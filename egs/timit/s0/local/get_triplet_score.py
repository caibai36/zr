import numpy as np
import pandas as pd
import h5py
import os
import argparse
default_score_file="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/cos/analysis/tmp/timit_within.score"

def main():
    parser = argparse.ArgumentParser(description="Convert the score file of ABXpy toolkit to scores of triplets",
                                     epilog="python local/get_triplet_score.py --score_file=" + default_score_file)
    parser.add_argument("--score_file", type=str, default="")
    args = parser.parse_args()
    score_file = args.score_file    
    directory = os.path.dirname(score_file)
    task_type = score_file[len(score_file) - 12:len(score_file)-6]

    f = h5py.File(score_file, 'r')
    score_item = []
    pairs = []
    counts = []
    for item in f['scores']:
        score_item.append(np.array(f['scores'].get(item)))
        pairs.append(item)
        counts.append(np.array(f['scores'].get(item)).shape[0])
        df_counter = pd.DataFrame({"score_context": pairs, 'num_lines': counts})
        scores = np.concatenate(score_item, axis=0)

    out_score = os.path.join(directory, task_type + "_triplet_score.txt")
    out_counter = os.path.join(directory, task_type + "_scorecontext2numlines.txt")

    np.savetxt(out_score, scores, fmt="%d")
    df_counter.to_csv(out_counter, index=False)

if __name__ == "__main__":
    main()
