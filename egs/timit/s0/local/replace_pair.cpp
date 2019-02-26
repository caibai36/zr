/* stdin: a pair of strings as the 'replace from string' and the 'replace to string'
 * argv[1]: the sequence file with the tokens to replace
 * echo '6 0' | ./local/replace_pair tmp_seq
 */

#include <iostream>
#include <string>
#include <iterator>
#include <algorithm>
#include <vector>
#include <fstream>
#include <sstream>
using namespace std;

int main(int argc, char *argv[]) {
  ifstream in(argv[1]);
  if (!in) {
    cerr << "Fail to open the file " << argv[1] << endl;
  }

  string from, to;
  cin >> from >> to;
  
  string line;
  while (getline(in, line)) {
    vector<string> tokens;
    stringstream converter(line);
    copy(istream_iterator<string>(converter), istream_iterator<string>(), back_inserter(tokens));
    replace(tokens.begin(), tokens.end(), from, to);
    copy(tokens.begin(), tokens.end(), ostream_iterator<string>(cout, " "));
    cout << endl;
  }
}
