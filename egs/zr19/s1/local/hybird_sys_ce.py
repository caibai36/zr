from typing import Dict, Callable
import numpy as np
import torch
from torch import nn, optim
from torch.utils.data import Dataset, DataLoader
import argparse

class ParallelDataset(Dataset):

    def __init__(self,
                 source_feats: np.ndarray,
                 target_feats: np.ndarray,
                 num_left_context: int = 0) -> None:
        """
        Parallel dataset of a list of source features and a list of target features.
        Target feature can be discrete labels or continuous feature vector.
        source features with left few contexts is supported.

        Arguments
        ---------
        source_feats: shape (num_feats, input_dim)
        target_feats: shape (num_feats,) or (num_feats, output_dim)
        num_left_context: number of left contexts exclude the current feature

        Examples
        --------
        In [461]: source = np.array([1, 2, 3])
        In [462]: target = np.array([0.1, 0.2, 0.1])
        In [463]: dataset = ParallelDataset(source, target, num_left_context=2)
        In [466]: for index in range(len(dataset)):
             ...:     print(dataset[index])
        {'source': array([1, 1, 1]), 'target': 0.1}
        {'source': array([1, 1, 2]), 'target': 0.2}
        {'source': array([1, 2, 3]), 'target': 0.1}
        """
        super().__init__()
        if num_left_context == 0:
            self.source_feats = source_feats
            self.target_feats = target_feats
        else:
            source_head_fake = np.stack([source_feats[0]] * num_left_context, axis=0)
            self.source_feats = np.concatenate([source_head_fake, source_feats], axis=0)
            target_head_fake = np.stack([target_feats[0]] * num_left_context, axis=0)
            self.target_feats = np.concatenate([target_head_fake, target_feats], axis=0)

        self.num_left_context = num_left_context

    def __len__(self) -> int:
        return len(self.source_feats) - self.num_left_context

    # It is OK for dataset to return array or integer
    # Dataloader will convert all numpy array to tensor
    # Dataloader will convert all integer or float to tensor.
    def __getitem__(self, index: int) -> Dict:
        return {'source': self.source_feats[index: index + self.num_left_context + 1],
                'target': self.target_feats[index + self.num_left_context]}

class ParallelCENet(nn.Module):

    def __init__(self,
                 input_dim: int,
                 hidden_dim: int,
                 output_dim: int,
                 num_layers: int) -> None:
        """
        A neural network with cross entropy loss for parallel dataset with contexts.
        As the prediction will be posteriorgram, so we should add a softmax layer
        """
        super().__init__()
        self.lstm = nn.LSTM(input_size=input_dim,
                            hidden_size=hidden_dim,
                            num_layers=num_layers,
                            batch_first=True)
        self.project = nn.Linear(hidden_dim, output_dim)
        self.loss = nn.CrossEntropyLoss()
        self.softmax = nn.Softmax(dim=-1)

    def forward(self,
                source: torch.FloatTensor,
                target: torch.LongTensor = None,
                train=True) -> Dict:
        """
        source: shape (batch_size, seq_length, input_dim)
        target: shape (seq_length,)
        """
        o, (h, c) = self.lstm(source)
        assert torch.all(torch.eq(h[-1], o[:,-1,:])), "output and hidden dimension mismatching."
        predicted = self.softmax(self.project(h[-1]))
        loss = self.loss(predicted, target) if train else None
        return {'predicted': predicted, 'loss': loss}

egstr=""

def main():
    parser = argparse.ArgumentParser(description="DPGMM hybird system posteriorgram learner",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog=egstr)
    parser.add_argument("--source_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc")
    parser.add_argument("--target_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel")
    parser.add_argument("--test_source_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw2.mfcc")
    parser.add_argument("--output_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel.b0.post")
    parser.add_argument("--seed", type=int, default=2019)

    parser.add_argument("--num_epochs", type=int, default=5)
    parser.add_argument("--batch_size", type=int, default=2)
    parser.add_argument("--print_interval", type=int, default=400)

    parser.add_argument("--hidden_dim", type=int, default=512)
    parser.add_argument("--num_layers", type=int, default=3)
    parser.add_argument("--num_left_context", type=int, default=0)
    parser.add_argument("--learning_rate", type=float, default=0.001)

    args = parser.parse_args()
    source_file = args.source_file
    target_file = args.target_file
    output_file = args.output_file
    seed = args.seed

    num_epochs = args.num_epochs
    batch_size = args.batch_size
    print_interval = args.print_interval

    hidden_dim = args.hidden_dim
    num_layers = args.num_layers
    num_left_context = args.num_left_context
    learning_rate = args.learning_rate
    test_source_file = args.test_source_file

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)

    # for cross entropy
    # s1 = np.array([[0, 0], [1, 1], [2, 2], [3, 3], [4, 4]])
    # t1 = np.array([0, 1, 2, 0, 1])

    # for mean square error
    # s2 = np.array([[0, 0], [1, 1], [2, 2], [3, 3], [4, 4]])
    # t2 = np.array([[1., 0, 0], [0, 1., 0], [0, 0, 1.], [1., 0, 0], [0, 1., 0]])

    source_data = np.loadtxt(source_file)
    target_data = np.loadtxt(target_file, delimiter=',') # posteriorgram
    test_source_data = np.loadtxt(test_source_file)
    test_target_data = np.loadtxt(test_source_file) # hack, fake target file, we don't need target file for test set

    input_dim = source_data.shape[1]
    assert target_data.min() >= 0, "the class of index should be greater or equal to zero"
    output_dim = int(target_data.max()) + 1 # We index the classes from 0

    train_dataset = ParallelDataset(source_data, target_data, num_left_context=num_left_context)
    train_dataloader = DataLoader(dataset=train_dataset, batch_size=batch_size)

    test_dataset = ParallelDataset(test_source_data, test_target_data, num_left_context=num_left_context)
    test_dataloader = DataLoader(dataset=test_dataset, batch_size=batch_size)

    model = ParallelCENet(input_dim, hidden_dim, output_dim, num_layers)
    model.to(device)
    print(model)
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    step = 0
    running_loss = 0
    for epoch in range(num_epochs):
        for batch in train_dataloader:
            source = batch['source'].to(device).float()
            target = batch['target'].to(device).long()

            output = model(source, target)

            optimizer.zero_grad()
            output['loss'].backward()
            optimizer.step()

            running_loss += output['loss'].item()
            step += 1

            if (step % print_interval == 0):
                print(f"Epoch: {epoch} batch: {step} loss: {running_loss / print_interval:.4f}")
                running_loss = 0

    outputs = []
    with torch.no_grad():
        for batch in test_dataloader:
            source = batch['source'].to(device).float()
            # target = batch['target'].to(device).long()

            # may be create model.train() and model.test() to change the self.train is a better idea
            output = model(source, train=False)
            outputs.append(output['predicted'])

    print(torch.cat(outputs, dim=0).shape)
    np.savetxt(output_file, torch.cat(outputs, dim=0).cpu().numpy(), fmt="%.4e", delimiter=',')

if __name__ == '__main__':
    main()
