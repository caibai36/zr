from typing import Dict, Callable
import os
import numpy as np
import torch
from torch import nn, optim
from torch.utils.data import Dataset, DataLoader
import argparse

from tensorboardX import SummaryWriter

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

class Net(nn.Module):

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
        
        self.softmax = nn.Softmax(dim=-1)

    def forward(self, source: torch.FloatTensor) -> Dict:
        """
        source: shape (batch_size, seq_length, input_dim)
        """
        o, (h, c) = self.lstm(source.float())
        output = self.softmax(self.project(h[-1]))
        return output

def train_cluster3(model, device, train_loader, optimizer, criterion):
    model.train()
    for batch_idx, batch in enumerate(train_loader):
        data = batch['source'].to(device).float()
        output = model(data)
        with torch.no_grad():
            post = output
            post = post / post.sum(dim=0)
            post = post.cpu().numpy()
        # post.sum(0) ~= 1

        num_classes = output.shape[1]
        cur_batch_size = output.shape[0] # size of last batch (target[0]) is less than batch_size

        optimizer.zero_grad()
        cur_target = torch.arange(num_classes)

        # flatten feature, transpose for mul, then tranpose back to num_classes first, reshape to the original data
        cur_data = data.reshape(cur_batch_size, -1).transpose(0, 1).matmul(torch.Tensor(post).to(device)).transpose(0, 1).reshape((num_classes, *list(data[0].shape)))

        cur_data, cur_target = cur_data.to(device), cur_target.to(device)

        output = model(cur_data)
        cur_loss = criterion(output, cur_target)
        cur_loss.backward()
        optimizer.step()


def eval_cluster(model, device, test_loader):
    from sklearn import metrics

    model.eval()

    targets = []
    preds = []
    outputs = []
    with torch.no_grad():
        for batch_index, batch in enumerate(test_loader):
            data, target = batch['source'].to(device), batch['target'].to(device)
            output = model(data)
            pred = output.argmax(dim=1) # get the index of the max log-probability
            targets.append(target)
            preds.append(pred)
            outputs.append(output)

    targets = torch.cat(targets).reshape(-1)
    preds = torch.cat(preds).reshape(-1)
    outputs = torch.cat(outputs).reshape(preds.shape[0], -1)
    result = metrics.homogeneity_completeness_v_measure(targets.cpu().numpy(), preds.cpu().numpy())
    print('homo: {:.4f}, comp: {:.4f}, v_meas: {:.4f}, Target.size: {}, Preds.size: {}'.format(
        result[0], result[1], result[2], targets.shape, preds.shape))
    return result, preds, outputs

egstr=""

def main():
    parser = argparse.ArgumentParser(description="DPGMM hybird system posteriorgram learner",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog=egstr)
    parser.add_argument("--exp", type=str, required=False, default="timit")
    parser.add_argument("--source_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc")
    parser.add_argument("--target_file", type=str, required=False, default="dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel")
    parser.add_argument("--seed", type=int, default=4)

    parser.add_argument("--epochs", type=int, default=5)
    parser.add_argument("--batch_size", type=int, default=2)

    parser.add_argument("--hidden_dim", type=int, default=512)
    parser.add_argument("--output_dim", type=int, default=39)
    parser.add_argument("--num_layers", type=int, default=3)
    parser.add_argument("--num_left_context", type=int, default=0)
    parser.add_argument("--learning_rate", type=float, default=0.001)
    parser.add_argument("--print_post", action='store_true', default=False) 
    parser.add_argument('--exp_dir', type=str, default='exp/test_clustering')
    parser.add_argument('--log_dir', type=str, default='logs')
    parser.add_argument("--print_pred_interval", type=int, default=1)

    args = parser.parse_args()
    print(args)
    exp_name = f"{args.exp}_bs{args.batch_size}_seed{args.seed}_hd{args.hidden_dim}_od{args.output_dim}_nl{args.num_layers}_lc{args.num_left_context}_lr{args.learning_rate}"
    writer = SummaryWriter(args.exp_dir + '/' + args.log_dir + '/' + exp_name)
    
    if (not os.path.exists(args.exp_dir + '/' + exp_name + "/outputs") and args.print_post):
        os.makedirs(args.exp_dir + '/' + exp_name + "/outputs")
    if not os.path.exists(args.exp_dir + '/' + exp_name + "/preds"):
        os.makedirs(args.exp_dir + '/' + exp_name + "/preds")
    fr = open(args.exp_dir + '/' + exp_name + "/out", 'w') 
    
    source_file = args.source_file
    target_file = args.target_file
    seed = args.seed

    epochs = args.epochs
    batch_size = args.batch_size

    hidden_dim = args.hidden_dim
    output_dim = args.output_dim
    num_layers = args.num_layers
    num_left_context = args.num_left_context
    learning_rate = args.learning_rate

    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    # for cross entropy
    # s1 = np.array([[0, 0], [1, 1], [2, 2], [3, 3], [4, 4]])
    # t1 = np.array([0, 1, 2, 0, 1])

    # for mean square error
    # s2 = np.array([[0, 0], [1, 1], [2, 2], [3, 3], [4, 4]])
    # t2 = np.array([[1., 0, 0], [0, 1., 0], [0, 0, 1.], [1., 0, 0], [0, 1., 0]])

    source_data = np.loadtxt(source_file)
    target_data = np.loadtxt(target_file, delimiter=',') # posteriorgram

    input_dim = source_data.shape[1]
    assert target_data.min() >= 0, "the class of index should be greater or equal to zero"
    # output_dim = int(target_data.max()) + 1 # We index the classes from 0

    test_dataset = ParallelDataset(source_data, target_data, num_left_context=num_left_context)
    test_loader = DataLoader(dataset=test_dataset, batch_size=batch_size)

    model = Net(input_dim, hidden_dim, output_dim, num_layers).to(device)
    print(model)
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    criterion = nn.CrossEntropyLoss()

    epoch=0
    test_v, preds, outputs = eval_cluster(model, device, test_loader)
    
    print("Epoch {}: test_v:{}".format(epoch, test_v))
    fr.write("Epoch {}: test_v:{}\n".format(epoch, test_v)) 
    writer.add_scalar('v/test_homo', test_v[0], epoch)
    writer.add_scalar('v/test_comp', test_v[1], epoch)
    writer.add_scalar('v/test_v', test_v[2], epoch)
    if(args.print_post):
        np.savetxt(args.exp_dir + '/' + exp_name + "/outputs/" + str(epoch), outputs.cpu().numpy(), fmt="%.4e", delimiter='\t')
    np.savetxt(args.exp_dir + '/' + exp_name + "/preds/" + str(epoch), preds.cpu().numpy(), fmt="%d", delimiter='\t')


    for epoch in range(1, epochs + 1):
        train_cluster3(model, device, test_loader, optimizer, criterion)
        test_v, preds, outputs = eval_cluster(model, device, test_loader)
        
        print("Epoch {}: test_v:{}".format(epoch, test_v))
        fr.write("Epoch {}: test_v:{}\n".format(epoch, test_v))
        writer.add_scalar('v/test_homo', test_v[0], epoch)
        writer.add_scalar('v/test_comp', test_v[1], epoch)
        writer.add_scalar('v/test_v', test_v[2], epoch)
        if(args.print_post):
            np.savetxt(args.exp_dir + '/' + exp_name + "/outputs/" + str(epoch), outputs.cpu().numpy(), fmt="%.4e", delimiter='\t')
        if(epoch % args.print_pred_interval == 0): 
            np.savetxt(args.exp_dir + '/' + exp_name + "/preds/" + str(epoch), preds.cpu().numpy(), fmt="%d", delimiter='\t')

if __name__ == '__main__':
    main()
