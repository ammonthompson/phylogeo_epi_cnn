#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from statsmodels.nonparametric.smoothers_lowess import lowess
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.spatial import cKDTree
from scipy.interpolate import RegularGridInterpolator
from scipy.interpolate import interp1d
from scipy.interpolate import interp2d
from scipy.interpolate import LinearNDInterpolator
import copy
import cnn_utilities as cn
import tensorflow as tf

def make_output_files(coverage_dict, ci_dict, file_prefix):
    """
    Creates two output files from given coverage and confidence interval (CI) dictionaries.
    
    The function generates two dataframes, one for coverage and another for 95% CI. It saves these dataframes 
    as tab-separated value files (.tsv) with the given file prefix.
    
    Parameters:
    coverage_dict (dict): A dictionary containing coverage values.
    
    ci_dict (dict): A dictionary containing confidence interval values. It expects the keys to be confidence
                    levels and values to be 2D arrays for each parameter ("R0", "delta", "m").

    file_prefix (str): The prefix of the output .tsv files. The function will append "_coverage.tsv" and 
                       "_ci.tsv" to this prefix for the respective output files.

    Returns:
    None
    """
    
    df_caltest_coverage = pd.DataFrame(np.array([v for k, v in coverage_dict.items()]), 
                                            columns = ["R0", "sample_rate", "migration_rate"], 
                               index = ["5", "10", "25", "50", "75", "90", "95"])
    df_caltest_coverage.to_csv(file_prefix + "_coverage.tsv", sep = "\t", index = True)
    
    # write 95% quantiles to file
    R0_95_q = np.array((ci_dict[0.95][0][:,0], ci_dict[0.95][1][:,0])).transpose()
    delta_95_q = np.array((ci_dict[0.95][0][:,1], ci_dict[0.95][1][:,1])).transpose()
    m_95_q = np.array((ci_dict[0.95][0][:,2], ci_dict[0.95][1][:,2])).transpose()

    df_caltest_95q = pd.DataFrame(np.hstack((R0_95_q, delta_95_q, m_95_q)),
                             columns = ["R0_lq", "R0_uq", "delta_lq", "delta_uq", "m_lq", "m_uq"])
    df_caltest_95q.to_csv(file_prefix + "_ci.tsv", sep = "\t", index = False)

def plot_QI(preds_low, preds_up, labels, param_names = ["R0", "sample rate", "migration rate"], axis_labels = ["prediction", "truth"]):
    """
    Plots Quantile Intervals (QI) for given predictions and labels. 
    
    This function visualizes the true values and predicted confidence intervals for parameters on a plot. 
    The true values are represented by red dots, and the prediction intervals are represented by blue vertical lines.

    Parameters:
    preds_low (array-like): Lower bounds of the prediction intervals.
    preds_up (array-like): Upper bounds of the prediction intervals.
    labels (array-like): True values of the parameters to be plotted.
    param_names (list of str, optional): Names of the parameters, used for y-axis labels. Default is ["R0", "sample rate", "migration rate"].
    axis_labels (list of str, optional): Labels for the axes, with the default being ["prediction", "truth"].

    Returns:
    None

    Note: 
    It is assumed that inputs preds_low, preds_up and labels have the same shape.
    """
    
    labels = np.atleast_2d(labels).T
    preds_low = np.atleast_2d(preds_low).T
    preds_up = np.atleast_2d(preds_up).T

    for j in range(0, labels.shape[1]):
        plt.plot(labels[:,j], np.repeat(0, len(labels[:,j])), 'ro', label="True Values", markersize=1)
        plt.ylabel(param_names[j])
        for i in range(len(preds_low[:,j])):
            plt.vlines(labels[i,j], preds_low[i,j] - labels[i,j], preds_up[i,j] - labels[i,j], colors='b', alpha=0.5)
        plt.legend()
        plt.show()

    
    # get coverage statistics
def percentage_within_intervals(intervals, true_values):
    """
    Computes the percentage of true values that fall within the given intervals.

    This function iterates over the provided intervals and true_values and checks 
    if each true value falls within its corresponding interval. It returns the percentage 
    of true values that fall within their corresponding intervals.

    Parameters:
    intervals (list of tuples): A list where each element is a tuple representing an interval. 
                                Each tuple consists of two elements: the lower and upper bounds of the interval.
    true_values (list or array-like): A list or array-like object containing the true values to be checked.

    Returns:
    float: The percentage of true values that fall within their corresponding intervals.

    Raises:
    ValueError: If the lengths of intervals and true_values are not equal.
    """
    
    if len(intervals) != len(true_values):
        raise ValueError("Length of intervals and true_values must be equal")
    
    count = 0
    for i, (lower, upper) in enumerate(intervals):
        if lower <= true_values[i] <= upper:
            count += 1
            
    percentage = count / len(intervals) * 100
    return percentage


def make_cqr_coverage_set(q_dict, true):
    ''' 
    q_dict (dict): A dictionary where keys are quantiles and values are (2, 3) numpy arrays representing the lower and upper quantile estimations.
    true (array): The array of true values.
    Returns: cov_q (dict): A dictionary where keys are quantiles and values are coverage percentages.
    '''
    cov_q = {}
    for quantile, intervals in q_dict.items():
        # Extract the lower and upper interval predictions
        i_lower_q, i_upper_q = intervals[0], intervals[1]

        cov_q[quantile] = []
        for k in range(i_lower_q.shape[1]):
            i_ci = [(i_lower_q[j, k], i_upper_q[j, k]) for j in range(i_lower_q.shape[0])]
            cov_q[quantile] = np.append(cov_q[quantile], np.round(percentage_within_intervals(i_ci, true[:, k]), decimals = 2))
            print(f"Quantile {quantile}, parameter {k} finished: {cov_q[quantile][k]}")

    return cov_q

def get_CQR_constant(preds, true, inner_quantile=0.95, symmetric = True):
    #preds axis 0 is the lower and upper quants, axis 1 is the replicates, and axis 2 is the params
    
    """
    Computes Conformalized Quantile Regression (CQR) constants based on predictions and true values.

    This function calculates the CQR constants which are used to adjust the prediction intervals. 
    These constants depend on the non-conformity scores computed based on predictions and true values.

    Parameters:
    preds (array): A 3D array containing prediction intervals. The first axis (axis=0) represents 
                        the lower and upper quantiles, the second axis (axis=1) represents the replicates, 
                        and the third axis (axis=2) represents the parameters.
    true (array): An array containing the true values of the parameters.
    inner_quantile (float, optional): The desired level of confidence for the inner quantile. Default is 0.95.
    symmetric (bool, optional): Specifies the type of non-conformity score. If True, a symmetric 
                                 non-conformity score is calculated, else an asymmetric one. Default is True.

    Returns:
    array-like: An array containing the computed CQR constants. If symmetric is True, the array will be 
                one-dimensional, else it will be two-dimensional, with the first axis representing lower 
                and upper quantiles.

    Raises:
    ValueError: If the shapes of preds and true are not compatible.
    """
    
    # compute non-comformity scores
    Q = np.array([]) if symmetric else np.empty((2, preds.shape[2]))
    for i in range(preds.shape[2]):
        if symmetric:
            # Symmetric non-comformity score
            s = np.amax(np.array((preds[0][:,i] - true[:,i], true[:,i] - preds[1][:,i])), axis=0)
            # get adjustment constant: 1 - alpha/2's quintile of non-comformity scores
            Q = np.append(Q, np.quantile(s, inner_quantile * (1 + 1/preds.shape[1])))
        else:
            # Asymmetric non-comformity score
            lower_s = np.array(true[:,i] - preds[0][:,i])
            upper_s = np.array(true[:,i] - preds[1][:,i])
            # get (lower_q adjustment, upper_q adjustment)
            Q[:,i] = np.array((np.quantile(lower_s, (1 - inner_quantile)/2 * (1 + 1/preds.shape[1])),
                             np.quantile(upper_s, (1 + inner_quantile)/2 * (1 + 1/preds.shape[1]))))
            

    return Q
