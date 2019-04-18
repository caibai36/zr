import numpy as np
import pandas as pd
from scipy.stats import t

class NumpyRNGContext:
    """
    A context manager (for use with the ``with`` statement) that will seed the
    numpy random number generator (RNG) to a specific value, and then restore
    the RNG state back to whatever it was before.

    This is primarily intended for use in the astropy testing suit, but it
    may be useful in ensuring reproducibility of Monte Carlo simulations in a
    science context.

    Parameters
    ----------
    seed : int
        The value to use to seed the numpy RNG

    Examples
    --------
    A typical use case might be::

        with NumpyRNGContext(<some seed value you pick>):
            from numpy import random

            randarr = random.randn(100)
            ... run your test using `randarr` ...

        #Any code using numpy.random at this indent level will act just as it
        #would have if it had been before the with statement - e.g. whatever
        #the default seed is.

        
    # From: http://docs.astropy.org/en/stable/_modules/astropy/utils/misc.html#NumpyRNGContext
    """

    def __init__(self, seed):
        self.seed = seed

    def __enter__(self):
        from numpy import random

        self.startstate = random.get_state()
        random.seed(self.seed)

    def __exit__(self, exc_type, exc_value, traceback):
        from numpy import random

        random.set_state(self.startstate)

def bootstrap(data, bootnum=100, samples=None, bootfunc=None, *args, **kwargs):
    """
    Performs bootstrap resampling on numpy arrays.

    Bootstrap resampling is used to understand confidence intervals of sample
    estimates. This function returns versions of the dataset resampled with
    replacement ("case bootstrapping"). These can all be run through a function
    or statistic to produce a distribution of values which can then be used to
    find the confidence intervals.

    Parameters
    ----------
    data : numpy.ndarray
        N-D array. The bootstrap resampling will be performed on the first
        index, so the first index should access the relevant information
        to be bootstrapped.
    bootnum : int, optional
        Number of bootstrap resamples
    samples : int, optional
        Number of samples in each resample. The default `None` sets samples to
        the number of datapoints
    bootfunc : function, optional
        Function to reduce the resampled data. Each bootstrap resample will
        be put through this function and the results returned. If `None`, the
        bootstrapped data will be returned
    *args, **kwargs: parameters for the boot function

    Returns
    -------
    boot : numpy.ndarray

        If bootfunc is None, then each row is a bootstrap resample of the data.
        If bootfunc is specified, then the columns will correspond to the
        outputs of bootfunc.

    Examples
    --------
    Obtain a twice resampled array:

    >>> from astropy.stats import bootstrap
    >>> import numpy as np
    >>> from astropy.utils import NumpyRNGContext
    >>> bootarr = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
    >>> with NumpyRNGContext(1):
    ...     bootresult = bootstrap(bootarr, 2)
    ...
    >>> bootresult  # doctest: +FLOAT_CMP
    array([[6., 9., 0., 6., 1., 1., 2., 8., 7., 0.],
           [3., 5., 6., 3., 5., 3., 5., 8., 8., 0.]])
    >>> bootresult.shape
    (2, 10)

    Obtain a statistic on the array

    >>> with NumpyRNGContext(1):
    ...     bootresult = bootstrap(bootarr, 2, bootfunc=np.mean)
    ...
    >>> bootresult  # doctest: +FLOAT_CMP
    array([4. , 4.6])

    Obtain a statistic with two outputs on the array

    >>> test_statistic = lambda x: (np.sum(x), np.mean(x))
    >>> with NumpyRNGContext(1):
    ...     bootresult = bootstrap(bootarr, 3, bootfunc=test_statistic)
    >>> bootresult  # doctest: +FLOAT_CMP
    array([[40. ,  4. ],
           [46. ,  4.6],
           [35. ,  3.5]])
    >>> bootresult.shape
    (3, 2)

    Obtain a statistic with two outputs on the array, keeping only the first
    output

    >>> bootfunc = lambda x:test_statistic(x)[0]
    >>> with NumpyRNGContext(1):
    ...     bootresult = bootstrap(bootarr, 3, bootfunc=bootfunc)
    ...
    >>> bootresult  # doctest: +FLOAT_CMP
    array([40., 46., 35.])
    >>> bootresult.shape
    (3,)
    
    with NumpyRNGContext(2):
        boot_result = bootstrap(np.array([[1,1], [2, 2], [3, 3]]), bootnum=2)
        print(boot_result)
    with NumpyRNGContext(2):
        boot_result = bootstrap(np.array([[1,1], [2, 2], [3, 3]]), bootnum=2, bootfunc=np.mean)
        print(boot_result)
    with NumpyRNGContext(2):
        boot_result = bootstrap(np.array([[1,1], [2, 2], [3, 3]]), bootnum=2, bootfunc=np.mean, axis=0)
        print(boot_result)

    # [[[1. 1.]
    #   [2. 2.]
    #   [1. 1.]]

    #  [[3. 3.]
    #   [3. 3.]
    #   [1. 1.]]]
    # [1.33333333 2.33333333]
    # [[1.33333333 1.33333333]
    #  [2.33333333 2.33333333]]
    
    # Modified from http://docs.astropy.org/en/stable/_modules/astropy/stats/funcs.html#bootstrap
    """
    if samples is None:
        samples = data.shape[0]

    # make sure the input is sane
    if samples < 1 or bootnum < 1:
        raise ValueError("neither 'samples' nor 'bootnum' can be less than 1.")

    if bootfunc is None:
        resultdims = (bootnum,) + (samples,) + data.shape[1:]
    else:
        # test number of outputs from bootfunc, avoid single outputs which are
        # array-like
        try:
            resultdims = (bootnum, len(bootfunc(data, *args, **kwargs)))
        except TypeError:
            resultdims = (bootnum,)

    # create empty boot array
    boot = np.empty(resultdims)

    for i in range(bootnum):
        bootarr = np.random.randint(low=0, high=data.shape[0], size=samples)
        if bootfunc is None:
            boot[i] = data[bootarr]
        else:
            boot[i] = bootfunc(data[bootarr], *args, **kwargs)

    return boot

with NumpyRNGContext(2):
    boot_result = bootstrap(np.array([[1,1], [2, 2], [3, 3]]), bootnum=2)
    print(boot_result)
with NumpyRNGContext(2):
    boot_result = bootstrap(np.array([[1,1], [2, 2], [3, 3]]), bootnum=2, bootfunc=np.mean)
    #print(boot_result)
with NumpyRNGContext(2):
    boot_result = bootstrap(np.array([[1,1], [2, 2], [3, 3]]), bootnum=2, bootfunc=np.mean, axis=0)
    print(boot_result)
    
def df_bootstrap(data, bootnum=100, samples=None, bootfunc=None, *args, **kwargs):
    """bootfunc input an array with shape (N, D), output an array with shape (D, )
    
       eg.
       df=pd.DataFrame(np.array([[1,1], [2, 2], [3, 3]]), columns=["first", "second"])
        print(df)
        with NumpyRNGContext(2):
            print(df_bootstrap(df, bootnum=2, bootfunc=np.mean, axis=0))
        #    first  second
        # 0      1       1
        # 1      2       2
        # 2      3       3
        # [[[1. 1.]
        #   [2. 2.]
        #   [1. 1.]]

        # [[3. 3.]
        #  [3. 3.]
        #  [1. 1.]]]
        # 
        #       first    second
        # 0  1.333333  1.333333
        # 1  2.333333  2.333333
       """
    data_values = bootstrap(data.values, bootnum, samples, bootfunc, *args, **kwargs)
    return pd.DataFrame(data_values, columns=data.columns)

df=pd.DataFrame(np.array([[1,1], [2, 2], [3, 3]]), columns=["first", "second"])
print(df)
with NumpyRNGContext(2):
    print(df_bootstrap(df, bootnum=2, bootfunc=np.mean, axis=0))
    
import numpy as np
from scipy.stats import t

v1 = np.array([9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19])
v2 = np.array([7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9])

def two_sample_t_test_unpaired(v1, v2, alpha=0.05, alternative=None):
    """
    v1 = np.array([9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19])
    v2 = np.array([7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9])
    print(two_sample_t_test_unpaired(v1, v2))
    print(two_sample_t_test_unpaired(v1, v2, alternative="greater"))
    # In R
    # v1=c(9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19)
    # v2=c(7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9)
    # ## A two sample Welch t-test
    # t.test(v1, v2)

    # # 	Welch Two Sample t-test

    # # data:  v1 and v2
    # # t = 3.0091, df = 15.993, p-value = 0.008323
    # # alternative hypothesis: true difference in means is not equal to 0
    # # 95 percent confidence interval:
    # #  0.5922804 3.4166085
    # # sample estimates:
    # # mean of x mean of y 
    # # 10.297778  8.293333 

    # v1=c(9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19)
    # v2=c(7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9)
    # ## A two sample Welch t-test
    # t.test(v1, v2, alternative = "greater")

    # # 	Welch Two Sample t-test

    # # data:  v1 and v2
    # # t = 3.0091, df = 15.993, p-value = 0.004161
    # # alternative hypothesis: true difference in means is greater than 0
    # # 95 percent confidence interval:
    # #  0.8414436       Inf
    # # sample estimates:
    # # mean of x mean of y 
    # # 10.297778  8.293333 
    """ 
    assert len(v1.shape) == 1 and len(v2.shape) == 1, "only support the one dimension numpy array"
    assert alternative == None or alternative == "greater", "alternative have to be empty or greater"
    
    result = {}
    if not alternative:
        result['title'] = "Welch Two sample t-test (unpaired, two tailed)"
    else:
        result['title'] = "Welch Two sample t-test (unpaired, one tailed)"
    
    if not alternative:
        result['hypothesis'] = "true difference in means is not equal to 0"
    else:
        result['hypothesis'] = "true difference in means is greater 0"

    n1 = len(v1)
    n2 = len(v2)
    
    # distance_mean
    data_distance = v1.mean() - v2.mean()
    result['mean_v1'] = v1.mean() 
    result['mean_v2'] = v2.mean()
    
    # distance_variance
    std1 = v1.std(ddof=1)  # make std of numpy same as sd in R, normalized by n - 1
    std2 = v2.std(ddof=1)
    mean_var1 = pow(std1, 2) / n1
    mean_var2 = pow(std2, 2) / n2
    pooled_variance = mean_var1 +  mean_var2
    
    # t_quantile
    degrees_of_freedom = pow(pooled_variance, 2) / ((pow(mean_var1, 2) / (n1 - 1) + pow(mean_var2, 2) / (n2 - 1)))
    result['df'] = degrees_of_freedom

    # Confidence interval
    t_quantile = t.ppf(1 - alpha / 2, degrees_of_freedom)
    lower = data_distance - t_quantile * np.sqrt(pooled_variance)
    upper = data_distance + t_quantile * np.sqrt(pooled_variance)
    # Confidence interval for alternative "greater"
    if alternative:
        t_quantile = t.ppf(1 - alpha, degrees_of_freedom)
        lower = data_distance - t_quantile * np.sqrt(pooled_variance)
        upper = np.inf
    result['ci_lower'] = lower 
    result['ci_upper'] = upper

    
    
    # p-value
    t_stat = data_distance / np.sqrt(pooled_variance)
    result['t'] = t_stat
    p_value = (1 - t.cdf(t_stat, degrees_of_freedom)) * 2
    # p-value for alternative "greater"
    if alternative == "greater": 
        p_value /= 2 
    result['p-value'] = p_value

    return result

print(two_sample_t_test_unpaired(v1, v2))
print(two_sample_t_test_unpaired(v1, v2, alternative="greater"))

import numpy as np
from scipy.stats import t

v1 = np.array([9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19])
v2 = np.array([7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9])

def two_sample_t_test_paired(v1, v2, alpha=0.05, alternative=None):
    """
    v1 = np.array([9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19])
    v2 = np.array([7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9])
    print(two_sample_t_test_paired(v1, v2))
    print(two_sample_t_test_paired(v1, v2, alternative="greater"))
    
    # v1=c(9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19)
    # v2=c(7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9)
    # ## A two sample Welch t-test
    # t.test(v1, v2, paired=TRUE)

    # # 	Paired t-test

    # # data:  v1 and v2
    # # t = 2.8712, df = 8, p-value = 0.02079
    # # alternative hypothesis: true difference in means is not equal to 0
    # # 95 percent confidence interval:
    # #  0.3945477 3.6143412
    # # sample estimates:
    # # mean of the differences 
    # #                2.004444 

    # v1=c(9.21, 11.51, 12.79, 11.85, 9.97, 8.79, 9.69, 9.68, 9.19)
    # v2=c(7.53, 7.48, 8.08, 8.09, 10.15, 8.4, 10.88, 6.13, 7.9)
    # ## A two sample Welch t-test
    # t.test(v1, v2, paired=TRUE, alternative="greater")

    # # 	Paired t-test

    # # data:  v1 and v2
    # # t = 2.8712, df = 8, p-value = 0.0104
    # # alternative hypothesis: true difference in means is greater than 0
    # # 95 percent confidence interval:
    # #  0.7062332       Inf
    # # sample estimates:
    # # mean of the differences 
    # #                2.004444 
    """
    assert len(v1.shape) == 1 and len(v2.shape) == 1, "only support the one dimension numpy array"
    assert alternative == None or alternative == "greater", "alternative have to be empty or greater"
    assert len(v1) == len(v2), "We are using paired T-test, the number of samples are same"
    
    result = {}
    if not alternative:
        result['title'] = "Paired t-test (two tailed)"
    else:
        result['title'] = "Paired t-test (one tailed)"
    
    if not alternative:
        result['hypothesis'] = "true difference in means is not equal to 0"
    else:
        result['hypothesis'] = "true difference in means is greater 0"

    n = len(v1)
    
    # distance_mean
    data_distance = (v1 - v2).mean()
    result['mean_diff'] = data_distance

    # distance_variance
    mean_variance = pow((v1 - v2).std(ddof=1), 2) / n
    
    # Create confidence surrounding data, we need t_quantile
    degrees_of_freedom = n - 1
    result['df'] = degrees_of_freedom
    
    # Confidence interval
    t_quantile = t.ppf(1 - alpha / 2, df = degrees_of_freedom)
    lower = data_distance - t_quantile * np.sqrt(mean_variance)
    upper = data_distance + t_quantile * np.sqrt(mean_variance)
    if alternative:
        t_quantile = t.ppf(1 - alpha, degrees_of_freedom)
        lower = data_distance - t_quantile * np.sqrt(mean_variance)
        upper = np.inf
    result['ci_lower'] = lower 
    result['ci_upper'] = upper
    
    # p-value
    t_stat = data_distance / np.sqrt(mean_variance)
    result['t'] = t_stat
    p_value = (1 - t.cdf(t_stat, df = degrees_of_freedom)) * 2
    # p-value for alternative "greater"
    if alternative == "greater": 
        p_value /= 2 
    result['p-value'] = p_value

    return result

print(two_sample_t_test_paired(v1, v2))
print(two_sample_t_test_paired(v1, v2, alternative="greater"))