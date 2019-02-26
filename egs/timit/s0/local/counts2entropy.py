# Input a col. of counts; output the distribution
# [bin-wu@ahctitan02 timit]$ echo -en '2\n2\n2\n2\n' | python local/counts2entropy.py
# 0.25    0.25    0.25    0.25
# 2.0

from __future__ import print_function, division
import sys
import numpy as np
from scipy.stats import entropy

counts = np.array([ int(line.strip()) for line in sys.stdin ])
pr = counts / np.sum(counts)
en = entropy(pr, base = 2)
# print(*pr, sep = '\t')
print(en)
