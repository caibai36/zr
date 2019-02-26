# Read the perplexity table from the ppl_dir,
# print the phoneme ppl table, the feature ppl table and the normalized ones.
# Usage: python create_norm_ppl_table.py ppl_dir feat2phn_map_file
# 
# eg.: python local/create_norm_ppl_table.py fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl conf/simplefeature2phone.map
#

from __future__ import print_function, division
import pandas as pd
import numpy as np
import sys

def normal_ppl_dataframe(df):
    values = (df.values - 1) / (df.values - 1)[:, 0].reshape(-1, 1)
    return pd.DataFrame(values, columns = df.columns, index = df.index)

ppl_dir = sys.argv[1]
feat2phn_file = sys.argv[2]

feat2phn = pd.read_csv(sys.argv[2], header = None, sep = "\s+", names = ['feature', 'phoneme'])
feat2phn['feat_phn']  = feat2phn['feature'] +  '_'  + feat2phn['phoneme']

ppl = np.loadtxt(ppl_dir + '/table_ppls')

phn_table_ppl = pd.DataFrame(ppl.T, columns = np.arange(ppl.shape[0]), index = feat2phn['feat_phn'])

feat_table_ppl = pd.DataFrame(ppl.T, columns = np.arange(ppl.shape[0]), index = feat2phn['feature'])
feat_table_ppl = feat_table_ppl.groupby('feature', sort = False).mean()

with open(ppl_dir + "/feat_table_ppl", 'w') as feat_file:
    print(feat_table_ppl.to_csv(sep = '\t'), file = feat_file)

with open(ppl_dir + "/phn_table_ppl", 'w') as phn_file:
    print(phn_table_ppl.to_csv(sep = '\t'), file = phn_file)

with open(ppl_dir + "/norm_feat_table_ppl", 'w') as norm_feat_file:
    print(normal_ppl_dataframe(feat_table_ppl).to_csv(sep = '\t'), file = norm_feat_file)

with open(ppl_dir + "/norm_phn_table_ppl", 'w') as norm_phn_file:
    print(normal_ppl_dataframe(phn_table_ppl).to_csv(sep = '\t'), file = norm_phn_file)
