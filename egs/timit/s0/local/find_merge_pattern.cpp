#include <iostream>
#include <fstream>
#include <string>
#include <vector>
using namespace std;

int main() {
  ifstream in("exp/filter_label/merge");
  if (!in) cerr << "Fail to open the file" << endl;
  ofstream out("exp/filter_label/merge_patterns"); 

  string phn, lab;
  vector<string> phns, labs;
  while (in >> phn >> lab) {
    phns.push_back(phn);
    labs.push_back(lab);
  }

  int m_count = 0;
  int right_count = 0;
  for (int i = 1; i < labs.size() - 1 ; ++i) {
    if (labs[i] != labs[i - 1] && labs[i - 1] == labs[i + 1]) {
      m_count++;
      out << phns[i - 1] << "\t" << labs[i - 1] << endl; 
      out << phns[i] << "\t" << labs[i] << endl;
      out << phns[i + 1] << "\t" << labs[i + 1] << endl;
      out << "---------------------------" << endl;
      if (phns[i] == phns[i - 1] && phns[i] == phns[i + 1]) right_count++;
    }
  }
  
  cout << "The rate of merge pattern with the same phones is: "<< double(right_count) / m_count << endl;
}
