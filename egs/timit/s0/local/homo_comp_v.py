import sys
import argparse
import pandas as pd
import numpy as np
from sklearn import metrics

def main():
    parser = argparse.ArgumentParser(description="compute the homogeneity, completeness and v_measure",
                                     epilog="usage: cat class_cluster_colpair.txt | python homo_comp_v.py")
    args = parser.parse_args()
    df = pd.read_csv(sys.stdin, sep='\s+', names=['class', 'cluster'], index_col=None)
    homo = metrics.homogeneity_score(df["class"].values, df["cluster"].values)
    comp = metrics.completeness_score(df["class"].values, df["cluster"].values)
    v = metrics.v_measure_score(df["class"].values, df["cluster"].values)
    print(f"{homo:.4f} {comp:.4f} {v:.4f}")

if __name__ == "__main__":
    main()

