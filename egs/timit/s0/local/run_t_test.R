# file1="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/kl/analysis/tmp/within_triplet_score.txt"
# file2 ="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/kl/analysis/tmp/within_triplet_score.txt"

args = commandArgs(TRUE)
if (length(args) != 2) {
   stop("usage: Rscript run_t_test.R abx_csv_file1 abx_csv_file2")
}

file1 = args[1]
file2 = args[2]
data1 <- read.csv(file1, header=FALSE, sep="\t")
data2 <- read.csv(file2, header=FALSE, sep="\t")
t.test(data1$V1, data2$V1, paired=TRUE, alternative='greater')
