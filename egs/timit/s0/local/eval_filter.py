import pandas as pd
from sklearn import metrics

df = pd.read_csv("exp/dpgmm/data/merge/merge", sep='\s+', names=['phone', 'label'])
df.label=df.label.astype(str)
truth = df.phone
predict = df.label
print("homogenetiy, completeness and v_measure of true label of phone and cluster labels is {}          ", metrics.homogeneity_completeness_v_measure(truth, predict))

df = pd.read_csv("exp/dpgmm/data/merge/merge_filtered", sep='\s+', names=['phone', 'label'])
df.label=df.label.astype(str)
truth = df.phone
predict = df.label
print("homogenetiy, completeness and v_measure of true label of phone and filtered cluster labels is {} ", metrics.homogeneity_completeness_v_measure(truth, predict))
