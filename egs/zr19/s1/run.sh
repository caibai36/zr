stage=7

. local/kaldi_conf.sh
. path.sh
. cmd.sh

# frame-shift of mfcc features
frame_shift=10 # default 10
# frame-length of mfcc features
frame_length=25 # default 25
# Directory contains mfcc features and cmvn statistics.
mfcc_dir=mfcc
# Directory contains mfcc features with lVTLN and its cmvn statistics.
mfcc_vtln_dir=mfcc_vtln
# the number of Gaussians of training an ubm model
# We follow the timit egs setting of numGaussUBM=400
num_gauss_ubm=400
# the number of jobs for running the feature extraction
feat_nj=20
# Database for zerospeech 2019
# You can download the database by local/download.sh
db=/project/nakamura-lab08/Work/bin-wu/share/data/zr19/db # CHECKME

uttids=conf/test_uttids.txt
vads=conf/test_vads.txt
evalids=conf/eval_uttids.txt

if [ $stage -le 4 ]; then
    echo "---------------------------------------------------"
    echo "Dump the features after DPGMM."
    echo "---------------------------------------------------"
    # copy the uttid and feats.scp files
    mkdir -p conf
    cp ../st/conf/test_uttids.txt conf/train_uttids.txt
    cp ../st/conf/eval_uttids.txt conf/
    
    mkdir -p data/{test_vtln,train_vtln}
    cp ../s0/data/test_vtln/feats.scp data/test_vtln/
    cp ../st/data/test_vtln/feats.scp data/train_vtln/

    # Dump dpgmm features
    mkdir -p exp/dpgmm/data
    copy-feats scp:data/test_vtln/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > exp/dpgmm/data/test.vtln.deltas.mfcc
    copy-feats scp:data/train_vtln/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > exp/dpgmm/data/train.vtln.deltas.mfcc

    sort -k2,2 -k4,4g ../s0/data/test_vtln/segments > exp/dpgmm/data/test_segments_sorted
fi

if [ $stage -le 5 ]; then
    echo "---------------------------------------------------"
    echo "Get dpgmm posterigrams and labels. (need access to matlab)"
    echo "---------------------------------------------------"
    # need access to matlab
    /usr/local/MATLAB/R2018b/bin/matlab -r "addpath('local');run_dpgmm_modified('exp/dpgmm/data/train.vtln.deltas.mfcc', 'exp/dpgmm/data/test.vtln.deltas.mfcc');quit"
    mv exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.flabel exp/dpgmm/data/train.vtln.deltas.mfcc.dpmm.flabel
fi

if [ $stage -le 6 ]; then
    echo "---------------------------------------------------"
    echo "Evaluate the representation by ABX test"
    echo "---------------------------------------------------"

    # cp {../s0/,}data/test/utt2num_frames
    # cp -r ../s0/system/ .
    # cp ../s0/local/eval.sh local/
    mkdir -p local/bin
    [ -f local/bin/split_post_seg ] || g++ local/split_post_seg.cpp -o local/bin/split_post_seg

    file=exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.post
    echo $(basename $file)
    base=$(basename $file)
    root=exp/dpgmm/post/${base}
    evalids=conf/eval_uttids.txt

    abx_post=eval/abx/post/${root}/
    abx_result_cos=eval/abx/result/${root}/cos
    abx_result_kl=eval/abx/result/${root}/kl
    post_file=$file
    segments_sorted=exp/dpgmm/data/test_segments_sorted

    mkdir -p $abx_post $abx_result_cos $abx_result_kl
    ./local/bin/split_post_seg data/test/utt2num_frames $post_file $segments_sorted $abx_post

    while read -r line; do
    	file=$abx_post/${line}.pos;
	# modify postfix. eg: 146f_0584.pos -> 146f_0584.txt
	# Remove the first time column, squeeze the spaces and cut the head and tail blanks
    	cat $file  | tr -s ' ' | cut -d' ' -f2- | sed -e 's/^ //' -e 's/ $//' > $(echo $file | sed "s:pos$:txt:")
    done < $evalids
    rm $abx_post/*.pos

    source activate eval

     # cp -r ../zs19_docker/system/ .
    ./local/eval.sh --DIST 'cos' --EMB $abx_post --RES $abx_result_cos
    ./local/eval.sh --DIST 'kl' --EMB $abx_post --RES $abx_result_kl
fi

if [ $stage -le 7 ]; then
    cat exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.post | python local/post2onehot.py > exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.post.onehot
    echo "---------------------------------------------------"
    echo "Evaluate the representation by ABX test"
    echo "---------------------------------------------------"

    mkdir -p local/bin
    [ -f local/bin/split_post_seg ] || g++ local/split_post_seg.cpp -o local/bin/split_post_seg

    file=exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.post.onehot
    echo $(basename $file)
    base=$(basename $file)
    root=exp/dpgmm/onehot/${base}
    evalids=conf/eval_uttids.txt

    abx_post=eval/abx/post/${root}/
    abx_result_cos=eval/abx/result/${root}/cos
    abx_result_kl=eval/abx/result/${root}/kl
    abx_result_edit=eval/abx/result/${root}/edit
    post_file=$file
    segments_sorted=exp/dpgmm/data/test_segments_sorted

    mkdir -p $abx_post $abx_result_cos $abx_result_kl
    ./local/bin/split_post_seg data/test/utt2num_frames $post_file $segments_sorted $abx_post

    while read -r line; do
    	file=$abx_post/${line}.pos;
	# modify postfix. eg: 146f_0584.pos -> 146f_0584.txt
	# Remove the first time column, squeeze the spaces and cut the head and tail blanks
    	cat $file  | tr -s ' ' | cut -d' ' -f2- | sed -e 's/^ //' -e 's/ $//' > $(echo $file | sed "s:pos$:txt:")
    done < $evalids
    rm $abx_post/*.pos

    source activate eval

     # cp -r ../zs19_docker/system/ .
    ./local/eval.sh --DIST 'cos' --EMB $abx_post --RES $abx_result_cos
    ./local/eval.sh --DIST 'kl' --EMB $abx_post --RES $abx_result_kl
    ./local/eval.sh --DIST 'edit' --EMB $abx_post --RES $abx_result_edit
fi
