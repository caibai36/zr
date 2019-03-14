import numpy as np
import pandas as pd
import sys

def one_hot_repr_ind(index_vector, num_of_classes):
    """Convert an index vector to its one_of_k encoded one-hot representation.
    Args: 
        index_vector (np.ndarray): the given index vector
        num_of_classes (int): the number of classes

    Returns:
        one_hot (np.ndarray): the one-hot representation of the indexed vector.

    """
    one_hot = np.zeros((len(index_vector), num_of_classes))
    one_hot[np.arange(len(index_vector)), index_vector] = 1
    return one_hot

def one_hot_repr(a):

    """Convert an list to its one_of_k encoded one-hot representation.
    Args: 
        a (1D list or np.ndarray): the given array, the number of classes will be infered from the array.

    Returns:
        one_hot (np.ndarray): the one-hot representation of the array.
    
    egs:
    v = np.array([1, 1, 2, 1])
    l = ['c','a', 'a', 'b', 'bc']
    
    print(one_hot_repr(v))
    print(one_hot_repr(l))
    [[1. 0.]
    [1. 0.]
    [0. 1.]
    [1. 0.]]

    [[0. 0. 0. 1.]
    [1. 0. 0. 0.]
    [1. 0. 0. 0.]
    [0. 1. 0. 0.]
    [0. 0. 1. 0.]]

    Note:
    # The shape of the input should be one-dimension array.
    # inputs = np.array([[1],['ab']]).flatten()
    """

    # Create index vector for the array
    m = {}
    for index, elem in enumerate(sorted(set(a))):
        m[elem] = index
    index_vector = np.array([m[elem] for elem in a])
    num_of_classes = len(m)

    # From the index vector to the one-hot representation of the vector
    return one_hot_repr_ind(index_vector, num_of_classes)

def main():
    assert len(sys.argv) == 3, ("Usage: python one_hot.py input one_hot_repr_of_input")
    # v = np.array([1, 1, 2, 1])
    # l = ['c','a', 'a', 'b', 'bc']
    # sorted(set(v))
    # print(one_hot_repr(v))
    # print(one_hot_repr(l))
    
    inputs = pd.read_csv(sys.argv[1], sep='\s+', header=None, index_col=False)
    # DataFrame always return an array, may be with different types.
    one_hot = one_hot_repr(inputs.values.flatten())
    np.savetxt(sys.argv[2],one_hot, fmt="%d")

if __name__ == "__main__":
    main()
