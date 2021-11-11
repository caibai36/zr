import argparse
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import chi2
from scipy.stats import multivariate_normal
from sklearn import metrics
import logging
import sys
logging.basicConfig(stream=sys.stdout,level=logging.INFO, format="[ %(asctime)s | %(filename)s | %(levelname)s ] %(message)s", datefmt="%d/%m/%Y %H:%M:%S")

# https://en.wikipedia.org/wiki/Inverse-Wishart_distribution
class NormalInverseWishartDistribution(object):
    def __init__(self, mu, lmbda, nu, psi):
        self.mu = mu
        self.lmbda = float(lmbda)
        self.nu = nu
        self.psi = psi
        self.inv_psi = np.linalg.inv(psi)

    def sample(self):
        sigma = np.linalg.inv(self.wishartrand())
        return (np.random.multivariate_normal(self.mu, sigma / self.lmbda), sigma)

    def wishartrand(self):
        dim = self.inv_psi.shape[0]
        chol = np.linalg.cholesky(self.inv_psi)
        foo = np.zeros((dim,dim))

        for i in range(dim):
            for j in range(i+1):
                if i == j:
                    foo[i,j] = np.sqrt(chi2.rvs(self.nu-(i+1)+1))
                else:
                    foo[i,j]  = np.random.normal(0,1)
        return np.dot(chol, np.dot(foo, np.dot(foo.T, chol.T)))

    def posterior(self, data):
        n = len(data)
        mean_data = np.mean(data, axis=0)
        sum_squares = np.sum([np.array(np.matrix(x - mean_data).T * np.matrix(x - mean_data)) for x in data], axis=0)
        mu_n = (self.lmbda * self.mu + n * mean_data) / (self.lmbda + n)
        lmbda_n = self.lmbda + n
        nu_n = self.nu + n
        psi_n = self.psi + sum_squares + self.lmbda * n / float(self.lmbda + n) * np.array(np.matrix(mean_data - self.mu).T * np.matrix(mean_data - self.mu))
        return NormalInverseWishartDistribution(mu_n, lmbda_n, nu_n, psi_n)

def DPGMM2(alpha, mu0, lmbda, Sigma0, nu, sources, K0, num_iterations, verbose=True, targets=None):
    """ Implementation of the DPGMM clustering by the Gibb sampling.
    
    Parameters
    ----------
    alpha: the concentration parameter
    mu0: the prior belief of the mean (np.array with shape [data_dim])
    lmbda: the belief-strength of the mean
    Sigma0: the prior belief of the covariance (np.array with shape [data_dim, data_dim])
    nu: the belief-strength of the covariance (degree of freedom)
    sources: the data (np.array with shape [num_data, data_dim])
    K0: the initial number of the clusters (can be any number)
    num_iterations: number of the iterations
    verbose: print verbose information or not
    targets: for evaluation
    
    Returns
    -------
    A dict of key-value:
        {'z': z, 'z_posterior': z_posterior, 'weights': weights, 'means': means, 'covs': covs, 'clusters': clusters}
    z: the sampled hidden cluster indicators of the last iteration (shape [num_data])
    z_posterior: the posterior of all the data (shape [num_data, num_clusters])
    weights: the sampled weights of the last iteration (shape [num_clusters])
    means: the sampled mean of the last iteration (list of np.array with length num_clusters) 
    covs: the sampled variance of the last iteration (list of np.array with length num_clusters) 
    clusters: the cluster index set of the last iteration
    
    Example
    -------
    import scipy
    from sklearn import cluster, datasets
    from itertools import cycle, islice

    n_samples = 1500
    blobs = datasets.make_blobs(n_samples=n_samples, random_state=8)
    sources, targets = blobs[0], blobs[1]

    D = sources.shape[1]
    alpha = 1 # concentrate parameter
    mu0 = np.mean(sources, axis = 0)
    lmbda = 1 # belief of the mean
    Sigma0 = np.cov(sources.T) # belief of the covariance
    nu = D + 3 # belief of variance or degree of freedom
    K0=10 # initial number of clusters
    num_iterations = 100
    verbose=True

    results = DPGMM2(alpha, mu0, lmbda, Sigma0, nu, sources, K0, num_iterations, verbose)
    # preds = results['z']
    preds = np.argmax(results['z_posterior'], axis=1)

    colors = np.array(list(islice(cycle(['#377eb8', '#ff7f00', '#4daf4a',
                                         '#f781bf', '#a65628', '#984ea3',
                                         '#999999', '#e41a1c', '#dede00']),
                                  int(max(preds) + 1))))
    plt.scatter(sources[:, 0], sources[:, 1], s=10, color=colors[preds])
    plt.show()
    """
    # randomly initilize the cluster indicator
    z = np.random.choice(K0, len(sources))
    niw_sampler = NormalInverseWishartDistribution(mu0, lmbda, nu, Sigma0)

    for iteration in range(num_iterations):
        # sample the weights
        clusters, counts = np.unique(z, return_counts=True) # counter
        # if verbose: print(f"iter: {iteration} - clusters: {clusters}")
        clusters = np.append(clusters, [clusters.max() + 1]) # 1,....,K, K+1 --- not empty clusters + possible new cluster
        counts = np.append(counts, [alpha]) # n_1,.., n_K, n_{K+1}
        weights = np.random.dirichlet(counts)

        # sample the mean and the covariance for each Gaussian cluster including the possible new K+1 one
        parameters = []
        for cluster in clusters[:-1]: # exclude the new K+1 cluster
            parameters.append(niw_sampler.posterior(sources[z==cluster]).sample())
        parameters.append(niw_sampler.sample()) # sample for the K+1 cluster
        means, covs = list(zip(*parameters))

        # sample z
        num_clusters = len(clusters) # number of not empty clusters and possible new one
        num_sources = len(sources)
        assert (len(clusters) == len(means) == len(covs) == len(weights))

        z_posterior = []
        for k in range(num_clusters):
            z_posterior.append((multivariate_normal.pdf(sources, mean=means[k], cov=covs[k]) * weights[k]).reshape(-1, 1))
        z_posterior = np.concatenate(z_posterior, axis=1)
        z_posterior = z_posterior / z_posterior.sum(axis=1).reshape(-1, 1)
        
        updated_z = []
        for i in range(num_sources):
            updated_z.append(np.random.choice(clusters, p=z_posterior[i]))

        # update z
        z = np.array(updated_z)

        # evaluation
        if targets is not None:
            preds = np.argmax(z_posterior, axis=1) # preds = z
            result = metrics.homogeneity_completeness_v_measure(targets, preds)
            #if verbose: logging.info('iter: {}, homo: {:.4f}, comp: {:.4f}, v_meas: {:.4f}, num_clusters: {}'.format(iteration, result[0], result[1], result[2], len(clusters)))
            if verbose: logging.info('iter: {}, num_clusters: {}, homo: {:.4f}, comp: {:.4f}, v_meas: {:.4f}'.format(iteration, len(clusters), result[0], result[1], result[2]))

    return  {'z': z, 'z_posterior': z_posterior, 'weights': weights, 'means': means, 'covs': covs, 'clusters': clusters}

def main():
    parser = argparse.ArgumentParser(description="DPGMM by gibbs clustering")
    parser.add_argument("--exp", type=str, required=False, default="timit")
    parser.add_argument("--source_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc")
    parser.add_argument("--target_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel")
    parser.add_argument("--seed", type=int, default=2020)
    parser.add_argument("--verbose", type=bool, default=True, help="print extra information or not")

    parser.add_argument("--num_iterations", type=int, default=100)
    parser.add_argument("--K0", type=int, default=10, help="init number of clusters")
    parser.add_argument("--alpha", type=float, default=1, help="the concentration parameter")
    parser.add_argument("--lmbda", type=float, default=1, help="the belief of mean")

    args = parser.parse_args()
    opts = vars(args)

    source_file = opts['source_file']
    target_file = opts['target_file']
    sources = np.loadtxt(source_file)
    targets = np.loadtxt(target_file, delimiter=',')
    assert targets.min() >= 0, "the class of index should be greater or equal to zero"
    
    np.random.seed(opts['seed'])
    K0 = opts['K0']              # initial number of clusters
    num_iterations = opts['num_iterations']
    verbose = opts['verbose']

    D = sources.shape[1]
    alpha = opts['alpha']
    mu0 = np.mean(sources, axis = 0)
    lmbda = opts['lmbda']
    Sigma0 = np.cov(sources.T) # belief of the covariance
    nu = D + 3                 # belief of covariance or degree of freedom

    DPGMM2(alpha, mu0, lmbda, Sigma0, nu, sources, K0, num_iterations, verbose, targets)

if __name__ == "__main__":
    main()
