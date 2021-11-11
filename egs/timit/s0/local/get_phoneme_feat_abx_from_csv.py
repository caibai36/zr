import os
import pandas as pd
import numpy as np
import ast
import argparse

def get_phoneme_to_feature(feat2phn_file):
    phn2feat = {}
    phn2simplefeat = {}
    with open(feat2phn_file, 'r') as f:
        for line in f:
            line = line.strip()
            feat, phn = line.split()
            simplefeat = feat if "_" not in feat else feat[:feat.index("_")]
            phn2feat[phn] = feat
            phn2simplefeat[phn] = simplefeat

    return phn2feat, phn2simplefeat

def compute_abx_from_csv(filename, feat2phn_file="/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/egs/timit/s0/conf/feature2phone.map"):
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
    df_full = df.copy()
    # aggregate on talkers
    groups = df.groupby(['context', 'phone_1', 'phone_2'], as_index=False)
    df = groups['score'].mean()
    # aggregate on contexts
    groups = df.groupby(['phone_1', 'phone_2'], as_index=False)
    df = groups['score'].mean()
    
    print(f"{task_type} {(1 - df.mean()[0]) * 100:.3f}")

    #########################################################################################################
    # Get ABX score for phoneme
    df_phoneme = df.copy()

    # Optional without averaging across the speaker and context (much more data and use the raw error); Comment out the line if one want to use results when aggregating talker and contexts
    df = df_full.copy() 

    # Add the column of feature and simple feature
    phn2feat, phn2simplefeat = get_phoneme_to_feature(feat2phn_file)  # simplefeat is the simple feature such as simplifying the `stop_v' and `stop_u' to `stop'
    # ,phone_1,phone_2,score,feat_1,feat_2,sfeat_1,sfeat_2
    # 0,aa,ae,1.0,Mid,Front,Mid,Front
    # 1,aa,ah,0.375,Mid,Mid,Mid,Mid
    # ...
    # 5,aa,d,0.31944444444450004,Mid,Stop_v,Mid,Stop    
    df["feat_1"] = df.phone_1.apply(lambda x: phn2feat[x])
    df["feat_2"] = df.phone_2.apply(lambda x: phn2feat[x])
    df["sfeat_1"] = df.phone_1.apply(lambda x: phn2simplefeat[x])
    df["sfeat_2"] = df.phone_2.apply(lambda x: phn2simplefeat[x])

    # Get ABX scores for features
    df_feat = df[df['feat_1'] == df['feat_2']]
    df_feature = df_feat.groupby('feat_1', as_index=False)['score'].mean()

    # Get ABX scores for simple features
    df_sfeat = df[df['sfeat_1'] == df['sfeat_2']]
    df_sfeature = df_sfeat.groupby('sfeat_1', as_index=False)['score'].mean()

    return df, df_phoneme, df_feature, df_sfeature


parser = argparse.ArgumentParser(description="Compute abx scores from the csv file generated from ABX toolkit. Process the csv file from the ABXpy of timit_within.csv (or timit_across.csv) and output the ABX score of the phoneme with timit_within_phoneme.csv or ABX score of the feature with timit_within_feat.csv at the same directory.",
epilog="python ./local/get_phoneme_feat_abx_from_csv.py --in_csv=\"eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/edit/timit_within.csv\"")

parser.add_argument("--in_csv", type=str, default="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/edit/timit_within.csv")

args = parser.parse_args()
in_csv = args.in_csv

# df_full includes the feature columns
# df_feat => stop_v stop_u
# df_sfeat => stop (including the cross comparison of voiced and unvoiced)
df_full, df_phoneme, df_feat, df_sfeat = compute_abx_from_csv(in_csv)

print(df_feat)
print()
print(df_sfeat)

name_dir, ext = os.path.splitext(in_csv)  # .../timit_across.csv or .../timit_within.csv
full_file = name_dir + "_full" + ext # .../timit_across_full.csv
phn_file = name_dir + "_phoneme" + ext # .../timit_across_phoneme.csv
feat_file = name_dir + "_feat" + ext # .../timit_across_feat.csv
sfeat_file = name_dir + "_sfeat" + ext # .../timit_across_sfeat.csv

df_full.to_csv(full_file)
df_phoneme.to_csv(phn_file)
df_feat.to_csv(feat_file)
df_feat.to_csv(sfeat_file)






















# parser.add_argument("--out_phn_csv", type=str, default="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/kl/timit_across_phoneme.csv")
# parser.add_argument("--feature2phoneme", type=str, default="/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/egs/timit/s0/conf/feature2phone.map") # feat2phn_file = args.feature2phoneme


# df_feat = df[df['feat_1'] == df['feat_2']]
#     print("sum")
# #    print(df_feat.groupby('feat_1', as_index=False)['score'].sum())
# #    print("count")
# #    print(df_feat.groupby('feat_1', as_index=False)['score'].count())
#     df_feature = print(df_feat.groupby('feat_1', as_index=False)['score'].mean())
#     print()

#     df_sfeat = df[df['sfeat_1'] == df['sfeat_2']]
# #    print("sum")
# #    print(df_sfeat.groupby('sfeat_1', as_index=False)['score'].sum())
# #    print("count")
#     print(df_sfeat.groupby('sfeat_1', as_index=False)['score'].count())
#     print(df_sfeat.groupby('sfeat_1', as_index=False)['score'].mean())

#     # print(df_full.head(40))
#     # print(df.head(40))
#     # print(len(df_feat))
#     # print(df_feat.head(40))
#     # print(len(df_sfeat))
#     # print(df_sfeat.head(40))
#     return df_full, df_phoneme, None
