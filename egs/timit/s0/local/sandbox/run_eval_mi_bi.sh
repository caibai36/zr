# bash local/sandbox/eval_mi.sh --post_dir eval/abx/post/exp/selffeat/post/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post_post
# for post_dir in eval/abx/post/exp/*/*/*post; do bash local/eval_mi.sh --post_dir $post_dir; done | tee local/sandbox/run_eval_mi.log
for post_dir in eval/abx/post/exp/hybrid/ce/v2*f[0-9]*post; do bash local/eval_mi.sh --post_dir $post_dir;done  | tee local/sandbox/run_eval_mi_bi.log
