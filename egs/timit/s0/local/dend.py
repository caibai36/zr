# Usage: python local/dend.py "fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/fl.txt" "fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/dendrogram_complete_fl_tri.png"
from __future__ import print_function, division
from scipy.cluster.hierarchy import dendrogram, linkage
from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import sys

# condensed distance vector.
# cond_dist = np.array([1, 6, 5, 4, 7, 2])
fl = pd.read_csv(sys.argv[1], header = None, sep = '\s+',
                 names = ['label1', 'label2', 'ent_before_merge', 'ent_after_merge', 'fl']) 

cond_dist = fl['fl'].values

# num * (num - 1) / 2 = size(cond_dist)
num_of_labels = (1 + np.sqrt(1 + 8 * len(cond_dist))) / 2

gen_labels = np.arange(num_of_labels, num_of_labels * 2 - 1).reshape(-1, 1)

Z = linkage(cond_dist, 'complete')
# fig = plt.figure(figsize = (25, 10))
# fig = plt.figure(figsize = (25, 15))
fig = plt.figure(figsize = (20, 10))
dn = dendrogram(Z)

ax = plt.gca()
for label in ax.get_xticklabels():
    label.set_fontsize(12.)     

for label in ax.get_yticklabels():
    label.set_fontsize(12.)     

plt.xlabel("labels of clusters", fontsize = 16)
plt.ylabel("distance", fontsize = 16)
plt.title("Hierarchical Clustering Dendrogram - method: 'complete linkage'; distance: 'functional load with trigram'\n", fontsize = 20)
# plt.show()
fig.savefig(sys.argv[2])
