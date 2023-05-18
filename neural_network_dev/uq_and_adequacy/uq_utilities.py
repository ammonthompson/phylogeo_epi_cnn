#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from statsmodels.nonparametric.smoothers_lowess import lowess
from scipy.interpolate import interp1d
import numpy as np
import matplotlib.pyplot as plt


    
    # get coverage statistics
def percentage_within_intervals(intervals, true_values):
    if len(intervals) != len(true_values):
        raise ValueError("Length of intervals and true_values must be equal")
    
    count = 0
    for i, (lower, upper) in enumerate(intervals):
        if lower <= true_values[i] <= upper:
            count += 1
            
    percentage = count / len(intervals) * 100
    return percentage


def make_coverage_set(x_train, y_train, x_test, y_test, quantiles = [0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95], q_fun = None):
    ''' x_train (array-like): The training data for input features.
        y_train (array-like): The training data for target labels.
        x_test (array-like): The test data for input features.
        y_test (array-like): The test data for target labels.
        quantiles (list, optional): A list of quantiles to compute coverage percentages. 
            Defaults to [0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95].
        q_fun (function or None, optional): A user-defined quantile function that returns the lower and upper 
            quantile estimations for a given quantile. If not provided, 
            the function will use fit_lowess_with_local_quantiles for estimating quantiles. Defaults to None.
        Returns: cov_q (list): A list of coverage percentages for each quantile specified in quantiles.
    '''
    cov_q = []
    for q in range(len(quantiles)):
        if q_fun is not None:
            f_lq, f_uq = q_fun[quantiles[q]]
        else:
            f_m, f_lq, f_uq = get_CPI(x_train, y_train, frac=0.1, inner_quantile=quantiles[q])
        i_lower_q = f_lq(x_test)
        i_upper_q = f_uq(x_test)
        i_ci = []
        for idx in range(0,len(x_test)):
            i_ci.append((i_lower_q[idx], i_upper_q[idx]))
            
        cov_q.append(percentage_within_intervals(i_ci, y_test))
        print(str(quantiles[q]) + " finished: " + str(cov_q[-1]))
    return cov_q


def get_CPI(x, y, frac=0.1, inner_quantile=0.95):
    # Fit using residuals around CNN predictions rather than LOWESS
    sorted_idx = np.argsort(x)
    #smoothed = lowess(y[sorted_idx], x[sorted_idx], frac=frac)
    
    xx = x[sorted_idx]
    yy = y[sorted_idx]
    
    lower_q = (1-inner_quantile)/2
    upper_q = 1 - lower_q
    local_lower_q = []  
    local_upper_q = []
    
    xvals = np.linspace(xx[0], xx[-1], 5000 )
    for i in xvals:
        # get frac total window
        window_indices = np.abs(xx - i) <= (frac * (xx[-1] - xx[0])) / 2
        window_x = xx[window_indices]
        window_y = yy[window_indices]
        residuals = window_y - window_x
        local_lower_q.append(i + np.array(np.quantile(residuals, lower_q)))
        local_upper_q.append(i + np.array(np.quantile(residuals, upper_q)))
        np.quantile
    local_lower_q = np.array(local_lower_q)
    local_upper_q = np.array(local_upper_q)

    # Create functions to interpolate the lowess fits for out-of-sample values
    smoothed_func = interp1d(xvals, xvals, kind='linear', fill_value='extrapolate')
    smoothed_lower_local_q = interp1d(xvals, local_lower_q, kind='linear', fill_value='extrapolate')
    smoothed_upper_local_q = interp1d(xvals, local_upper_q, kind='linear', fill_value='extrapolate')

    return smoothed_func, smoothed_lower_local_q, smoothed_upper_local_q
    
    
def plot_lowess_fit_quantile(x, y, mean_smooth_f, lower_q_smooth_f, upper_q_smooth_f):
    lspace = np.linspace(np.min(x), np.max(x), 100)
    mean = mean_smooth_f((lspace))
    lower_q = lower_q_smooth_f(lspace)
    upper_q = upper_q_smooth_f(lspace)
    plt.scatter(x, y, label="Data points", alpha=0.5, s=10)
    plt.plot(lspace, lspace, color = "yellow", label = "y = x")
    plt.plot(lspace, (mean), color="red", label="Local linear regression")
    plt.fill_between(
        lspace,
        lower_q,
        upper_q,
        color="red",
        alpha=0.25,
        label="inner q",
    )
    plt.xlabel("x")
    plt.ylabel("y")
    plt.legend()
    plt.show()

    
    
    
############    
# Not used #
############
def fit_lowess_with_local_quantiles(x, y, frac=0.1, inner_quantile=0.95):
    # Fit lowess to the data
    sorted_idx = np.argsort(x)
    smoothed = lowess(y[sorted_idx], x[sorted_idx], frac=1)
    
    xx = x[sorted_idx]
    yy = y[sorted_idx]
    
    lower_q = (1-inner_quantile)/2
    upper_q = 1 - lower_q
    local_lower_q = []  
    local_upper_q = []
    for i in range(len(x)):
        # Perform a local gaussian weighted linear regression on the local data sd
        window_indices = np.abs(xx - xx[i]) <= (frac * (xx[-1] - xx[0])) / 2
        window_x = xx[window_indices]
        window_y = yy[window_indices]
        residuals = window_y - smoothed[window_indices,1]
        local_lower_q.append(smoothed[i,1] + np.array(np.quantile(residuals, lower_q)))
        local_upper_q.append(smoothed[i,1] + np.array(np.quantile(residuals, upper_q)))
        np.quantile
    local_lower_q = np.array(local_lower_q)
    local_upper_q = np.array(local_upper_q)

    # Create functions to interpolate the lowess fits for out-of-sample values
    smoothed_func = interp1d(smoothed[:, 0], smoothed[:, 1], kind='linear', fill_value='extrapolate')
    smoothed_lower_local_q = interp1d(smoothed[:,0], local_lower_q, kind='linear', fill_value='extrapolate')
    smoothed_upper_local_q = interp1d(smoothed[:,0], local_upper_q, kind='linear', fill_value='extrapolate')

    return smoothed_func, smoothed_lower_local_q, smoothed_upper_local_q

def get_lowess_CI(meanx, local_std_dev, percent_CI = 50):
    alpha = 1 - (percent_CI / 100)
    z = sp.norm.ppf(1 - (alpha / 2))
    return [((meanx[x] - z * local_std_dev[x], meanx[x] + z * local_std_dev[x])) for x in range(len(meanx))]
   
