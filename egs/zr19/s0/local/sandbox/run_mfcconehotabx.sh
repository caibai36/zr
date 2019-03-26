for file in $(ls -d eval/abx/post/exp/dpgmm/mfcc_onehot/test.vtln.*); do
    echo "---------------------------------------------------"
    echo "Evaluate the representation by ABX test"
    echo "---------------------------------------------------"

    # file=exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.post
    echo $(basename $file)
    base=$(basename $file)
    root=exp/dpgmm/mfcc_onehot/${base}

    abx_post=eval/abx/post/${root}/
    abx_result_cos=eval/abx/result/${root}/cos
    abx_result_kl=eval/abx/result/${root}/kl
    abx_result_edit=eval/abx/result/${root}/edit
    mkdir -p $abx_post $abx_result_cos $abx_result_kl $abx_result_edit

    source activate eval

     # cp -r ../zs19_docker/system/ .
    ./local/eval.sh --DIST 'cos' --EMB $abx_post --RES $abx_result_cos
    ./local/eval.sh --DIST 'kl' --EMB $abx_post --RES $abx_result_kl
    ./local/eval.sh --DIST 'edit' --EMB $abx_post --RES $abx_result_edit
done
