import pandas as pd
import numpy as np
import ast
import argparse

def compute_abx_from_csv(filename):
    # csv_file produced from the ABX test software with --csv flag.
    # There are two possible postfix for the filename of the csv file.
    # XXX_within.csv
    # XXX_across.csv

    task_type = filename[len(filename) - 10:len(filename)-4]
    assert task_type == "across" or task_type == "within", "the filename should be XXX_within.csv or XXX_across.csv"
    df = pd.read_csv(filename, sep='\t')
    if task_type=='across':
        df['context'] = df['by']
    elif task_type=='within':
        arr = np.array(list(map(eval, df['by'])))
        df['talker']  = [e for e, f in arr]
        df['context'] = [f for e, f in arr]
    else:
        raise ValueError('Unknown task type: {0}'.format(task_type))
    del df['by']
    df2 = df.copy()
    # aggregate on talkers
    groups = df.groupby(['context', 'phone_1', 'phone_2'], as_index=False)
    df = groups['score'].mean()
    # aggregate on contexts    
    groups = df.groupby(['phone_1', 'phone_2'], as_index=False) 
    df = groups['score'].mean()

    print(f"{task_type} {(1 - df.mean()[0]) * 100:.3f}")

def main():
    parser = argparse.ArgumentParser(description="Compute abx from the csv file generated from ABX toolkit",
                                     epilog="python local/eval_abx_from_csv.py --csv_file=\"eval/abx/result/exp/dpgmm/baseline/vltn.deltas_post/cos/timit_within.csv\"")
    parser.add_argument("--csv_file", type=str, default="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/kl/timit_across.csv")
    args = parser.parse_args()
    cvs_file = args.csv_file
    compute_abx_from_csv(cvs_file)

if __name__ == "__main__":
    main()
