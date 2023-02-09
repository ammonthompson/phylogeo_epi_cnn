#!/usr/bin/env python3

import sys
import numpy as np
import pandas as pd

#import phylodeep.sumstats as sumstats


from collections import Counter

import warnings
warnings.filterwarnings("ignore")

DISTANCE_TO_ROOT = "dist_to_root"

DEPTH = "depth"

HEIGHT = "height"

LADDER = "ladder"

VISITED = "visited"



new_leaf_order_names = []
newLeafKeys_inputNameValues = {}

# all branches of given tree will be rescaled to TARGET_AVG_BL
TARGET_AVG_BL = 1


# set high recursion limit
sys.setrecursionlimit(100000)


def add_dist_to_root(tre):
    """
    Add distance to root (dist_to_root) attribute to each node
    :param tre: ete3.Tree, tree on which the dist_to_root should be added
    :return: void, modifies the original tree
    """

    for node in tre.traverse("preorder"):
        if node.is_root():
            node.add_feature("dist_to_root", 0)
        elif node.is_leaf():
            node.add_feature("dist_to_root", getattr(node.up, "dist_to_root") + node.dist)
            # tips_dist.append(getattr(node.up, "dist_to_root") + node.dist)
        else:
            node.add_feature("dist_to_root", getattr(node.up, "dist_to_root") + node.dist)
            # int_nodes_dist.append(getattr(node.up, "dist_to_root") + node.dist)
    return None


def name_tree(tre):
    """
    Names all the tree nodes that are not named, with unique names.
    :param tre: ete3.Tree, the tree to be named
    :return: void, modifies the original tree
    """
    existing_names = Counter((_.name for _ in tre.traverse() if _.name))
    
    i = 0
    for node in tre.traverse('levelorder'):
        if(node.is_leaf()): # A.M.T
        	#new_leaf_order_names.append((i, node.name))
                newLeafKeys_inputNameValues[i] = node.name
        node.name = i
        i += 1
   
    return None


def rescale_tree(tre, target_avg_length):
    """
    Returns branch length metrics (all branches taken into account and external only)
    :param tre: ete3.Tree, tree on which these metrics are computed
    :param target_avg_length: float, the average branch length to which we want to rescale the tree
    :return: float, resc_factor
    """
    # branch lengths
    dist_all = [node.dist for node in tre.traverse("levelorder")]

    all_bl_mean = np.mean(dist_all)

    resc_factor = all_bl_mean/target_avg_length

    for node in tre.traverse():
        node.dist = node.dist/resc_factor

    return resc_factor

    


def encode_into_most_recent(tree_input, sampling_proba):
    """Rescales all trees from tree_file so that mean branch length is 1,
    then encodes them into full tree representation (most recent version)

    :param tree_input: ete3.Tree, that we will represent in the form of a vector
    :param sampling_proba: float, value between 0 and 1, presumed sampling probability value
    :return: pd.Dataframe, encoded rescaled input trees in the form of most recent, last column being
     the rescale factor
    """
    leaf_ordered_names = [] # A.M.T
  
    def real_polytomies(tre):
        """
        Replaces internal nodes of zero length with real polytomies.
        :param tre: ete3.Tree, the tree to be modified
        :return: void, modifies the original tree
        """
        for nod in tre.traverse("postorder"):
            if not nod.is_leaf() and not nod.is_root():
                if nod.dist == 0:
                    for child in nod.children:
                        nod.up.add_child(child)
                    nod.up.remove_child(nod)
        return

    def get_not_visited_anc(leaf):
        while getattr(leaf, "visited", 0) >= len(leaf.children)-1:
            leaf = leaf.up
            if leaf is None:
                break
        return leaf

    def get_deepest_not_visited_tip(anc):
        max_dist = -1
        tip = None
        for leaf in anc:
            if leaf.visited == 0:
                distance_leaf = getattr(leaf, "dist_to_root") - getattr(anc, "dist_to_root")
                if distance_leaf > max_dist:
                    max_dist = distance_leaf
                    tip = leaf
        leaf_ordered_names.append(getattr(tip, "name")) # A.M.T
        return tip

    def get_dist_to_root(anc):
        dist_to_root = getattr(anc, "dist_to_root")
        return dist_to_root

    def get_dist_to_anc(feuille, anc):
        dist_to_anc = getattr(feuille, "dist_to_root") - getattr(anc, "dist_to_root")
        return dist_to_anc

    def encode(anc):
        leaf = get_deepest_not_visited_tip(anc)
        new_leaf_order_names.append(leaf.name) # A.M.T.
        yield get_dist_to_anc(leaf, anc)
        leaf.visited += 1
        anc = get_not_visited_anc(leaf)

        if anc is None:
            return
        anc.visited += 1
        yield get_dist_to_root(anc)
        for _ in encode(anc):
            yield _

    def complete_coding(encoding, max_length):
        add_vect = np.repeat(0, max_length - len(encoding))
        add_vect = list(add_vect)
        encoding.extend(add_vect)
        return encoding

    def refactor_to_final_shape(result_v, sampling_p, maxl):
        def reshape_coor(max_length):
            tips_coor = np.arange(0, max_length, 2)
            tips_coor = np.insert(tips_coor, -1, max_length + 1)

            int_nodes_coor = np.arange(1, max_length - 1, 2)
            int_nodes_coor = np.insert(int_nodes_coor, 0, max_length)
            int_nodes_coor = np.insert(int_nodes_coor, -1, max_length + 2)

            order_coor = np.append(int_nodes_coor, tips_coor)

            return order_coor
       
        reshape_coordinates = reshape_coor(maxl)

        # add sampling probability:
        if maxl == 999:
            result_v.loc[:, 1000] = 0
            result_v['1001'] = sampling_p
            result_v['1002'] = sampling_p
        else:
            result_v.loc[:, 400] = 0
            result_v['401'] = sampling_p
            result_v['402'] = sampling_p

        # reorder the columns        
        result_v = result_v.iloc[:,reshape_coordinates]

        return result_v

    # local copy of input tree
    tree = tree_input.copy()
    
    #if len(tree) < 200:
    #    max_len = 399
    #else:
    #    max_len = 999
    max_len = 999

    # remove the edge above root if there is one
    if len(tree.children) < 2:
        tree = tree.children[0]
        tree.detach()

    # set to real polytomy
    real_polytomies(tree)

    # rescale branch lengths
    rescale_factor = rescale_tree(tree, target_avg_length=TARGET_AVG_BL)

    # set all nodes to non visited:
    for node in tree.traverse():
        setattr(node, "visited", 0)

    name_tree(tree)
    
    add_dist_to_root(tree)

    tree_embedding = list(encode(tree))
    
    tree_embedding = complete_coding(tree_embedding, max_len)
   
    result = pd.DataFrame(tree_embedding, columns=[0])

    result = result.T
 
    result = refactor_to_final_shape(result, sampling_proba, max_len)

    return result, rescale_factor, new_leaf_order_names, newLeafKeys_inputNameValues
