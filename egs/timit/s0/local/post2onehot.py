# import numpy as np
# import torch
# import argparse
# import sys

# def labelseq2onehot(seq: torch.LongTensor, num_classes: int = None) -> torch.LongTensor:
#     """
#     Arguments
#     ---------
#     seq: shape (seq_length,)

#     Examples
#     --------
#     In [361]: seq2onehot(torch.Tensor([1, 2, 1]).long())
#     Out[361]:
#     tensor([[0., 1., 0.],
#             [0., 0., 1.],
#             [0., 1., 0.]])
#     -------
#     """
#     assert seq.min() >= 0, "the class of index should be greater or equal to zero"
#     if num_classes:
#         assert num_classes >= seq.max() + 1, "number of class too small"
#     else:
#         num_classes = seq.max() + 1 # We index the classes from 0

#     seq_length = len(seq)
#     onehot = torch.zeros(seq_length, num_classes)
#     onehot[range(seq_length), seq] = 1
#     return onehot

# def onehot2labelseq(onehot: torch.LongTensor) -> torch.LongTensor:
#     """
#     Arguments
#     ---------
#     onehot: shape (seq_length, num_classes)

#     Examples
#     --------
#     In [366]: onehot
#     Out[366]:
#     tensor([[0., 1., 0.],
#             [0., 0., 1.],
#             [0., 1., 0.]])

#     In [367]: onehot2seq(onehot)
#     Out[367]: tensor([1, 2, 1])
#     """
#     return torch.argmax(onehot, dim=1)

# #seq = np.loadtxt("label_seq")
# #seq = torch.Tensor(seq).long()
# #np.savetxt("label_onehot", seq2onehot(seq), fmt="%d")   

# example_str="""
# Note the onehot representation will has delimiter of ','.
# if no post_file or onehot_file is presented,
# the standard input and standard output will be used instead.
# """
# post = np.loadtxt("dpgmm/test3/timit_test3_raw.mfcc.dpmm.post", delimiter=',')
# label = post.argmax(-1)
# np.savetxt(sys.stdout, label.reshape((-1,1)), fmt="%d")


# if __name__ == "__main__":
#     parser = argparse.ArgumentParser(description="convert a sequence of label to onehot representation",
#                                      formatter_class=argparse.RawDescriptionHelpFormatter,
#                                      epilog=example_str)
#     parser.add_argument("--labelseq_file", type=str, default="")
#     parser.add_argument("--onehot_file", type=str, default="")

#     args = parser.parse_args()

#     input_file = args.labelseq_file if args.labelseq_file else sys.stdin
#     output_file = args.onehot_file if args.onehot_file else sys.stdout

#     labelseq = torch.LongTensor(np.loadtxt(input_file))
#     onehot = labelseq2onehot(labelseq)
#     np.savetxt(output_file, onehot, fmt="%d", delimiter=",")   

import numpy as np
import argparse
import sys

def post2onehot(post: np.ndarray) -> np.ndarray:
    """Convert a posteriorgram to its onehot representation.
    
    Arguments
    --------
    post: shape (seq_length, post_dim)
    onehot: shape(seq_length, post_dim)

    Examples
    --------
    In [595]: x
    array([[-1.42999544, -0.89400039,  0.77512976],
           [ 1.37445471,  1.63523631,  0.46542024]])

    In [596]: post2onehot(x)
    array([[0., 0., 1.],
           [0., 1., 0.]])
    """
    onehot = np.zeros_like(post)
    onehot[range(post.shape[0]), post.argmax(-1)] = 1

    return onehot

example_str="""
If the posteriorgram or the onehot file is not specified by parameters
the standard input and standard output will be used.
"""
def main():
    parser = argparse.ArgumentParser(description="Convert a posteriorgram to onehot",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog=example_str)
    parser.add_argument("--post_file", type=str, default="")
    parser.add_argument("--onehot_file", type=str, default="")
    parser.add_argument("--delimiter", type=str, default=",")

    args = parser.parse_args()

    input_file = args.post_file if args.post_file else sys.stdin
    output_file = args.onehot_file if args.onehot_file else sys.stdout

    post = np.loadtxt(input_file, delimiter=args.delimiter)
    np.savetxt(output_file, post2onehot(post), delimiter=args.delimiter, fmt='%d')
    
if __name__ == "__main__":
    main()
