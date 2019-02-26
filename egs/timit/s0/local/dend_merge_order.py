# Generate the merge order of labels according to the dendrogram.
# Usage:
#       eg. echo -e '1\n6\n5\n4\n7\n2' | python local/dend_merge_order.py merge_order.txt
#
# stdin: condensed distance vector; implicit label 0, 1, 3, ....
#        eg. [1, 6, 5, 4, 7, 2] with label 0, 1, 2, 3
# output to the merge_order file: merge order of the label set
#               with format <merge_from1, merge_from2, to>
#               [bin-wu@ahctitan02 timit]$ cat merge_order.txt
#               0 1 4
#               2 3 5
#               4 5 6

  
from __future__ import print_function, division
from scipy.cluster.hierarchy import dendrogram, linkage
import numpy as np
import sys

# condensed distance vector.
# eg. cond_dist = np.loadtxt("tri_cond_dist.txt")
# eg. cond_dist = np.array([1, 6, 5, 4, 7, 2])
cond_dist = np.array([dist for dist in sys.stdin], dtype=float)

# num * (num - 1) / 2 = size(cond_dist)
num_of_labels = (1 + np.sqrt(1 + 8 * len(cond_dist))) / 2

gen_labels = np.arange(num_of_labels, num_of_labels * 2 - 1).reshape(-1, 1)

Z = linkage(cond_dist, 'complete')
gen_Z = np.hstack([Z[:, 0].reshape(-1, 1), Z[:, 1].reshape(-1, 1), gen_labels])
gen_Z = gen_Z.astype(int)
np.savetxt(sys.argv[1], gen_Z, fmt='%d')
