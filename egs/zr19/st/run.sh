stage=0

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
if [ $stage -le 1 ]; then
    echo "Prepare utterance file, vad file and evaluation utterance file"

    for file in $db/english/train/unit/* ; do
	echo $(basename $file .wav);
    done | sort -u > $uttids
    echo -n "number of utterances in ${uttids}: "
    wc -l $uttids

    grep -f $uttids $db/english/vads.txt > $vads
    echo -n "number of utterances in ${vads}: "
    awk '{print $1}' $vads | sort -u | wc -l


    for file in $db/english/test/*; do
        echo $(basename $file .wav);
    done | sort -u > $evalids
fi

# uttid with format speak_utterance
# audio file with name speaker_utterance.wav
mkdir -p data/test
if [ $stage -le 2 ]; then
    echo "Prepare wav.scp, utt2spk, spk2utt and segments file for corpus"

    for file in $(cat $uttids); do
	echo "$file $(find $db/english/train/unit -name ${file}.wav)";
    done > data/test/wav.scp
    echo "number of utterances in wav.scp file: $(wc -l data/test/wav.scp)"

    cat data/test/wav.scp | awk '{print gensub(/^([A-Za-z0-9]+)_([A_Za-z0-9]+)$/, "\\0 \\1", "g", $1)}' > data/test/utt2spk
    utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt
    cat $vads | awk '{print $1, $1, $2, $3}' | sort -k1,1 -u > data/test/segments
fi

# Run the stage again if it says
# "...segments is not in sorted order or has duplicates"
# as it will be fixed by fix_data_dir.sh
if [ $stage -le 3 ]; then
    echo "---------------------------------------------------"
    echo "MFCC feature extration and compute CMVN of data set"
    echo "---------------------------------------------------"
    echo -e "--use-energy=false\n--frame-length=$frame_length\n--frame-shift=$frame_shift" | tee conf/mfcc.conf

    # Do Mel-frequency cepstral coefficients (mfcc) feature extraction.
    # Differ from step/make_mfcc.sh  (extract-segments => set --min-segment-length=0.001)
    local/make_mfcc.sh --mfcc-config conf/mfcc.conf \
		       --nj $feat_nj \
		       --cmd "$train_cmd" \
		       --write-utt2num-frames true \
		       data/test exp/make_mfcc/test $mfcc_dir
    # Compute Cepstral mean and variance normalization (cmvn) of data.
    steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfcc_dir
    # Fixing data format.
    utils/fix_data_dir.sh data/test || exit 1 # remove segments with problems

    echo "---------------------------------------------------"
    echo "lvtln model training"
    echo "---------------------------------------------------"

    # Train the linear Vocal Tract Length Normalization (lVTLN) to get the warping factors.
    # This script does not require to start with a trained model.
    # There is another script (steps/train_lvtln.sh) that requires an initial model.
    ./local/english_train_lvtln.sh $num_gauss_ubm data/test exp/test_vtln

    # Prepare the data files.
    # We copy it because the following scripts may change the data files.
    mkdir -p data/test_vtln
    cp -r data/test/* data/test_vtln || exit 1
    cp exp/test_vtln/warps/utt2warp data/test_vtln || exit 1

    echo "---------------------------------------------------"
    echo "MFCC feature extraction with lVTLN of dataset"
    echo "---------------------------------------------------"

    # Do Mel-frequency cepstral coefficients (mfcc) feature extraction.
    local/make_mfcc.sh --mfcc-config conf/mfcc.conf \
		       --nj $feat_nj \
		       --cmd "$train_cmd" \
		       data/test_vtln exp/make_mfcc/test_vtln $mfcc_vtln_dir
    # Compute Cepstral mean and variance normalization (cmvn) of data.
    steps/compute_cmvn_stats.sh data/test_vtln exp/make_mfcc/test_vtln $mfcc_vtln_dir
    # Fixing data format.
    utils/fix_data_dir.sh data/test_vtln || exit 1 # remove segments with problems

    echo "---------------------------------------------------"
    echo "Dump the features after CMVN."
    echo "---------------------------------------------------"
    # Place the lVTLN before the dump.
    # Store the script file of the law mfcc before CMVN.
    cp data/test/feats.scp data/test/raw.scp
    # Dump the features after CMVN.
    local/make_cmvn.sh data/test $mfcc_dir

    # Store the script file of the law mfcc before CMVN.
    cp data/test_vtln/feats.scp data/test_vtln/raw.scp
    # Dump the features after CMVN.
    local/make_cmvn.sh data/test_vtln $mfcc_vtln_dir
fi

if [ $stage -le 4 ]; then
    echo "---------------------------------------------------"
    echo "Dump the features after DPGMM."
    echo "---------------------------------------------------"
    mkdir -p exp/dpgmm/data
    # copy-feats scp:data/test_vtln/feats.scp ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' >  exp/dpgmm/data/test.vtln.mfcc
    copy-feats scp:data/test_vtln/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > exp/dpgmm/data/test.vtln.deltas.mfcc
    sort -k2,2 -k4,4g data/test/segments > exp/dpgmm/data/test_segments_sorted
fi

# if [ $stage -le 5 ]; then
#     echo "---------------------------------------------------"
#     echo "Get dpgmm posterigrams and labels. (need access to matlab)"
#     echo "---------------------------------------------------"
#     # need access to matlab
#     /usr/local/MATLAB/R2018b/bin/matlab -r "addpath('local');run_dpgmm('exp/dpgmm/data/test.vtln.deltas.mfcc');quit"
# fi

# if [ $stage -le 6 ]; then
#     echo "---------------------------------------------------"
#     echo "Evaluate the representation by ABX test"
#     echo "---------------------------------------------------"

#     mkdir -p local/bin
#     [ -f local/bin/split_post_seg ] || g++ local/split_post_seg.cpp -o local/bin/split_post_seg

#     file=exp/dpgmm/data/test.vtln.deltas.mfcc.dpmm.post
#     echo $(basename $file)
#     base=$(basename $file)
#     root=exp/dpgmm/post/${base}
#     evalids=conf/eval_uttids.txt

#     abx_post=eval/abx/post/${root}/
#     abx_result_cos=eval/abx/result/${root}/cos
#     abx_result_kl=eval/abx/result/${root}/kl
#     post_file=$file
#     segments_sorted=exp/dpgmm/data/test_segments_sorted

#     mkdir -p $abx_post $abx_result_cos $abx_result_kl
#     ./local/bin/split_post_seg data/test/utt2num_frames $post_file $segments_sorted $abx_post

#     while read -r line; do
#     	file=$abx_post/${line}.pos;
# 	# modify postfix. eg: 146f_0584.pos -> 146f_0584.txt
# 	# Remove the first time column, squeeze the spaces and cut the head and tail blanks
#     	cat $file  | tr -s ' ' | cut -d' ' -f2- | sed -e 's/^ //' -e 's/ $//' > $(echo $file | sed "s:pos$:txt:")
#     done < $evalids
#     rm $abx_post/*.pos

#     source activate eval

#      # cp -r ../zs19_docker/system/ .
#     ./local/eval.sh --DIST 'cos' --EMB $abx_post --RES $abx_result_cos
#     ./local/eval.sh --DIST 'kl' --EMB $abx_post --RES $abx_result_kl
# fi
