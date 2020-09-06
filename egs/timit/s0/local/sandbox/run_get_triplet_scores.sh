#for file in eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel*{b16,onehot}*post/*/analysis/tmp/*score; do
for file in eval/abx/result/exp/hybrid_onehot/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel*{b0,b2,b4,b8}*post/*/analysis/tmp/*score; do
    echo $file;
    python local/get_triplet_score.py --score_file=$file
done
