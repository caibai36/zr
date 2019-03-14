/* 
 * File: split_post.cpp
 * last modified at 01:02 on 03 March 2019 by bin-wu.
 */

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <iterator>
#include <assert.h>
#include <algorithm>
#include <set>
#include <cmath>
using namespace std;

class Double2Key {
public:
  Double2Key(double epsilon = 0.0001): epsilon(epsilon) {}
  // Convert all the doubles (where we intended as keys) into integers
  // by multiplying them by the precision factor (e.g. 1e8) and rounding to the nearest (int)i+0.5(if i>0),
  // then create a set/map that keys off these integers
  int operator()(const double & value) const {return round(value / this->epsilon);}

private:
  double epsilon;
};

Double2Key double2key(0.0001);

void ReadPost(ifstream &inPost, const vector<string> &utter, const vector<int> &size, map<string, vector<string> > &utt2post) {
  string line;
  for (int i = 0; i < utter.size(); i++) {
    int s = size[i];

    vector<string> p;
    while (s--) {
      assert(getline(inPost, line));
      p.push_back(line);
    }
    
    utt2post.insert(make_pair(utter[i], p));
  }
 
  assert(!(inPost >> line));
}

void PrintPostABX(const string &outputDir, const map<string, vector<string> > &utt2post, const string &abxTimeDir) {
  for (map<string, vector<string> >::const_iterator itr = utt2post.begin(); itr != utt2post.end(); itr++) {
    string outFile =  outputDir + "/" + itr->first + ".post"; // abx format of cluster label
    ofstream out(outFile.c_str());

    string abxTimeFile = abxTimeDir + "/" + itr->first;
    ifstream abxTime(abxTimeFile.c_str());
    if(!abxTime) cout << "fail to open " << abxTimeFile << endl;

    set<double> abxTimes;
    double time;
    while (abxTime >> time) {
      abxTimes.insert(double2key(time));
    }
   
    for (int frameInd = 0; frameInd < itr->second.size(); frameInd++) {
      /* Start at the center of a frame with frame-length = 25ms and frame-shift = 10ms. */
      double time = 0.0125 + frameInd * 0.010;      
      string feat = itr->second[frameInd];
      // 3.4,4.5,5,66 -> 3.4 4.5 5.66
      replace(feat.begin(), feat.end(), ',', ' ');
      if (abxTimes.find(double2key(time)) != abxTimes.end()) out << time << " " << feat << endl;
    }
  }
}

int main(int argc, char *argv[]) {
  if (argc != 5) {
    cout << "Split the post-file according to the size-file, output with the ABX format with abx time." << endl
         << "abx-time-dir contains files of name as utter_id and content as a sequence of time for abx test" << endl
	 << "Usage: ./split_post_with_abx_time <size-file> <post-file> <abx-time-dir> <output-dir>" << endl
	 << "e.g.: ./local/split_post_with_abx_time data/test/utt2num_frames dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc data/test_time/test_abx_time abx/baseline_post" << endl
	 << "Note: ABX format: each line: <time-in-second> <posteriorgram-per-frame>" << endl << endl;
    return 1;
  }
  
  ifstream inSize(argv[1]), inPost(argv[2]);
  if(!inSize || !inPost) cerr << "Fail to open the file" << endl;
  string abxTimeDir(argv[3]);
  string outputDir(argv[4]);

  string u;
  int s;
  vector<string> utter;
  vector<int> size;
  assert(utter.size() == size.size());
  while (inSize >> u >> s) {
    utter.push_back(u);
    size.push_back(s);
  }

  map<string, vector<string> > utt2post;
  ReadPost(inPost, utter, size, utt2post);
  PrintPostABX(outputDir, utt2post, abxTimeDir);
  return 0;  
}
