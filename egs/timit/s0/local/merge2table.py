from __future__ import print_function
import sys

label1_to_print = set()
def main():
    if len(sys.argv) != 2:
        print("Usage: eg: cat label_file | python merge2table.py merge")
        return 1
        
    s2 = set()
    counter = {}
    with open(sys.argv[1]) as in_merge:
        for line in in_merge:
            [l1, l2] = line.rstrip().split()
            s2.add(l2)
            if l1 not in counter:
                counter[l1] = {}
                counter[l1][l2] = 1
            elif l2 not in counter[l1]:
                counter[l1][l2] = 1
            else:
                counter[l1][l2] += 1

    for l in sys.stdin:
        label = l.rstrip()
        if label not in counter:
            for i in range(len(s2)):
                print("0\t", end='')
            print()
        else:
            for label2 in s2:
                if label2 not in counter[label]:
                    print("0\t", end = '')
                else:
                    assert(counter[label][label2] > 0)
                    print(str(counter[label][label2]) + "\t", end = '')
            print()
            
if __name__=="__main__":
    sys.exit(main())
