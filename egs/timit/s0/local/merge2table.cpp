/*
 * File: merge2table.
 * last modified at 16:34 on 12 January 2018 by bin-wu.    
 * 
 * Provide the merge file with two different label sequences,
 * and stdin the label file with labels we need to print out in order,
 * print out the table of the number of co-occurances of label pairs.
 * 
 * Usage: cat label_file | ./merge2table merge_file
 * eg: cat label_file | ./merge2table merge |  tr '\t' ' ' | paste label_file - 
 */

#include <map>
#include <set>
#include <vector>
#include <string>
#include <fstream>
#include <iostream>
using namespace std;

int main(int argc, char *argv []) {
  if (argc != 2) {
    cerr << "Provide the merge file with two different label sequences," << endl                                                                                                         
	 << "and stdin the label file with labels we need to print out in order," << endl
	 << "print out the table of the number of co-occurances of label pairs. " << endl << endl
	 << "Usage: cat label_file | ./merge2table merge_file " << endl
	 << "eg: cat label_file | ./merge2table merge |  tr '\\t' ' ' | paste label_file - " << endl << endl;
    return 1;
  }

  ifstream in(argv[1]);
  if (!in) cerr << "Merge file not found: " << argv[1] << endl;

  string label;
  vector<string> labelToPrint;
  while (cin >> label) labelToPrint.push_back(label);

  /* label pair of label1 and label2 */
  string l1, l2;
  /* set of all possible label2 */
  set<string> s2; // the key of s1 can be found in counter.
  /* counter table of the occurance of label1 and label2 pairs */
  map<string, map<string, int> > counter;
  
  while (in >> l1 >> l2) {
    s2.insert(l2);
    counter[l1][l2]++;
  }

  cerr << "Set of label2:";
  for (set<string>::iterator it = s2.begin(); it != s2.end(); ++it) cerr << *it << " ";
  cerr << endl;
  
  for (vector<string>::iterator itr = labelToPrint.begin(); itr != labelToPrint.end(); ++itr) {
    if (counter.find(*itr) == counter.end()) {
      cerr << "Warning: " << *itr << " is not found in merge file." << endl;
      for (int i = 0; i < s2.size(); ++i) cout << "0\t";
      cout << endl;
    } else {
      for (set<string>::iterator itr2 = s2.begin(); itr2 != s2.end(); ++itr2) {
	if (counter[*itr].find(*itr2) == counter[*itr].end()) cout << "0\t";
	else cout << counter[*itr][*itr2] << "\t";
      }
      cout << endl;
    }
  }
}
