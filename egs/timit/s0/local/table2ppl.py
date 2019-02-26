from  __future__ import print_function
import numpy as np
import scipy.stats as stats
import os.path as path
import sys

def main():
    if len(sys.argv) != 3:
        print("From table file to get the perplexity w.r.t phoneme label and cluster label, append perplexities to perplexity files .\n", file = sys.stderr)
        print("Usage: python table2ppl.py table_file ppl_directory", file = sys.stderr)
        print("eg: python local/table2ppl.py tmp/table fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl\n", file = sys.stderr)
        print("the table directory should have the table file of co-occurrance of label pairs.", file = sys.stderr)
        print("the numpy and scipy is needed.\n", file=sys.stderr)
        return  1
    
    table_file_name = sys.argv[1]

    # Print the perplexity tables.
    table = np.loadtxt(table_file_name)

    # NOTE:
    # table's dimension: ..., (29, 3), (29, 2), (29, )
    # Final one will be (29,) instead of (29, 1).
    if (len(table.shape) == 1):
        table = table.reshape(-1, 1)

    table_pr = table / np.sum(table, axis = 1).reshape(-1, 1)
    table_en = stats.entropy(np.transpose(table_pr), base = 2)
    table_ppl = np.power(2, table_en)
    
    table_pr_col = table / np.sum(table, axis = 0).reshape(1, -1)
    table_en_col = stats.entropy(table_pr_col, base = 2)
    table_ppl_col  = np.power(2, table_en_col)

    with open(sys.argv[2] + '/table_ppls', 'a') as ppl_file:
        print(*table_ppl, sep='\t', file=ppl_file)

    with open(sys.argv[2] + '/table_ppls_col', 'a') as ppl_col_file:
        print(*table_ppl_col, sep='\t', file=ppl_col_file)

if __name__ =='__main__':
    sys.exit(main())
