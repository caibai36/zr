/* 
 * File: split_post.cpp
 * last modified at 01:02 on 09 January 2018 by bin-wu.
 */

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <iterator>
#include <assert.h>
#include <algorithm>
using namespace std;

void ReadPostwithTimeIndex(ifstream &inPost, ifstream &inTime, const vector<string> &utter, const vector<int> &size, map<string, vector<string> > &utt2post) {
  string time, label;
  for (int i = 0; i < utter.size(); i++) {
    int s = size[i];

    vector<string> p;
    while (s--) {
      assert(inTime >> time);
      assert(getline(inPost, label));
      p.push_back(time + " " + label);
    }
    
    utt2post.insert(make_pair(utter[i], p));
  }
 
  assert(!(inPost >> label));
}

void PrintPostABX(const string &outputDir, const map<string, vector<string> > &utt2post) {
  for (map<string, vector<string> >::const_iterator itr = utt2post.begin(); itr != utt2post.end(); itr++) {
    string outFile =  outputDir + "/" + itr->first + ".post"; // abx format of cluster label
    ofstream out(outFile.c_str());
    for (vector<string>::const_iterator it = itr->second.begin(); it != itr->second.end(); ++it) out << *it << endl;
  }
}

int main(int argc, char *argv[]) {
  if (argc != 5) {
    cout << "Split the post-file according to the size-file, output with the ABX format." << endl
	 << "Usage: ./split_post <size-file> <time-file> <post-file> <output-dir>" << endl
	 << "e.g.:  ./local/split_post.v2 exp/dpgmm/data/merge/utt2frames exp/dpgmm/data/merge/time exp/dpgmm/data/merge/timit_label tmp/label_tmp/" << endl
	 << "Note: ABX format: each line: <time-in-second> <posteriorgram-per-frame>" << endl << endl;
    return 1;
  }
  
  ifstream inSize(argv[1]), inTime(argv[2]), inPost(argv[3]);
  if(!inSize || !inPost || !inTime) cerr << "Fail to open the file" << endl;
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

  //vector<double> times;
  //copy(istream_iterator<double>(inTime), istream_iterator<double>(), back_inserter(times));
    
  map<string, vector<string> > utt2post;
  ReadPostwithTimeIndex(inPost, inTime, utter, size, utt2post);
  PrintPostABX(outputDir, utt2post);
  return 0;  
}
