/*                                                                                                                                                                              * File: label_filter.cpp                                                                                                                                                  
 * last modified at 12:29 on 12 Mar. 2018 by bin-wu.                                                                                                                           
 *                                                                                                                                                                           
 * Filter and normalize the label sequence of a utterance.
 * Two cases will be modified:  diff cur diff
 * eg "... 1 2 1 ... " -> "... 1 1 1 ..."
 * 
 */


#include <iostream>
#include <string>
#include <vector>
#include <iterator>
#include <algorithm>
using namespace std;

int main() {
  vector<string> v;
  copy(istream_iterator<string>(cin), istream_iterator<string>(), back_inserter(v));
  // copy(v.begin(), v.end(), ostream_iterator<string>(cout, " ")); cout << endl;

  if (v.size() >= 2) {
    for (vector<string>::iterator itr = v.begin() + 1; itr != v.end(); ++itr) {
      string cur = *itr;
      string pre = *(itr - 1);
      string next1 = (itr + 1) >= v.end() ? "-1" : *(itr + 1);
      string next2 = (itr + 2) >= v.end() ? "-1" : *(itr + 2);

      if (cur != pre && cur != next1) {
	if (pre == next1) *itr = pre;  // case1: "y x y" -> "y y y"
	// else if (cur != next2) *itr = "-1"; // case2: "y z x k b" -> "y z -1 k b"
      }
    }
  }

  // copy(v.begin(), v.end(), ostream_iterator<string>(cout, " ")); cout << endl;
  v.erase(remove(v.begin(), v.end(), "-1"), v.end());
  // copy(v.begin(), v.end(), ostream_iterator<string>(cout, " ")); cout << endl;
  copy(v.begin(), v.end(), ostream_iterator<string>(cout, "\n"));
}

