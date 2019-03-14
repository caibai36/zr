from typing import Tuple, Dict, Callable
import torch
from torch.utils.data import Dataset, DataLoader
from torch import nn, optim
import numpy as np
import argparse

class SelfFeatDataset(Dataset):

    def __init__(self,
                 feats: np.ndarray,
                 num_sources: int,
                 num_targets: int,
                 source_flatten: bool = False,
                 target_flatten: bool = False,
                 use_fake_feature = True) -> None:
        """
        We use a window to slide through a list of features.
        Each window has divided into the source and the target.

        We will copy the first feature num_sources times as heading fake features;
        we will copy the last feature such that total number of features
        will be multiples of num_targets, which is the tailing fake features

        Parameters
        ----------
        feats: a list of features
        num_sources: the number of features for source
        num_targets: the number of features for target
        source_flatten: flatten the source or not
        target_flatten: flatten the target or not
        use_fake_feature: use fake heading and tailing fake feature or not
                        We will copy the first feature num_sources times as heading fake features;
                        we will copy the last feature such that total number of features
                        will be multiples of num_targets, which is the tailing fake features

        Examples
        --------
        def main():
            feats = np.arange(10)
            dataset = SelfFeatDataset(feats, 2, 3)
            print(f"length of dataset: {len(dataset)}")
            for index in range(len(dataset)):
                print(f"item of dataset: {dataset[index]}")
            print(f"number of heading and tailing residual features: {dataset.get_residual()}")

        In [86]: run self_feat.py # default use_fake_feature = True
        length of dataset: 4
        item of dataset:
         {'source': tensor([0., 0.]), 'target': tensor([0., 1., 2.])}
        item of dataset:
         {'source': tensor([1., 2.]), 'target': tensor([3., 4., 5.])}
        item of dataset:
         {'source': tensor([4., 5.]), 'target': tensor([6., 7., 8.])}
        item of dataset:
         {'source': tensor([7., 8.]), 'target': tensor([9., 9., 9.])}
        number of heading, tailing and extra residual features: (0, 0, 2)

        In [86]: run self_feat.py # use_fake_feature = False
        length of dataset: 2
        item of dataset: {'source': tensor([0., 1.]), 'target': tensor([2., 3., 4.])}
        item of dataset: {'source': tensor([3., 4.]), 'target': tensor([5., 6., 7.])}
        number of heading, tailing and extra residual features: (2, 2, 0)
        """
        assert num_sources + num_targets <= len(feats), "too few number of features"
        super().__init__()
        self.feats = feats
        self.num_sources = num_sources
        self.num_targets = num_targets
        self.source_flatten = source_flatten
        self.target_flatten = target_flatten
        self.use_fake_feature = use_fake_feature

        if use_fake_feature:
            num_head_fake = num_sources
            head_fake = np.stack([feats[0]] * num_head_fake)
            num_tail_fake = num_targets - len(feats) % num_targets
            tail_fake = np.stack([feats[-1]] * num_tail_fake)
            self.feats = np.concatenate((head_fake, feats, tail_fake), axis=0)
            self.num_tail_fake = num_tail_fake

    def __len__(self) -> int:
        return int((len(self.feats) - self.num_sources) / self.num_targets)

    def __getitem__(self, index: int)-> Dict:
        source = self.feats[index * self.num_targets: index * self.num_targets + self.num_sources]
        target = self.feats[self.num_sources + index * self.num_targets:
                            self.num_sources + (index + 1) * self.num_targets]

        if self.source_flatten: source = source.flatten()
        if self.target_flatten: target = target.flatten()

        return {'source': torch.Tensor(source),
                'target': torch.Tensor(target)}

    def get_residual(self) -> Tuple[int, int]:
        """ return the number of heading residual feature,
        the number of tailing residual features
        and the extra tailing features if use_fake_feature
        """
        if self.use_fake_feature:
            return (0, 0, self.num_tail_fake)
        else:
            return (self.num_sources, (len(self.feats) - self.num_sources) % self.num_targets, 0)


class SelfFeatLSTM(nn.Module):

    def __init__(self,
                 input_dim: int,
                 hidden_dim: int,
                 num_layers: int,
                 loss: Callable[[torch.FloatTensor, torch.FloatTensor], torch.FloatTensor] = None) -> None:
        """
        Examples:
        model = SelfFeatLSTM(2, 3, 4) # (input_dim, hidden_dim, num_layers)
        source = torch.rand(5, 7, 2 ) # (batch_size, seq_length, input_dim)
        target = torch.rand(5, 3)     # (batch_size, hidden_dim)
        model(source, target)
        """
        super().__init__()
        self.lstm = nn.LSTM(input_size=input_dim,
                            hidden_size=hidden_dim,
                             num_layers=num_layers,
                            batch_first=True)
        self.loss = loss or nn.MSELoss()

    def forward(self,
                source: torch.FloatTensor,
                target: torch.FloatTensor) -> Dict:
        """
        source: (batch_size, seq_length, input_dim)
        target: (batch_size, hidden_dim)
        """
        o, (h, c) = self.lstm(source)
        assert torch.all(torch.eq(o[:,-1,:], h[-1])), "dimension of LSTM mismatching"
        # (batch_size, hidden_dim)
        predicted = h[-1]
        loss = self.loss(predicted, target)
        return {'loss': loss, 'predicted': predicted}


def main():
    egstr="""
    examples
    --------
    python local/self_feat.py --input_file=dpgmm/test3/timit_test3_raw.mfcc --output_file=dpgmm/test3/timit_test3_raw.mfcc.s2t3 --num_sources=2 --num_targets=3
    """
    parser = argparse.ArgumentParser(description="self-supervised feature learner",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog=egstr)
    parser.add_argument("--input_file", type=str, required=True, default="dpgmm/test3/timit_test3_raw.mfcc")
    parser.add_argument("--output_file", type=str, required=True, default="dpgmm/test3/timit_test3_raw.mfcc.s2t3")
    parser.add_argument("--num_sources", type=int, default=2)
    parser.add_argument("--num_targets", type=int, default=3)
    parser.add_argument("--seed", type=int, default=2019)
    parser.add_argument("--num_epochs", type=int, default=5)
    parser.add_argument("--batch_size", type=int, default=2)
    parser.add_argument("--print_interval", type=int, default=10000)
    parser.add_argument("--num_layers", type=int, default=2)
    parser.add_argument("--learning_rate", type=float, default=0.001)

    args = parser.parse_args()
    num_sources = args.num_sources
    num_targets = args.num_targets
    seed = args.seed
    num_epochs = args.num_epochs
    batch_size = args.batch_size
    print_interval = args.print_interval
    num_layers = args.num_layers
    learning_rate = args.learning_rate
    input_file = args.input_file
    output_file = args.output_file

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)

    # feats = np.arange(10)
    # feats = np.arange(10).reshape((-1, 1))
    # feats = np.concatenate((feats, feats), axis=1)
    feats = np.loadtxt(input_file)
    print(f"the shape of the feature: {feats.shape}")
    
    train_dataset = SelfFeatDataset(feats, num_sources, num_targets, target_flatten=True)
    train_loader = DataLoader(dataset=train_dataset, batch_size=batch_size)

    test_dataset = SelfFeatDataset(feats, num_sources, num_targets, target_flatten=True)
    test_loader = DataLoader(dataset=test_dataset, batch_size=batch_size)

    print(f"length of dataset: {len(train_dataset)}")
    print(f"number of heading, tailing and extra residual features: {train_dataset.get_residual()}")

    # assume the shape of features is (len, feat_dim)
    feat_dim = feats.shape[-1]
    input_dim = feat_dim
    input_length = num_sources
    hidden_dim = num_targets * feat_dim
    model = SelfFeatLSTM(input_dim, hidden_dim, num_layers)
    model.to(device)

    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    running_loss = 0
    step = 0
    for epoch in range(num_epochs):
        for batch in train_loader:
            source = batch['source'].to(device)
            target = batch['target'].to(device)

            output = model(source, target)

            optimizer.zero_grad()
            output['loss'].backward()
            optimizer.step()

            running_loss += output['loss'].item()
            step += 1
            if (step % print_interval == 0):
                print(f"Epoch: {epoch} batch: {step} loss: {running_loss / print_interval:.03f}")
                running_loss = 0

    outputs = []
    with torch.no_grad():
        for batch in test_loader:
            source = batch['source'].to(device)
            target = batch['target'].to(device)

            output = model(source, target)
            # (batch_size, hidden_dim)
            outputs.append(output['predicted'])

        converted = torch.cat(outputs, dim=0).reshape(-1, feat_dim)[:len(feats)].cpu().numpy()
        np.savetxt(output_file, converted, fmt="%.5g")

if __name__ == "__main__":
    main()
