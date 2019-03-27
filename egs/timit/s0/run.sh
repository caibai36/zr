###################################################################################
# File: run.sh
# Modified at 11:35 on 13 January 2018 by bin-wu.
#     Run the dpmm experiment for the phoneme discovery. 
# Modified at 01:43 on 29 January 2018 by bin-wu.
#     Use functional load to enhance the phoneme discovery.
# Modified at 15:47 on 06 Frebruary 2018 by bin-wu
#     Add data analysis codes.
# Script to run the dpmm experiment on the timit test data.
# 
####################################################################################

#!/bin/bash

# Prepare the conf files.
./local/kaldi_conf.sh # CHECKME
. cmd.sh
. path.sh

# Directory contains mfcc features and cmvn statistics.
mfcc_dir=mfcc
# Directory contains mfcc features with lVTLN and its cmvn statistics.
mfcc_vtln_dir=mfcc_vtln
# the number of Gaussians of training an ubm model
# We follow the timit egs setting of numGaussUBM=400
num_gauss_ubm=400 
# the number of jobs for running the feature extraction
feat_nj=20
# the directory of timit
timit=/project/nakamura-lab01/Share/Corpora/Speech/en/TIMIT/TIMIT # CHECKME
# see README for how to prepare abx test for timit corpus
abx=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/tools/abx # CHECKME
stage=7

if [ $stage -le 1 ]; then
    echo ============================================================================
    echo "                Data & Lexicon & Language Preparation                     "
    echo ============================================================================

    # Prepare the data files.
    local/timit_data_prep.sh $timit || exit 1

    local/timit_prepare_dict.sh

    # Caution below: we remove optional silence by setting "--sil-prob 0.0",
    # in TIMIT the silence appears also as a word in the dictionary and is scored.
    utils/prepare_lang.sh --sil-prob 0.0 --position-dependent-phones false --num-sil-states 3 \
			  data/local/dict "sil" data/local/lang_tmp data/lang

    local/timit_format_data.sh

    echo ============================================================================
    echo "              MFCC Feature Extration & CMVN of data set                   "
    echo ============================================================================

    # Do Mel-frequency cepstral coefficients (mfcc) feature extraction.
    steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj $feat_nj --cmd "$train_cmd" data/test exp/make_mfcc/test $mfcc_dir
    # Compute Cepstral mean and variance normalization (cmvn) of data.
    steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfcc_dir
    # Fixing data format.                                                                               
    utils/fix_data_dir.sh data/test || exit 1 # remove segments with problems  

    echo ============================================================================
    echo "                      lvtln model Training                                "
    echo ============================================================================

    # Train the linear Vocal Tract Length Normalization (lVTLN) to get the warping factors.
    # This script does not require to start with a trained model.
    # There is another script (steps/train_lvtln.sh) that requires an initial model.
    ./local/timit_train_lvtln.sh $num_gauss_ubm data/test exp/test_vtln

    # Prepare the data files.
    # We copy it because the following scripts may change the data files.
    mkdir -p data/test_vtln
    cp -r data/test/* data/test_vtln || exit 1
    cp exp/test_vtln/warps/utt2warp data/test_vtln || exit 1

    echo ============================================================================
    echo "          MFCC Feature Extration with lVTLN of data set                   "
    echo ============================================================================

    # Do Mel-frequency cepstral coefficients (mfcc) feature extraction.
    steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj $feat_nj --cmd "$train_cmd" data/test_vtln exp/make_mfcc/test_vtln $mfcc_vtln_dir
    # Compute Cepstral mean and variance normalization (cmvn) of data.
    steps/compute_cmvn_stats.sh data/test_vtln exp/make_mfcc/test_vtln $mfcc_vtln_dir
    # Fixing data format.                                                                               
    utils/fix_data_dir.sh data/test_vtln || exit 1 # remove segments with problems

    echo ============================================================================
    echo "                   Dump the features after CMVN.                          "
    echo ============================================================================

    # Place the lVTLN before the dump.
    # Store the script file of the law mfcc before CMVN.
    cp data/test/feats.scp data/test/raw.scp
    # Dump the features after CMVN.
    local/make_cmvn.sh data/test $mfcc_dir

    # Store the script file of the law mfcc before CMVN.
    cp data/test_vtln/feats.scp data/test_vtln/raw.scp
    # Dump the features after CMVN.
    local/make_cmvn.sh data/test_vtln $mfcc_vtln_dir

    # Create mapping from each utterance to its num of frames.
    paste <(cut -d' ' -f1 data/test/feats.scp) <(while read line; do echo "$line" | feat-to-len scp:- 2>/dev/null; done < data/test/feats.scp) > data/test/utt2num_frames
fi

if [ $stage -le 2 ]; then
    echo ============================================================================
    echo "    Get dpgmm posteriorgrams of the data set. (need access to matlab)     "
    echo ============================================================================

    # Choose the first 3 utterances of testing set.
    mkdir -p dpgmm/test3
    head -3 data/test/raw.scp | copy-feats scp:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > dpgmm/test3/timit_test3_raw.mfcc
    matlab -nodesktop -nosplash -r "addpath('local');run_dpgmm('dpgmm/test3/timit_test3_raw.mfcc');quit"

    # Choose the whole testing set.
    mkdir -p dpgmm/test
    copy-feats scp:data/test/feats.scp ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > dpgmm/test/timit_test_raw.cmvn.mfcc
    copy-feats scp:data/test/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > dpgmm/test/timit_test_raw.cmvn.deltas.mfcc
    copy-feats scp:data/test_vtln/feats.scp ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > dpgmm/test/timit_test_raw.vtln.cmvn.mfcc
    copy-feats scp:data/test_vtln/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    tac dpgmm/test/timit_test_raw.vtln.cmvn.mfcc > dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.reverse

    matlab -r "addpath('local');run_dpgmm('dpgmm/test/timit_test_raw.cmvn.deltas.mfcc');quit"
    matlab -r "addpath('local');run_dpgmm('dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc');quit"

    # from MCMC label sequence to the onehot representation
    cat dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel | python local/labelseq2onehot.py > dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post
fi

if [ $stage -le 3 ]; then
    echo ============================================================================
    echo "       Split posterigram according to different utterances                "
    echo ============================================================================

    # Create mapping from each utterance to its num of frames.
    paste <(cut -d' ' -f1 data/test/feats.scp) <(while read line; do echo "$line" | feat-to-len scp:- 2>/dev/null; done < data/test/feats.scp) > dpgmm/test/test.size
    head -3 dpgmm/test/test.size > dpgmm/test3/test3.size

    # Split the posteriorgram and label to each utterance.
    g++ local/split_post_old.cpp -o local/split_post_old
    mkdir -p dpgmm/test3/data/01.raw.mfcc/cluster_label/
    ./local/split_post_old dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel dpgmm/test3/data/01.raw.mfcc/cluster_label/

    mkdir -p dpgmm/test/data/mfcc.deltas/cluster_label
    ./local/split_post_old dpgmm/test/test.size dpgmm/test/timit_test_raw.cmvn.deltas.mfcc.dpmm.flabel dpgmm/test/data/mfcc.deltas/cluster_label
    mkdir -p dpgmm/test/data/mfcc.vtln.deltas/cluster_label
    ./local/split_post_old dpgmm/test/test.size dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel dpgmm/test/data/mfcc.vtln.deltas/cluster_label
fi

if [ $stage -le 4 ]; then
    echo ============================================================================
    echo "       Get time information from original timit mannal annotation         "
    echo ============================================================================

    # Collect the phn files of timit
    # run command "cp /project/nakamura-lab01/Share/Corpora/Speech/en/TIMIT/TIMIT/TEST/DR1/FCJF0/SI1027.PHN data/test_phn/FCJF0_SI1027.PHN
    #              cp /project/nakamura-lab01/Share/Corpora/Speech/en/TIMIT/TIMIT/TEST/DR1/FCJF0/SA1.PHN data/test_phn/FCJF0_SA1.PHN ...."
    # Note: use only si & sx utterances (no sa utterance) of timit testing corpus, as done in kaldi standard timit corpus.
    mkdir -p data/test_time/test_phn
    find $timit/TEST/ -name *PHN -not \( -iname 'SA*' \) | sed "s:.*/\(.*\)/\(.*\).PHN:cp \0\tdata/test_time/test_phn/\1_\2.PHN:g" | sh
    awk '{print $1 "\t" $3}' conf/phones.60-48-39.map | sed 's:^q\t$:q\tsil:' > conf/phones.61-39.map

    # from timit format to abx <frame_time label> format 
    g++ ./local/timit2abx.cpp -o ./local/timit2abx # Updated timit2abx
    mkdir -p data/test_time/test_time_phn
    for file in data/test_time/test_phn/*; do
	./local/timit2abx $file ./conf/phones.61-39.map > data/test_time/test_time_phn/$(basename $file).abx; # with phone map
    done
    
    # Convert timit format to <begin_frame_time end_frame_time label> format
    mkdir -p data/test_time/test_dur_phn/
    g++ local/timit_normal.cpp -o local/timit_normal
    for file in data/test_time/test_phn/*; do
	./local/timit_normal $file ./conf/phones.61-39.map > data/test_time/test_dur_phn/$(basename $file)
    done

    # Create item_file for timit for abx test
    g++ local/timit_abx_item.cpp -o local/timit_abx_item
    echo "#file onset offset #phone context talker" > data/test_time/timit.item
    for file in data/test_time/test_dur_phn/*; do # normalize the time and label
	./local/timit_abx_item $file
    done | sort -k4,4 -k5,5 >> data/test_time/timit.item
fi

if [ $stage -le 5 ]; then
    echo ============================================================================
    echo "     Get abx time by merging annotated time and mfcc frame time           "
    echo ============================================================================

    # Merge the phn label and cluster label of abx files according to the common time index
    mkdir -p exp/dpgmm/baseline/data/merge_label
    g++ ./local/merge_abx_with_log.cpp -o ./local/merge_abx_with_log

    for file in $(ls data/test_time/test_time_phn/); do
	./local/merge_abx_with_log \
	    data/test_time/test_time_phn/$file dpgmm/test/data/mfcc.vtln.deltas/cluster_label/$(basename $file .PHN.abx).clabel.abx \
	    exp/dpgmm/baseline/data > exp/dpgmm/baseline/data/merge_label/$(basename $file .PHN.abx).mlabel.abx
    done

    # Get the intersection of the annotation time and the frame time
    mkdir -p data/test_time/test_abx_time
    for file in exp/dpgmm/baseline/data/merge_label/*; do
	awk '{print $1}' $file > data/test_time/test_abx_time/$(basename $file .mlabel.abx)
    done
fi

if [ $stage -le 6 ]; then
    echo ============================================================================
    echo "               Evaluate the posteriorgram by ABX test                     "
    echo ============================================================================

    [ -f local/split_post_with_abx_time ] || g++ local/split_post_with_abx_time.cpp -o local/split_post_with_abx_time
    
    root=exp/dpgmm/baseline/deltas
    post_file=dpgmm/test/timit_test_raw.cmvn.deltas.mfcc.dpmm.post
    
    abx_post=eval/abx/post/${root}_post/
    abx_result_cos=eval/abx/result/${root}_post/cos
    abx_result_kl=eval/abx/result/${root}_post/kl

    mkdir -p $abx_post $abx_result_cos $abx_result_kl
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post

    source activate zr15
    python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py $abx_post $abx_result_cos -j 5 --csv
    python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py -kl $abx_post $abx_result_kl -j 5 --csv
fi

if [ $stage -le 7 ]; then
    echo ============================================================================
    echo "               Evaluate the posteriorgram2 by ABX test                     "
    echo ============================================================================

    [ -f local/split_post_with_abx_time ] || g++ local/split_post_with_abx_time.cpp -o local/split_post_with_abx_time
    
    root=exp/dpgmm/baseline/vltn.deltas
    post_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post
    
    abx_post=eval/abx/post/${root}_post/
    abx_result_cos=eval/abx/result/${root}_post/cos
    abx_result_kl=eval/abx/result/${root}_post/kl

    mkdir -p $abx_post $abx_result_cos $abx_result_kl
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post

    source activate zr15
    python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py $abx_post $abx_result_cos -j 5 --csv
    python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py -kl $abx_post $abx_result_kl -j 5 --csv
fi

# if [ $stage -le 8 ]; then
#     echo ============================================================================
#     echo "               Evaluate the posteriorgram by ABX test                     "
#     echo ============================================================================

#     [ -f local/split_post_with_abx_time ] || g++ local/split_post_with_abx_time.cpp -o local/split_post_with_abx_time

#     # first use split_post to get abx format, then fix every file by the abx_time to the abx test folder
#     mkdir -p exp/dpgmm/baseline/deltas
#     cp dpgmm/test/dpgmm/test/timit_test_raw.cmvn.deltas.mfcc.dpmm.flabel exp/dpgmm/baseline/deltas
#     # python local/one_hot.py
    
#     root=exp/dpgmm/baseline/deltas_onehot
#     post_file=exp/dpgmm/baseline/deltas/timit_test_raw.cmvn.deltas.mfcc.dpmm.flabel.onehot
    
#     abx_post=eval/abx/post/${root}_post/
#     abx_result_cos=eval/abx/result/${root}_post/cos
#     abx_result_kl=eval/abx/result/${root}_post/kl

#     mkdir -p $abx_post $abx_result_cos $abx_result_kl
#     ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
#     source activate zr15
#     python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py $abx_post $abx_result_cos -j 5 --csv
#     python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py -kl $abx_post $abx_result_kl -j 5 --csv
# fi

###################################################################
# TODO
# onehot representation; one_hot.py
# eval by mutual information; labels_of_abx_time.cpp to produce labels
###################################################################
# # Make timit label file and dpgmm label file from the merged file
# mkdir -p exp/dpgmm/data/{timit_label,dpgmm_label}
# for file in exp/dpgmm/data/merge_label/*; do
#     awk '{print $1,$2}' $file > exp/dpgmm/data/timit_label/$(basename $file .mlabel.abx).label;
#     awk '{print $1,$3}' $file > exp/dpgmm/data/dpgmm_label/$(basename $file .mlabel.abx).label;
# done

# mkdir -p exp/dpgmm/data/merge
# rm -rf exp/dpgmm/data/merge/{merge,utt2frames,merge_filtered,timit_label,dpgmm_label,time,dpgmm_filtered_label}
# for file in exp/dpgmm/data/merge_label/*;do
#      echo -n $(basename $file .mlabel.abx) " " >> exp/dpgmm/data/merge/utt2frames;
#      wc -l $file  | cut -d' ' -f1 >> exp/dpgmm/data/merge/utt2frames;

#     # echo -n $(basename $file .mlabel.abx) " " >> exp/dpgmm/data/merge/utt2beginendtime;
#     # begin=$(head -1 $file | cut -d' ' -f1)
#     # end=$(tail -1 $file | cut -d' ' -f1)
#     # echo "$begin $end" >> exp/dpgmm/data/merge/utt2beginendtime

#     awk '{print $2, $3}' $file >> exp/dpgmm/data/merge/merge;
#     paste <(awk '{print $2}' $file) <(awk '{print $3}' $file | ./local/label_filter_simp) >> exp/dpgmm/data/merge/merge_filtered;
#     awk '{print $1}' $file >> exp/dpgmm/data/merge/time
#     awk '{print $2}' $file >> exp/dpgmm/data/merge/timit_label
#     awk '{print $3}' $file >> exp/dpgmm/data/merge/dpgmm_label
#     awk '{print $3}' $file | ./local/label_filter_simp >> exp/dpgmm/data/merge/dpgmm_filtered_label
# done

#source activate workspace
# python local/eval_filter.py 

# python local/one_hot.py exp/dpgmm/data/merge/dpgmm_label exp/dpgmm/data/merge/dpgmm_label_one_hot
# python local/one_hot.py exp/dpgmm/data/merge/timit_label exp/dpgmm/data/merge/timit_label_one_hot
# python local/one_hot.py exp/dpgmm/data/merge/dpgmm_filtered_label exp/dpgmm/data/merge/dpgmm_filtered_label_one_hot

# # Prepare one hot representation for abx test.
# mkdir -p abx/post/one_hot/{dpgmm_label,timit_label,dpgmm_filtered_label}
# ./local/split_post.v2 exp/dpgmm/data/merge/utt2frames exp/dpgmm/data/merge/time exp/dpgmm/data/merge/dpgmm_label_one_hot abx/post/one_hot/dpgmm_label
# ./local/split_post.v2 exp/dpgmm/data/merge/utt2frames exp/dpgmm/data/merge/time exp/dpgmm/data/merge/timit_label_one_hot abx/post/one_hot/timit_label
# ./local/split_post.v2 exp/dpgmm/data/merge/utt2frames exp/dpgmm/data/merge/time exp/dpgmm/data/merge/dpgmm_filtered_label_one_hot abx/post/one_hot/dpgmm_filtered_label

# # ABX test for one hot representation
# echo "Start abx test..."
# source activate zr15
# mkdir -p abx/result/one_hot/{dpgmm_label,timit_label,dpgmm_filtered_label}
# python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py -kl abx/post/one_hot/dpgmm_label abx/result/one_hot/dpgmm_label -j 5 --csv
# python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py -kl abx/post/one_hot/timit_label abx/result/one_hot/timit_label -j 5 --csv
# python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py -kl abx/post/one_hot/dpgmm_filtered_label abx/result/one_hot/dpgmm_filtered_label -j 5 --csv
