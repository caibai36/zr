import numpy as np
import torch
import argparse
import sys

def labelseq2onehot(seq: torch.LongTensor, num_classes: int = None) -> torch.LongTensor:
    """
    Arguments
    ---------
    seq: shape (seq_length,)

    Examples
    --------
    In [361]: seq2onehot(torch.Tensor([1, 2, 1]).long())
    Out[361]:
    tensor([[0., 1., 0.],
            [0., 0., 1.],
            [0., 1., 0.]])
    -------
    """
    assert seq.min() >= 0, "the class of index should be greater or equal to zero"
    if num_classes:
        assert num_classes >= seq.max() + 1, "number of class too small"
    else:
        num_classes = seq.max() + 1 # We index the classes from 0

    seq_length = len(seq)
    onehot = torch.zeros(seq_length, num_classes)
    onehot[range(seq_length), seq] = 1
    return onehot

def onehot2labelseq(onehot: torch.LongTensor) -> torch.LongTensor:
    """
    Arguments
    ---------
    onehot: shape (seq_length, num_classes)

    Examples
    --------
    In [366]: onehot
    Out[366]:
    tensor([[0., 1., 0.],
            [0., 0., 1.],
            [0., 1., 0.]])

    In [367]: onehot2seq(onehot)
    Out[367]: tensor([1, 2, 1])
    """
    return torch.argmax(onehot, dim=1)

#seq = np.loadtxt("label_seq")
#seq = torch.Tensor(seq).long()
#np.savetxt("label_onehot", seq2onehot(seq), fmt="%d")   

example_str="""
Note the onehot representation will has delimiter of ','.
if no labelseq_file or label_onehot_file is presented,
the standard input and standard output will be used instead.
"""

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="convert a sequence of label to onehot representation",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog=example_str)
    parser.add_argument("--labelseq_file", type=str, default="")
    parser.add_argument("--onehot_file", type=str, default="")

    args = parser.parse_args()

    input_file = args.labelseq_file if args.labelseq_file else sys.stdin
    output_file = args.onehot_file if args.onehot_file else sys.stdout

    labelseq = torch.LongTensor(np.loadtxt(input_file))
    onehot = labelseq2onehot(labelseq)
    np.savetxt(output_file, onehot, fmt="%d", delimiter=",")   
