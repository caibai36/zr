from  __future__ import print_function
import numpy as np
import scipy.stats as stats
import os.path as path
import sys

def main():
    # path = 'dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/tables'
    if len(sys.argv) != 2:
        print("Print the probability table, entropy table and perplexity table to the table directory.\n", file = sys.stderr)
        print("Usage: python table_stat.py tables_directory", file = sys.stderr)
        print("eg: python local/table_stat.py dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/tables\n", file = sys.stderr)
        print("the table directory should have the table file of co-occurrance of label pairs.", file = sys.stderr)
        print("the numpy and scipy is needed.\n", file=sys.stderr)
        return  1
    
    path = sys.argv[1]

    # Print the probability table, entropy table and perplexity table.
    table = np.loadtxt(path + '/table')

    # NOTE:
    # table's dimension: ..., (29, 3), (29, 2), (29, )
    # Final one will be (29,) instead of (29, 1).
    if (len(table.shape) == 1):
        table = table.reshape(-1, 1)

    table_pr = table / np.sum(table, axis = 1).reshape(-1, 1)
    table_en = stats.entropy(np.transpose(table_pr), base = 2)
    table_ppl = np.power(2, table_en)
    
    np.savetxt(path + '/table_pr', table_pr, delimiter = '\t')
    np.savetxt(path + '/table_en', table_en, delimiter = '\t')
    np.savetxt(path + '/table_ppl', table_ppl, delimiter = '\t')
    
    table_pr_col = table / np.sum(table, axis = 0).reshape(1, -1)
    table_en_col = stats.entropy(table_pr_col, base = 2)
    table_ppl_col  = np.power(2, table_en_col)
        
    np.savetxt(path + '/table_pr_col', table_pr_col, delimiter = '\t')
    np.savetxt(path + '/table_en_col', table_en_col, delimiter = '\t')
    np.savetxt(path + '/table_ppl_col', table_ppl_col, delimiter = '\t')

if __name__ =='__main__':
    sys.exit(main())
