stage=5
for file in eval/abx/post/exp/hybrid_onehot/ce/t*post; do
    echo "---------------------------------------------------"
    echo "Evaluate the representation by ABX test"
    echo "---------------------------------------------------"

    # file=exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.post.onehot
    echo $(basename $file)
    base=$(basename $file)
    root=exp/hybrid_onehot/ce/${base}
    evalids=conf/eval_uttids.txt

    abx_post=eval/abx/post/${root}/
    abx_result_cos=eval/abx/result/${root}/cos
    abx_result_kl=eval/abx/result/${root}/kl
    abx_result_edit=eval/abx/result/${root}/edit
    post_file=$file
    segments_sorted=exp/dpgmm/data/test_segments_sorted

    mkdir -p $abx_post $abx_result_cos $abx_result_kl

    source activate eval

     # cp -r ../zs19_docker/system/ .
    ./local/eval.sh --DIST 'cos' --EMB $abx_post --RES $abx_result_cos
    ./local/eval.sh --DIST 'kl' --EMB $abx_post --RES $abx_result_kl
    ./local/eval.sh --DIST 'edit' --EMB $abx_post --RES $abx_result_edit
done
