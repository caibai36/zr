for dir in $(ls -d eval/abx/post/exp/hybrid/*/v2_timit_test_raw.vtln.cmvn.* | grep -v onehot); do
    date
    echo $dir
    bash local/dirpost2dironehot.sh $dir $(echo $dir | sed 's/hybrid/hybrid_onehot/')
done
