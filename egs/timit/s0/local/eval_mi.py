import pandas as pd
from sklearn import metrics
import sys

if len(sys.argv) == 1:
    print("python eval_mi.py phone_label file")
    exit()

df = pd.read_csv(sys.argv[1], sep='\s+', names=['phone', 'label'])
df.label=df.label.astype(str)
truth = df.phone
predict = df.label
(h, c, v) = metrics.homogeneity_completeness_v_measure(truth, predict)
print(f"homogenetiy, completeness and v_measure of true label of phone and cluster labels is:")
print(f"homogenetiy: {h:.4f}")
print(f"completeness: {c:.4f}")
print(f"v_measure: {v:.4f}")
