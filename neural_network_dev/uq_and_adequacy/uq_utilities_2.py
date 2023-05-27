#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from statsmodels.nonparametric.smoothers_lowess import lowess
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import KDTree
from scipy.interpolate import RegularGridInterpolator
from scipy.interpolate import interp1d
import copy

    
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
        f_lq, f_uq = q_fun[quantiles[q]] 

        xx_low = copy.deepcopy(x_test)
        xx_high = copy.deepcopy(x_test)
        i_lower_q = f_lq(xx_low)
        i_upper_q = f_uq(xx_high)
        
        i_ci = []
        for idx in range(0,len(x_test[:,0])):
            i_ci.append((i_lower_q[idx], i_upper_q[idx]))
        cov_q.append(percentage_within_intervals(i_ci, y_test))
        print(str(quantiles[q]) + " finished: " + str(cov_q[-1]))
    return cov_q

def get_CPI(x, y, frac=0.1, inner_quantile=0.95):
    # Fit using residuals around CNN predictions
    
    # scale and shift columns 1 and 2 to have same spread as column 0
    min_x0 = np.min(x[:,0])
    max_x0 = np.max(x[:,0])
    min_x1 = np.min(x[:,1])
    max_x1 = np.max(x[:,1])
    min_x2 = np.min(x[:,2])
    max_x2 = np.max(x[:,2])
    x[:,1] = min_x0 + (x[:,1] - min_x1)/(max_x1 - min_x1) * (max_x0 - min_x0)
    x[:,2] = min_x0 + (x[:,2] - min_x2)/(max_x2 - min_x2) * (max_x0 - min_x0)
    
    sorted_idx = np.lexsort((x[:,2], x[:,1], x[:,0]))  # Sort by multiple columns
    xx = x[sorted_idx,:]
    yy = y[sorted_idx]
    
    lower_q = (1-inner_quantile)/2
    upper_q = 1 - lower_q
    tree = KDTree(xx)

    grid_points = 40 
    xvals = [np.linspace(np.min(xx[:, i]), np.max(xx[:, i]), grid_points) for i in range(3)]
    local_lower_q = np.empty((grid_points, grid_points, grid_points))  
    local_upper_q = np.empty((grid_points, grid_points, grid_points))

    num_frac = int(round(frac * xx.shape[0]))
    
    for i in range(grid_points):
        for j in range(grid_points):
            for k in range(grid_points):
                point = [xvals[0][i], xvals[1][j], xvals[2][k]]
                
                dist, indices = tree.query(point, num_frac)
                window_x = xx[indices, :]
                window_y = yy[indices]
                residuals = window_y - window_x[:, 0]  # Assuming y is 1-D
                local_lower_q[i, j, k] = point[0] + np.quantile(residuals, lower_q)
                local_upper_q[i, j, k] = point[0] + np.quantile(residuals, upper_q)
                
    # Create functions to interpolate the fits for out-of-sample values
    smoothed_lower_local_q = RegularGridInterpolator((xvals[0], xvals[1], xvals[2]), 
                                                     local_lower_q, method='linear', bounds_error=False, fill_value=None)
    smoothed_upper_local_q = RegularGridInterpolator((xvals[0], xvals[1], xvals[2]), 
                                                     local_upper_q, method='linear', bounds_error=False, fill_value=None)
        
    # output functions for exponentiating, rescaling and interpolation
    def scaled_lq(a):
        a[:,1] = min_x0 + (a[:,1] - min_x1)/(max_x1 - min_x1) * (max_x0 - min_x0)
        a[:,2] = min_x0 + (a[:,2] - min_x2)/(max_x2 - min_x2) * (max_x0 - min_x0)
        return np.exp(smoothed_lower_local_q(a))
    def scaled_uq(a):
        a[:,1] = min_x0 + (a[:,1] - min_x1)/(max_x1 - min_x1) * (max_x0 - min_x0)
        a[:,2] = min_x0 + (a[:,2] - min_x2)/(max_x2 - min_x2) * (max_x0 - min_x0)
        return np.exp(smoothed_upper_local_q(a))
    
    return None, scaled_lq, scaled_uq


    
 