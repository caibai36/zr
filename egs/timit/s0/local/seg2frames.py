import argparse
import sys
import re

def main():
    parser = argparse.ArgumentParser(description="Convert segement label with count of the label to frame labels",
                                     epilog="Usage: echo -en '1\\t1\\n2\\t2\\n' | python local/seg2frames.py # output: 1\\n2\\n2\\n")
    parser.add_argument("--input_file", type=str, default="")
    args = parser.parse_args()

    input_file = args.input_file
    in_file = open(input_file, 'r') if input_file else sys.stdin

    for line in in_file:
        label, count = re.split("\s+", line.strip())
        for i in range(int(count)):
            print(label)

if __name__ == "__main__":
    main()
