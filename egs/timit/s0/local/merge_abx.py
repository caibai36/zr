from __future__ import print_function
import sys

def main():
    if len(sys.argv) != 3:
        print("Merge two abx files.")
        print("if the two abx line have the common time indice,")
        print("print the corresponding label pair.\n")
        print("Usage: python merge_abx.py abx_file1 abx_file2")
        print("python ./local/merge_abx.py data/test_phn_abx/FAKS0_SI1573.PHN.abx dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/cluster_label/FAKS0_SI1573.clabel.abx\n")
        return 1

    t = []
    m1 = {}
    m2 = {}
    with open(sys.argv[1], 'r') as in1, open(sys.argv[2], 'r') as in2:
        for line in in1:
            [time, label] = line.rstrip().split()
            t.append(time)
            m1[time] = label

        for line in in2:
            [time, label] = line.rstrip().split()
            m2[time] = label

        for time in t:
            if time in m1 and time in m2:
                print(str(time) + " " + m1[time] + " " + m2[time])
            
if __name__== '__main__':
    sys.exit(main())
