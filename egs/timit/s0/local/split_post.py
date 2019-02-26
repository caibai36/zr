##################################################################################################################################################
#
# File: split_post.cpp
# last modified at 22:32 on 09 January 2018 by WuBin.
#
# Split the post-file according to the size-file, output with the ABX format for each utterance as a file.
# Usage: python split_post.py <size-file> <post-file> <output-dir> 
# e.g.:  python local/split_post.py dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel dpgmm/test3/data/01.raw.mfcc/cluster_label/
#
# Note: 
# size-file format: each line as <utterance-id> <num-of-frames-per-utterance>
# post-file format: each line as <label-per-frame> or <posteriorgram-per-frame>
# ABX format:       each line as <time-in-second> <label-per-frame> or
#                                <time-in-second> <posteriorgram-per-frame>
#
##################################################################################################################################################

from __future__ import print_function
import sys
import os

def read_post(in_post, utter, size, utt2post):
    for i, val in enumerate(utter):
        s = int(size[i])
        
        p = []
        while s:
            s -= 1
            line = in_post.readline().rstrip()
            p.append(line)

        utt2post[utter[i]] = p

def print_post_abx(out_dir, utt2post):
    if not os.path.exists(out_dir):
            os.makedirs(out_dir)
            
    for utt in utt2post:
        post = utt2post[utt]
        out_file = str(out_dir) + "/" + str(utt) + ".pos";

        with open(out_file, 'w') as out:
            for frame_ind, feat in enumerate(post):
                # Start at the center of a frame with frame-length = 25ms and frame-shift = 10ms.
                time = 0.0125 + frame_ind * 0.010;
                # 3.4,4.5,5,66 -> 3.4 4.5 5.66
                print(str(time) + " " + str(feat).replace(',', ' '), file = out)
                
def main():
    if len(sys.argv) != 4 :
        print("Split the post-file according to the size-file, output with the ABX format.")
        print("Usage: python split_post.py <size-file> <post-file> <output-dir>")
	print("e.g.:  python local/split_post.py dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel dpgmm/test3/data/01.raw.mfcc/cluster_label/")
	print("Note:  ABX format: each line: <time-in-second> <posteriorgram-per-frame>\n")
        return 1
    
    in_size = open(sys.argv[1], 'r')
    in_post = open(sys.argv[2], 'r')
    out_dir = sys.argv[3]
    
    utter = []
    size = []
    for line in in_size:
        [u, s] = line.rstrip().split()
        utter.append(u)
        size.append(s)

    utt2post = {}
    read_post(in_post, utter, size, utt2post)
    print_post_abx(out_dir, utt2post)
    
if __name__ == '__main__':
    sys.exit(main())
