for dir in $(ls -d eval/abx/post/exp/hybrid/ce/test.vtln.deltas.mfcc.dpmm.*post); do
    date
    echo $dir
    bash local/dirpost2dironehot.sh $dir $(echo $dir | sed 's/hybrid/hybrid_onehot/')
done
