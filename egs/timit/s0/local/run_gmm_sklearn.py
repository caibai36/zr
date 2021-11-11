import os
import argparse

import numpy as np
import sklearn
from sklearn.mixture import GaussianMixture

parser = argparse.ArgumentParser(description="Get posteriorgram matrix from the feature matrix by GMM")
parser.add_argument("--train_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc", help="training feature")
parser.add_argument("--test_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc", help="testing feature")
parser.add_argument("--test_post", type=str, required=False, default="dpgmm/test3/timit_test3_raw_GMM.post", help="test post")

# Arguments for GMM
# gm = GaussianMixture(n_components=2, covariance_type="full", max_iter=100, init_params="kmeans", means_init=None,  random_state=None, verbose=2).fit(X)
parser.add_argument("--K", type=int, default=3, help="the number of clusters (K)")
parser.add_argument("--seed", type=int, default=None, help="the random seed or the random state")
parser.add_argument("--cov_type", type=str, choices=["full", "tied", "diag", "spherical"], default="full", help="the type of covariance")
parser.add_argument("--epochs", type=int, default=100, help="the maximum iteraion or epochs for EM algorithm")
parser.add_argument("--init_params", type=str, default="kmeans", choices=["kmeans", "random"], help="the way of initalizing the parameters using kmeans or random")
parser.add_argument("--mean_init", type=int, nargs="+", default=None, help="initalized the mean of clusters")
parser.add_argument("--verbose", type=int, default=2, help="Enable verbose output. If 1 then it prints the current initialization and each iteration step. If greater than 1 then it prints also the log probability and the time needed for each step.")

args = parser.parse_args()
print(args)

train_data = np.loadtxt(args.train_file) # (num_of_samples, num_dim)
test_data = np.loadtxt(args.test_file) # (num_of_sample, num_dim)
print(train_data.shape)

gm = GaussianMixture(n_components=args.K, covariance_type=args.cov_type, max_iter=args.epochs, init_params=args.init_params,
                     means_init=args.mean_init, random_state=args.seed, verbose=args.verbose).fit(train_data)

test_post = gm.predict_proba(test_data) 
print("the posteriorgram shape: {}".format(test_post.shape)) # (num_of_samples, K)
print("the posteriorgram at: \"{}\"".format(args.test_post))

np.savetxt(args.test_post, test_post, fmt='%.4e', delimiter=',')
