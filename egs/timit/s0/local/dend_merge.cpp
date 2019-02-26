/* 
 * Merge the merge file labels according to the merge order fo dendrogram.
 * Usage: cat merge_order_file | ./dend_merge merge_file
 *  e.g.: echo -e '0 43 2\n2 6 10' | ./local/dend_merge merge
 *  e.g.: cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/merge_order.txt | ./local/dend_merge fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge
 *
 * stdin: The merge order of the labels according to the dendrogram.
 *        Each line represents merging two labels into a new one 
 *        for constructing the dendrogram from leaves to the root.
 * merge_file: the merge file with each line as a  pair of phoneme label and cluster label each frame.
 */


#include <iostream>
#include <string>
#include <fstream>
#include <algorithm>
#include <vector>
using namespace std;

int main(int argc, char *argv[]) {
  ifstream in(argv[1]);
  if (!in) {
    cerr << "Fail to open the merge file: " << argv[1] << endl;
    return 1;
  }

  string phn, clu;
  vector<string> phn_label, clu_label;
  while (in >> phn >> clu) {
    phn_label.push_back(phn);
    clu_label.push_back(clu);
  }

  string from1, from2, to;
  while (cin >> from1 >> from2 >> to) {
    replace(clu_label.begin(), clu_label.end(), from1, to);
    replace(clu_label.begin(), clu_label.end(), from2, to);
  }

  for (size_t i = 0; i < clu_label.size(); ++i) 
    cout << phn_label[i] << " " << clu_label[i] << endl;
}
