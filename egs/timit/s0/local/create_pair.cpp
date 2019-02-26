/* input a sequence, create the pairs of sequence elements.
 * Pairs symmetric, such as {a, b} {b, a}, only one will be included.
 * Pairs of itself, such as {a, a}, will be excluded
 */

#include <iostream>
#include <string>
#include <vector>
#include <iterator>
using namespace std;

int main() {
  vector<string> labels;

  copy(istream_iterator<string>(cin), istream_iterator<string>(), back_inserter(labels));

  for (int i = 0; i < labels.size() - 1; ++i)
    for (int j = i + 1; j < labels.size(); ++j)
      cout << labels[i] << " " << labels[j] << endl;

}
