file="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/kl/analysis/tmp/across_triplet_score.txt"
echo "Num of instances in across speakers t-test:"
echo "$(wc -l $file | cut -d' ' -f1)"
echo

file1="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/cos/analysis/tmp/across_triplet_score.txt"
file2="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/cos/analysis/tmp/across_triplet_score.txt"
echo "RNN16_cos_across DPGMM_cos_across"
Rscript local/run_t_test.R $file1 $file2

file1="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/kl/analysis/tmp/across_triplet_score.txt"
file2="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/kl/analysis/tmp/across_triplet_score.txt"
echo "RNN16_kl_across DPGMM_kl_across"
Rscript local/run_t_test.R $file1 $file2

file1="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/edit/analysis/tmp/across_triplet_score.txt"
file2="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/edit/analysis/tmp/across_triplet_score.txt"
echo "RNN16_edit_across DPGMM_edit_across"
Rscript local/run_t_test.R $file1 $file2

file="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/kl/analysis/tmp/within_triplet_score.txt"
echo "Num of instances in within speakers t-test:"
echo "$(wc -l $file | cut -d' ' -f1)"
echo

file1="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/cos/analysis/tmp/within_triplet_score.txt"
file2="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/cos/analysis/tmp/within_triplet_score.txt"
echo "RNN16_cos_within DPGMM_cos_within"
Rscript local/run_t_test.R $file1 $file2

file1="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/kl/analysis/tmp/within_triplet_score.txt"
file2="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/kl/analysis/tmp/within_triplet_score.txt"
echo "RNN16_kl_within DPGMM_kl_within"
Rscript local/run_t_test.R $file1 $file2

file1="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/edit/analysis/tmp/within_triplet_score.txt"
file2="eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/edit/analysis/tmp/within_triplet_score.txt"
echo "RNN16_edit_within DPGMM_edit_within"
Rscript local/run_t_test.R $file1 $file2
