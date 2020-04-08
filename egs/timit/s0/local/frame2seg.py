# Convert the frame label to segment label with the count of the frame
from typing import List
import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description="Convert the frame label to segment label with the count of the frame",
                                     epilog = "Usage: echo -e '1\\n2\\n2' | python local/frame2seg.py # output: 1\\t1\\n2\\t2\\n")
    parser.add_argument("--input_file", type=str, default="")
    parser.add_argument("--output_file", type=str, default="")
    args = parser.parse_args()
    
    input_file = args.input_file
    output_file = args.output_file

    in_file = open(input_file, 'r') if input_file else sys.stdin
    out_file = open(output_file, 'w') if output_file else sys.stdout

    labels: List = []
    for line in in_file:
        labels.append(line.strip())

    assert len(labels) > 0, "Error: we should not use the empty file"
    pre = labels[0]
    count = 0
    for label in labels:
        cur = label
        assert label, "Error: empty label"
        if label == pre:
            count += 1
        else:
            out_file.write(f"{pre}\t{count}\n")
            count = 1
        pre = cur

    out_file.write(f"{cur}\t{count}\n")

if __name__ == "__main__":
    main()
