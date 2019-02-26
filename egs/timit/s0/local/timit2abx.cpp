/*
 * File: timit2abx.cpp
 * last modified at 22:59 on 10 January 2018 by bin-wu.
 *
 * From the timit format (*.phn) to the abx format
 * Usage: ./timit2abx phn_file [phones_map_file] 
 * eg: ./timit2abx si1392.phn phones.61-39.map
 * eg: ./local/timit2abx data/test_phn/FADG0_SI649.PHN ./conf/phones.61-39.map
 *
 * timit format: <start> <end> <label>  
 * (No header, and <start> and <end> are in integer sample counts)
 * (i.e. in units of 1/16000 sec or whatever the sampling rate is). 
 *
 * abx format: <time> <label>
 */

#include <math.h>
#include <assert.h>
#include <string>
#include <fstream>
#include <iostream>
#include <map>
using namespace std;

/* the shift of a frame */
const double SHIFT = 0.01;
/* the the window size of a frame*/
const double WINDOW_SIZE = 0.025;
/* the sample rate of the audio */
const double RATE = 16000;

/* from frame index to the time of the center of the frame. */
double frameInd2time(double frameInd) {
  return WINDOW_SIZE / 2 + frameInd * SHIFT;
}

/* Choose the index of frame nearest to the given time. */
double time2frameInd(double time) {
  double frameInd = (time - WINDOW_SIZE / 2) / SHIFT;

  if (time < WINDOW_SIZE / 2) return 0;
 
  double pre = frameInd2time(floor(frameInd));
  double next = pre + SHIFT;
  double avg = (pre + next) / 2;

  /* 'floor' may have some precision issue, so make a precision bound. */
  double precision = 0.00001;
  assert(time - pre >= -precision && next - time >= -precision);
  
  return time - avg <= 0 ? floor(frameInd) : floor(frameInd) + 1; 
}

int main(int argc, char *argv[]) {
  ifstream in(argv[1]);
  if (argc != 2 && argc != 3) { 
    cerr << "From the timit format (*.phn) to the abx format" << endl
         << "Usage: ./timit2abx phn_file [phones_map_file]" << endl
	 << "eg: ./local/timit2abx data/test_phn/FADG0_SI649.PHN ./conf/phones.61-39.map" << endl << endl
	 << "timit format: <start> <end> <label>" << endl
	 << "abx format: <time> <label>" << endl;
    return 1;
  }
  if(!in) cerr << "The file: " << argv[1] << " doesn't exist." << endl;

  /* Map the phone set. */
  map<string, string> m;
  bool hasTrans = false;
  if(argc == 3) hasTrans= true;
  if (hasTrans) {
    ifstream inTrans(argv[2]);
    if (!inTrans) cerr << "The file: " << argv[2] << " doesn't exist." << endl;

    string from, to;
    while (inTrans >> from >> to) 
      m.insert(make_pair(from, to));
  }
      
  /* start and end are in integer sample counts. */
  double start, end;
  string label;
  while (in >> start >> end >> label) {
    double startTime = start / RATE, endTime = end / RATE;
    string l = hasTrans ? m[label] : label;
    /* NOTE: start_frame_index included, end_frame_index excluded. */
    for (int ind = time2frameInd(startTime); ind < time2frameInd(endTime); ind++) 
      cout << frameInd2time(ind) << " " << l << endl;
  }
  
  return 0;
}
