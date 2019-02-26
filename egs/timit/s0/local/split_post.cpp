/* 
 * File: split_post.cpp
 * last modified at 01:02 on 09 January 2018 by bin-wu.
 *
 * Split the post-file according to the size-file, output with the ABX format for each utterance as a file.
 * Usage: ./split_post <size-file> <post-file> <output-dir> 
 * e.g.: ./local/split_post dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel dpgmm/test3/data/01.raw.mfcc/cluster_label/
 *
 * Note: 
 * size-file format: each line as <utterance-id> <num-of-frames-per-utterance>
 * post-file format: each line as <label-per-frame> or <posteriorgram-per-frame>
 * ABX format:       each line as <time-in-second> <cluster-label-per-frame> or
 *                                <time-in-second> <posteriorgram-per-frame>    
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

void ReadPost(ifstream &inPost, const vector<string> &utter, const vector<int> &size, map<string, vector<string> > &utt2post) {
  string line;
  for (int i = 0; i < utter.size(); i++) {
    int s = size[i];

    vector<string> p;
    while (s--) {
      assert(inPost >> line);
      p.push_back(line);
    }
    
    utt2post.insert(make_pair(utter[i], p));
  }
 
  assert(!(inPost >> line));
}

void PrintPostABX(const string &outputDir, const map<string, vector<string> > &utt2post) {
  for (map<string, vector<string> >::const_iterator itr = utt2post.begin(); itr != utt2post.end(); itr++) {
    string outFile =  outputDir + "/" + itr->first + ".clabel.abx"; // abx format of cluster label
    ofstream out(outFile.c_str());
    for (int frameInd = 0; frameInd < itr->second.size(); frameInd++) {
      /* Start at the center of a frame with frame-length = 25ms and frame-shift = 10ms. */
      double time = 0.0125 + frameInd * 0.010;
      string feat = itr->second[frameInd];
      // 3.4,4.5,5,66 -> 3.4 4.5 5.66
      replace(feat.begin(), feat.end(), ',', ' ');
      out << time << " " << feat << endl;
    }
  }
}

int main(int argc, char *argv[]) {
  if (argc != 4) {
    cout << "Split the post-file according to the size-file, output with the ABX format." << endl
	 << "Usage: ./split_post <size-file> <post-file> <output-dir>" << endl
	 << "e.g.: ./local/split_post dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel dpgmm/test3/data/01.raw.mfcc/cluster_post/" << endl
	 << "Note: ABX format: each line: <time-in-second> <posteriorgram-per-frame>" << endl << endl;
    return 1;
  }
  
  ifstream inSize(argv[1]), inPost(argv[2]);
  if(!inSize || !inPost) cerr << "Fail to open the file" << endl;
  string outputDir(argv[3]);

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
  PrintPostABX(outputDir, utt2post);
  return 0;  
}
