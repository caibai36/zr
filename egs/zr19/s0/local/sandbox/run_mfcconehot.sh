for dir in $(ls -d eval/abx/post/exp/dpgmm/mfcc/test.vtln.*); do
    date
    echo $dir
    bash local/dirpost2dironehotwithouttime.sh $dir $(echo $dir | sed 's:mfcc:mfcc_onehot:')
done
