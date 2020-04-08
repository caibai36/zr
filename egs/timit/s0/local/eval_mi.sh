post_dir=eval/abx/post/exp/dpgmm/baseline/vltn.deltas_post

# You can run
# bash local/sandbox/eval_mi.sh --post_dir eval/abx/post/exp/selffeat/post/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post_post
. utils/parse_options.sh

echo "post_dir: $post_dir"
mi_dir=${post_dir/post/result}/mi # replace the first post with result
mkdir -p $mi_dir

paste \
    <(awk '{print $1}' data/test/feats.scp  | while read -r uttid; do cat ${post_dir}/${uttid}.post | tr -s ' ' | sed -e 's/^ //g' -e 's/ $//' | cut -d' ' -f2-  ; done | python -c 'import numpy as np; import sys; post = np.loadtxt(sys.stdin); np.savetxt(sys.stdout, post.argmax(-1), fmt="%d")') \
    <(awk '{print $1}' data/test/feats.scp | while read -r uttid; do cat exp/dpgmm/baseline/data/merge_label/${uttid}.mlabel.abx | cut -d' ' -f2; done ) \
    | tr -s '\t' ' ' | sed -e 's/^ //' -e 's/ $//' > $mi_dir/pair.txt

python local/eval_mi.py $mi_dir/pair.txt | tee $mi_dir/mi_result.txt
