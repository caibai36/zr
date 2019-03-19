. path.sh
xstage=4

if [ $xstage -le 4 ]; then
    echo "---------------------------------------------------"
    echo "Dump the features after DPGMM."
    echo "---------------------------------------------------"
    mkdir -p data/{test,train}
    cp ../s0/data/test/feats.scp data/test/
    cp ../st/data/test/feats.scp data/train/

    # Dump dpgmm features
    mkdir -p exp/dpgmm/data
    copy-feats scp:data/test/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > exp/dpgmm/data/test.deltas.mfcc
    copy-feats scp:data/train/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > exp/dpgmm/data/train.deltas.mfcc
fi

if [ $stage -le 5 ]; then
    echo "---------------------------------------------------"
    echo "Get dpgmm posterigrams and labels. (need access to matlab)"
    echo "---------------------------------------------------"
    # need access to matlab
    /usr/local/MATLAB/R2018b/bin/matlab -r "addpath('local');run_dpgmm_modified('exp/dpgmm/data/train.deltas.mfcc', 'exp/dpgmm/data/test.deltas.mfcc');quit"
fi
