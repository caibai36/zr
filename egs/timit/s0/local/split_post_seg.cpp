/* 
 * File: split_post.cpp
 * last modified at 01:02 on 09 January 2018 by bin-wu.
 *  
 * Split the post-file according to the frames_per_utt file and utt2file mapping in the segments file, output with the ABX format.
 * Usage: ./split_post_seg <FPU-file> <post-file> <segments-file> <output-dir>
 * e.g.: ./local/split_post_seg dpgmm/test/frames_per_utt dpgmm/test/tso_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post data/test/segments_sorted abx/post/dpgmm_post
 *
 * Note: 
 * FPU-file format:       each line as <utt-id> <frames_per_utt>
 * post-file format:      each line as <posteriorgram-per-frame>
 * segments-file format:  each line as <utt-id> <file-id> <begin-time-in-sec> <end-time-in-sec>
 * ABX format:            each line as <time-in-sec> <posteriorgram-per-frame> per file.    
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
      assert(getline(inPost, line));
      p.push_back(line);
    }
    
    utt2post.insert(make_pair(utter[i], p));
  }

  assert(!(getline(inPost, line)));
}

void ReadPostFromstdin(const vector<string> &utter, const vector<int> &size, map<string, vector<string> > &utt2post) {
  string line;
  for (int i = 0; i < utter.size(); i++) {
    int s = size[i];

    vector<string> p;
    while (s--) {
      assert(getline(cin,line));
      p.push_back(line);
    }
    
    utt2post.insert(make_pair(utter[i], p));
  }

  assert(!(getline(cin, line)));
}

void PrintPostABX(const string &outputDir, map<string, vector<string> > &utt2post,  const map<string, vector<string> > &file2utts,  map<string, pair<double, double> > &utt2time) {
  for (map<string, vector<string> >::const_iterator itr = file2utts.begin(); itr != file2utts.end(); ++itr) {
    string outFile = outputDir + "/" + itr->first + ".pos";
    ofstream out(outFile.c_str());

    /* Make sure the begin time increases for each file. */
    double pre = -1;
    double begin, end;
    for (vector<string>::const_iterator it = itr->second.begin(); it != itr->second.end(); it++) {
      /* Read begin time and end time for each utterance. */
      string utt = *it;
      begin = utt2time[utt].first;
      end = utt2time[utt].second;
      assert(begin >= pre);
      pre = begin;

      for (int frameInd = 0; frameInd < utt2post[utt].size(); frameInd++) {
	/* Start at the center of a frame with frame-length = 25ms and frame-shift = 10ms. */
	double time = begin + 0.0125 + frameInd * 0.010;
    
	string feat = utt2post[utt][frameInd];
	// 3.4,4.5,5,66 -> 3.4 4.5 5.66
	replace(feat.begin(), feat.end(), ',', ' ');
	out << time << " " << feat << endl;
      }
    }
    out.close();
  }
}  


int main(int argc, char *argv[]) {
  if (argc != 5) {
    cerr << "Split the post-file according to the frames_per_utt file and utt2file mapping in the segments file, output with the ABX format." << endl
	 << "Usage: ./split_post_seg <FPU-file> <post-file> <segments-file> <output-dir>" << endl
	 << "Usage: cat <post-file> | ./split_post_seg <FPU-file> - <segments-file> <output-dir>" << endl
	 << "e.g.: ./local/split_post_seg dpgmm/test/frames_per_utt dpgmm/test/buckeye_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post dpgmm/test/segments_sorted abx/post/dpgmm_post" << endl
         << "Note:" << endl 
         << "FPU-file format:       each line as <utt-id> <frames_per_utt>" << endl
         << "post-file format:      each line as <posteriorgram-per-frame>" << endl
         << "segments-file format:  each line as <utt-id> <file-id> <begin-time-in-sec> <end-time-in-sec>" << endl
         << "ABX format:            each line as <time-in-sec> <posteriorgram-per-frame> per file." << endl
	 << "segments-file should be sorted first by file-id, then by begin time(may use the gnu sort)" << endl << endl;
    return 1;
  }

  bool postFromstdin = false;
  string token(argv[2]);
  if (token == "-") postFromstdin = true;
  
  if (!postFromstdin) { 
    ifstream inSize(argv[1]), inPost(argv[2]), inSeg(argv[3]);
    if(!inSize || !inPost || !inSeg) cerr << "Fail to open the file" << endl;
    string outputDir(argv[4]);

    string u;
    int s;
    vector<string> utter;
    vector<int> size;
    while (inSize >> u >> s) {
      utter.push_back(u);
      size.push_back(s);
    }
 
    map<string, vector<string> > utt2post;
    ReadPost(inPost, utter, size, utt2post);

    map<string, vector<string> > file2utts;
    map<string, pair<double, double> > utt2time;
    string utt, file;
    double begin, end;
    while (inSeg >> utt >> file >> begin >> end) {
      file2utts[file].push_back(utt);
      pair<double, double> time = make_pair(begin, end);
      utt2time.insert(make_pair(utt, time));
    }
    PrintPostABX(outputDir, utt2post, file2utts, utt2time);
    return 0;
  } else {
    ifstream inSize(argv[1]), inSeg(argv[3]);
    if(!inSize || !inSeg) cerr << "Fail to open the file" << endl;
    string outputDir(argv[4]);

    string u;
    int s;
    vector<string> utter;
    vector<int> size;
    while (inSize >> u >> s) {
      utter.push_back(u);
      size.push_back(s);
    }
 
    map<string, vector<string> > utt2post;
    ReadPostFromstdin(utter, size, utt2post);
    
    map<string, vector<string> > file2utts;
    map<string, pair<double, double> > utt2time;
    string utt, file;
    double begin, end;
    while (inSeg >> utt >> file >> begin >> end) {
      file2utts[file].push_back(utt);
      pair<double, double> time = make_pair(begin, end);
      utt2time.insert(make_pair(utt, time));
    }
    PrintPostABX(outputDir, utt2post, file2utts, utt2time);
    return 0;
  }
}
