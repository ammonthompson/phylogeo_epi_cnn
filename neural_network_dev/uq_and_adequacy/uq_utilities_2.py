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
    # Ensure labels, preds_low, and preds_up are at least two-dimensional
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

def plot_multi_QI(preds_low, preds_up, labels, param_names = ["R0", "sample rate", "migration rate"], axis_labels = ["prediction", "truth"]):
    for j in range(0, len(param_names)):
        plt.plot(labels[:,j], np.repeat(0, len(labels[:,j])), 'ro', label="True Values", markersize=1)
        plt.ylabel(param_names[j])
        for i in range(len(preds_low[:,j])):
            plt.vlines(labels[i,j], preds_low[i,j] - labels[i,j], preds_up[i,j] - labels[i,j], colors='b', alpha=0.5)
        plt.legend()
        plt.show()
        

    
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


def make_cqr_coverage_set(q_dict, true):
    ''' 
        q_dict (dict): A dictionary where keys are quantiles and values are (2, N, 3) numpy arrays representing the lower and upper quantile estimations.
        true (array-like): The array of true values.
        Returns: cov_q (dict): A dictionary where keys are quantiles and values are coverage percentages.
    '''
    cov_q = {}
    for quantile, intervals in q_dict.items():
        # Extract the lower and upper interval predictions
        i_lower_q, i_upper_q = intervals[0], intervals[1]

        cov_q[quantile] = []
        for k in range(i_lower_q.shape[1]):
            i_ci = [(i_lower_q[j, k], i_upper_q[j, k]) for j in range(i_lower_q.shape[0])]
#             cov_q[quantile][k] = np.round(percentage_within_intervals(i_ci, true[:, k]), decimals = 2)
            cov_q[quantile] = np.append(cov_q[quantile], np.round(percentage_within_intervals(i_ci, true[:, k]), decimals = 2))
            print(f"Quantile {quantile}, parameter {k} finished: {cov_q[quantile][k]}")

    return cov_q


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

    

def get_CQR_constant(preds, true, inner_quantile=0.95, symmetric = True):
    #preds axis 0 is the lower and upper quants, axis 1 is the replicates, and axis 2 is the params
 
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




def get_CPI(x, y, frac=0.1, inner_quantile=0.95, grid_points = 20):
    # Fit using residuals around CNN predictions
    
    data_stats_rel_weights = [1., 1.]
    
    # scale and shift columns 1 and 2 to have same spread as column 0
    min_x0 = np.min(x[:,0])
    max_x0 = np.max(x[:,0])
    min_x1 = np.min(x[:,1])
    max_x1 = np.max(x[:,1])
    min_x2 = np.min(x[:,2])
    max_x2 = np.max(x[:,2])
    x[:,1] = min_x0 + (x[:,1] - min_x1)/(max_x1 - min_x1) * (max_x0 - min_x0) * data_stats_rel_weights[0]
    x[:,2] = min_x0 + (x[:,2] - min_x2)/(max_x2 - min_x2) * (max_x0 - min_x0) * data_stats_rel_weights[1]
    
    sorted_idx = np.lexsort((x[:,2], x[:,1], x[:,0]))  # Sort by multiple columns
    xx = x[sorted_idx,:]
    yy = y[sorted_idx]
    
    lower_q = (1-inner_quantile)/2
    upper_q = 1 - lower_q
    tree = cKDTree(xx, balanced_tree = False)

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
                
                # keep only close to prediction point[0]
                residuals = residuals[np.where(np.abs(residuals) < 3 * np.std(residuals))]
                nr = len(residuals)
                rlq = lower_q * (1+nr)/nr if (lower_q * (1+nr)/nr) < 1. else 1.
                ruq = upper_q * (1+nr)/nr if (upper_q * (1+nr)/nr) < 1. else 1.
                local_lower_q[i, j, k] = point[0] + np.quantile(residuals, rlq)
                local_upper_q[i, j, k] = point[0] + np.quantile(residuals, ruq)
                
                
    # Create functions to interpolate the fits for out-of-sample values
    smoothed_lower_local_q = RegularGridInterpolator((xvals[0], xvals[1], xvals[2]), 
                                                     local_lower_q, method='linear', bounds_error=False, fill_value=None)
    smoothed_upper_local_q = RegularGridInterpolator((xvals[0], xvals[1], xvals[2]), 
                                                     local_upper_q, method='linear', bounds_error=False, fill_value=None)
        
    # output functions for exponentiating, rescaling and interpolation
    def scaled_lq(a):
        a[:,1] = min_x0 + (a[:,1] - min_x1)/(max_x1 - min_x1) * (max_x0 - min_x0) * data_stats_rel_weights[0]
        a[:,2] = min_x0 + (a[:,2] - min_x2)/(max_x2 - min_x2) * (max_x0 - min_x0) * data_stats_rel_weights[1]
        return np.exp(smoothed_lower_local_q(a))
    def scaled_uq(a):
        a[:,1] = min_x0 + (a[:,1] - min_x1)/(max_x1 - min_x1) * (max_x0 - min_x0) * data_stats_rel_weights[0]
        a[:,2] = min_x0 + (a[:,2] - min_x2)/(max_x2 - min_x2) * (max_x0 - min_x0) * data_stats_rel_weights[1]
        return np.exp(smoothed_upper_local_q(a))
    
    return None, scaled_lq, scaled_uq


def get_conditional_CQR_fun(preds, true, inner_quantile=0.95, num_pts = 10):
    #preds axis 0 is the lower and upper quants, axis 1 is the replicates, and axis 2 is the params
    # doesnt work and I'm tired of trying to make it work
 
    # num nearest neighbors
    num_neighbors = preds.shape[1]//num_pts
    print(num_neighbors)
    # compute non-comformity scores
    Q_low_fun = []
    Q_high_fun = []
    for i in range(preds.shape[2]):
       
        low_grid_pts = np.linspace(np.min(preds[0][:,i]), np.max(preds[0][:,i]), num_pts)
        high_grid_pts = np.linspace(np.min(preds[1][:,i]), np.max(preds[1][:,i]), num_pts)
        
        # loop over 10 grid points
        local_lower_q = []
        local_upper_q = []
        for pt_idx in range(num_pts):
            lower_dif = np.abs(preds[0,:,i] - low_grid_pts[pt_idx])
            upper_dif = np.abs(preds[1,:,i] - high_grid_pts[pt_idx])
            
            # get k nearest neighbors for the lower and upper separately
#             window_low_idx = np.argpartition(lower_dif, num_neighbors)[:num_neighbors]
#             window_high_idx = np.argpartition(upper_dif, num_neighbors)[:num_neighbors]
            
            low_t = np.quantile(lower_dif, num_neighbors/preds.shape[1])
            up_t = np.quantile(upper_dif, num_neighbors/preds.shape[1])
            window_lower_idx = np.where(lower_dif <= low_t)
            window_upper_idx = np.where(upper_dif <= up_t)
            
            
            # Asymmetric non-comformity score
            lower_s = np.array(true[window_lower_idx,i] - preds[0,window_lower_idx,i])
            upper_s = np.array(true[window_upper_idx,i] - preds[1,window_upper_idx,i])
            
            # get (lower_q adjustment, upper_q adjustment)
            lower_Q = np.array(np.quantile(lower_s, (1 - inner_quantile)/2 * (1 + 1/num_neighbors)))
            upper_Q = np.array(np.quantile(upper_s, (1 + inner_quantile)/2 * (1 + 1/num_neighbors)))
            
#             print("quantile: " + str(inner_quantile) + "   lower: " + str(lower_Q) + "   upper: " + str(upper_Q))
            
            # add local adjusted quantile at grid point to quantile arrays
            local_lower_q.append(low_grid_pts[pt_idx] + lower_Q)
            local_upper_q.append(high_grid_pts[pt_idx] + upper_Q)
            
        Q_low_fun.append(interp1d(low_grid_pts, local_lower_q, kind='linear', fill_value='extrapolate'))
        Q_high_fun.append(interp1d(high_grid_pts, local_upper_q, kind='linear', fill_value='extrapolate'))
        print(" ")

    return np.array((Q_low_fun, Q_high_fun))


from scipy.spatial.distance import euclidean

def get_adaptive_CQR_fun(preds, true, num_neighbors=10000, num_grid_points = 20, inner_quantile=0.95):
    # preds axis 0 is the lower and upper quants, axis 1 is the replicates, and axis 2 is the params
    parms = ["R0", "delta", "m"]
    
    # initialize dictionaries to hold interpolation functions
    interp_lower = {}
    interp_upper = {}

    for i in range(preds.shape[2]):  # loop over parameters
        
        # initialize KDTree
        tree = cKDTree(preds[:,:,i].T)

        # create 2D grid
        grid_points_lower = np.linspace(0.9*np.min(preds[0,:,i]), 1.1*np.max(preds[0,:,i]), num_grid_points)
        grid_points_upper = np.linspace(0.9*np.min(preds[1,:,i]), 1.1*np.max(preds[1,:,i]), num_grid_points)

        grid_points = []
        for lower in grid_points_lower:
            for upper in grid_points_upper:
                if lower < upper:  # ensure lower is less than upper
                    grid_points.append((lower, upper))

        # convert to numpy array for easier indexing
        grid_points = np.array(grid_points)

        
        # initialize arrays to hold adjusted quantiles
        num_valid_grid_points = len(grid_points)
        adj_lower = np.empty(num_valid_grid_points)
        adj_upper = np.empty(num_valid_grid_points)

        for j, (grid_point_lower, grid_point_upper) in enumerate(grid_points):
            # find the indices of the nearest points that fall into the current grid
            grid_indices = tree.query([grid_point_lower, grid_point_upper], k=num_neighbors)[1]

            # compute non-conformity scores for points in the grid
            s = np.amax(np.array((preds[0][grid_indices, i] - true[grid_indices, i], 
                                  true[grid_indices, i] - preds[1][grid_indices, i])), axis=0)
            
            # get 1 - alpha/2's quintile of non-conformity scores
            Q = np.quantile(s, inner_quantile * (1 + 1/num_neighbors))
            
            # adjust quantiles
            adj_lower[j] = grid_point_lower - Q
            adj_upper[j] = grid_point_upper + Q

        # create 2D interpolation functions
        interp_lower[parms[i]] = LinearNDInterpolator(grid_points, adj_lower, fill_value = 1)
        interp_upper[parms[i]] = LinearNDInterpolator(grid_points, adj_upper, fill_value = 1)

    return interp_lower, interp_upper


