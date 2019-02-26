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

stage=2

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
    copy-feats scp:data/test_vtln/feats.scp ark:- | add-deltas ark:- ark,t:- | sed -e 's/]//g' -e "s/^\w.*\[//" -e '/^\s*$/d' > dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc

    matlab -r "addpath('local');run_dpgmm('dpgmm/test/timit_test_raw.cmvn.deltas.mfcc');quit"
    matlab -r "addpath('local');run_dpgmm('dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc');quit"
fi

# # Create mapping from each utterance to its num of frames.
# paste <(cut -d' ' -f1 data/test/feats.scp) <(while read line; do echo "$line" | feat-to-len scp:- 2>/dev/null; done < data/test/feats.scp) > dpgmm/test/test.size
# head -3 dpgmm/test/test.size > dpgmm/test3/test3.size

# # Split the posteriorgram and label to each utterance.
# g++ local/split_post.cpp -o local/split_post
# # mkdir -p dpgmm/test3/data/01.raw.mfcc/cluster_post/
# # ./local/split_post dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.post dpgmm/test3/data/01.raw.mfcc/cluster_post/ 
# mkdir -p dpgmm/test3/data/01.raw.mfcc/cluster_label/
# # equivalent command: python local/split_post.py dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel dpgmm/test3/data/01.raw.mfcc/cluster_label/
# ./local/split_post dpgmm/test3/test3.size dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel dpgmm/test3/data/01.raw.mfcc/cluster_label/

# mkdir -p dpgmm/test/data/03.raw.cmvn.deltas.mfcc/cluster_label
# ./local/split_post dpgmm/test/test.size dpgmm/test/timit_test_raw.cmvn.deltas.mfcc.dpmm.flabel dpgmm/test/data/03.raw.cmvn.deltas.mfcc/cluster_label
# mkdir -p dpgmm/test/data/04.raw.vtln.cmvn.deltas.mfcc/cluster_label
# ./local/split_post dpgmm/test/test.size dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel dpgmm/test/data/04.raw.vtln.cmvn.deltas.mfcc/cluster_label

# # Collect the phn files of timit
# # run the command of "cp /project/nakamura-lab01/Share/Corpora/Speech/en/TIMIT/TIMIT/TEST/DR1/FCJF0/SI1027.PHN  data/test_phn/FCJF0_SI1027.PHN
# #                     cp /project/nakamura-lab01/Share/Corpora/Speech/en/TIMIT/TIMIT/TEST/DR1/FCJF0/SA1.PHN     data/test_phn/FCJF0_SA1.PHN
# #                     ...."
# # Note: use only si & sx utterances (no sa utterance) of timit testing corpus, as done in kaldi standard timit corpus.
# mkdir -p data/test_phn
# find $timit/TEST/ -name *PHN -not \( -iname 'SA*' \) | sed "s:.*/\(.*\)/\(.*\).PHN:cp \0\tdata/test_phn/\1_\2.PHN:g" | sh

# # form timit format to abx format
# awk '{print $1 "\t" $3}' conf/phones.60-48-39.map | sed 's:^q\t$:q\tsil:' > conf/phones.61-39.map
# g++ ./local/timit2abx.cpp -o ./local/timit2abx
# mkdir data/test_phn_abx
# mkdir data/test_phn_abx_no_phone_map
# for file in data/test_phn/*; do
#     ./local/timit2abx $file ./conf/phones.61-39.map > data/test_phn_abx/$(basename $file).abx; # with phone map
#     ./local/timit2abx $file > data/test_phn_abx_no_phone_map/$(basename $file).abx; # without phonemap
# done

# # Merge the phn label and cluster label of abx files
# mkdir -p dpgmm/test/data/01.raw.mfcc/merge_label
# mkdir -p dpgmm/test/data/02.raw.vtln.cmvn.mfcc/merge_label
# mkdir -p dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge_label

# g++ ./local/merge_abx.cpp -o ./local/merge_abx

# for file in $(ls data/test_phn_abx/); do
#     ./local/merge_abx data/test_phn_abx/$file dpgmm/test/data/01.raw.mfcc/cluster_label/$(basename $file .PHN.abx).clabel.abx > dpgmm/test/data/01.raw.mfcc/merge_label/$(basename $file .PHN.abx).mlabel.abx
#      ./local/merge_abx data/test_phn_abx/$file dpgmm/test/data/02.raw.vtln.cmvn.mfcc/cluster_label/$(basename $file .PHN.abx).clabel.abx > dpgmm/test/data/02.raw.vtln.cmvn.mfcc/merge_label/$(basename $file .PHN.abx).mlabel.abx
#      ./local/merge_abx data/test_phn_abx/$file dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/cluster_label/$(basename $file .PHN.abx).clabel.abx > dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge_label/$(basename $file .PHN.abx).mlabel.abx
# done

# cat dpgmm/test/data/01.raw.mfcc/merge_label/* | awk '{print $2, $3}' > dpgmm/test/data/01.raw.mfcc/merge
# cat dpgmm/test/data/02.raw.vtln.cmvn.mfcc/merge_label/* | awk '{print $2, $3}' > dpgmm/test/data/02.raw.vtln.cmvn.mfcc/merge
# cat dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge_label/* | awk '{print $2, $3}' > dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge


# # Print the table contain occurance matrix of merged label pair
# cp local/feature2phone.map conf/
# g++ ./local/merge2table.cpp -o ./local/merge2table
# mkdir -p dpgmm/test/data/02.raw.vtln.cmvn.mfcc/tables dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/tables
# cat conf/feature2phone.map | cut  -d' ' -f2 | ./local/merge2table dpgmm/test/data/02.raw.vtln.cmvn.mfcc/merge > dpgmm/test/data/02.raw.vtln.cmvn.mfcc/tables/table
# cat conf/feature2phone.map | cut  -d' ' -f2 | ./local/merge2table dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge > dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/tables/table

# # Print the probability table, entropy table and perplexity table from the table file(to the table directory).
# virtualenv --system-site-packages env 2>/dev/null
# source env/bin/activate
# pip install --upgrade numpy scipy pandas 
# python local/table_stat.py dpgmm/test/data/02.raw.vtln.cmvn.mfcc/tables
# python local/table_stat.py dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/tables

# # Create the a file with each line as utterance name and label sequence pair.
# # The label sequence contains the labels of each frame of the uttrance. 
# for file in dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/cluster_label/*;do
#     echo -n "$(basename $file) "; cat $file| cut -d' ' -f2 | tr '\n' ' '; echo ; done > dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq

# # Extrace the label set from the label_seq file
# cat dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | cut -d' ' -f2- | tr ' ' '\n' | sed '/^$/d' | sort -ug | uniq > dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_set

# mkdir -p fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order{1,2,3}

# g++ local/create_pair.cpp -o local/create_pair
# cp dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_set fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/
# # each line as the labels of each frame of an uttrance.
# cat dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | cut -d' ' -f2- > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq
# # Create the pairs of sequence elements.
# # Pairs symmetric, such as {a, b} {b, a}, only one will be included.
# # Pairs of itself, such as {a, a}, will be excluded
# cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_set | ./local/create_pair > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_pair

# # Compute the functional load for each pairs
# g++ local/replace_pair.cpp -o local/replace_pair
# # Compute the entropy of label sequence.
# ent=$(cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | ngram-count -text - -write-order 1 | sort -k1,1g -k2,2g -k3,3g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py)
# # for each label pair, compute the entropy after merging the pair ($merge_ent) and then the functional load (($ent -  $merge_ent) / $ent).
# # print out <pair, entropy, entropy_after_merge, functional load>
# cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_pair |\
#     while read -r line; do
# 	echo -n "$line ";
# 	merge_ent=$(echo $line | ./local/replace_pair fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | ngram-count -text - -write-order 1 | sort -k1,1g -k2,2g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py);
# 	echo -n "$ent $merge_ent ";python -c "print ($ent -  $merge_ent) / $ent";
#     done > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order1/fl.txt

# # Compute the entropy of label sequence.
# ent=$(cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | ngram-count -text - -write-order 2 | sort -k1,1g -k2,2g -k3,3g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py)
# # for each label pair, compute the entropy after merging the pair ($merge_ent) and then the functional load (($ent -  $merge_ent) / $ent).
# # print out <pair, entropy, entropy_after_merge, functional load>
# cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_pair |\
#     while read -r line; do
# 	echo -n "$line ";
# 	merge_ent=$(echo $line | ./local/replace_pair fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | ngram-count -text - -write-order 2 | sort -k1,1g -k2,2g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py);
# 	echo -n "$ent $merge_ent ";python -c "print ($ent -  $merge_ent) / $ent";
#     done > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order2/fl.txt

# # Compute the entropy of label sequence.
# ent=$(cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | ngram-count -text - -write-order 3 | sort -k1,1g -k2,2g -k3,3g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py)
# # for each label pair, compute the entropy after merging the pair ($merge_ent) and then the functional load (($ent -  $merge_ent) / $ent).
# # print out <pair, entropy, entropy_after_merge, functional load>
# cat fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_pair |\
#     while read -r line; do
# 	echo -n "$line ";
# 	merge_ent=$(echo $line | ./local/replace_pair fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_seq | ngram-count -text - -write-order 3 | sort -k1,1g -k2,2g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py);
# 	echo -n "$ent $merge_ent ";python -c "print ($ent -  $merge_ent) / $ent";
#     done > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/fl.txt

# # Merge fl with unigram, bigram and trigram. (order1, order2, order3)
# # in the format <pair, unigram_fl, bigram_fl, trigram_fl>
# paste fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_pair <(awk '{print $5}' fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order1/fl.txt) <(awk '{print $5}' fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order2/fl.txt) <(awk '{print $5}' fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/fl.txt) > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/label_pair_fl123

# # Compute the perplexity after merging cluster labels according to the dendrogram by functional load.
# cp dpgmm/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge
# # Generate the dendrogram according to the fl, and then determine the order of merging cluster labels according to the dendrogram.
# awk '{print $5}' fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/fl.txt |\
#     python local/dend_merge_order.py fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/merge_order.txt
# g++ local/dend_merge.cpp -o local/dend_merge

# # Prepare files for dumping the perplexties after each merge.
# mkdir -p fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl
# cat /dev/null > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl/table_ppls
# cat /dev/null > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl/table_ppls_col

# # for tmp_table and tmp_merge files
# mkdir -p tmp

# # Create empty ppl files.
# cat /dev/null > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl/table_ppls
# cat /dev/null > fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl/table_ppls_col
# line_count=$(wc -l fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/merge_order.txt | cut -d' ' -f1)
# for i in $(seq 0 1 $line_count); do
#     # Merge the merge_file according to the merge order.
#     head -n $i fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/merge_order.txt |\
# 	./local/dend_merge fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/merge > tmp/merge;
#     # Convert the merged merge_file to table format
#     cat conf/feature2phone.map | cut  -d' ' -f2 | ./local/merge2table tmp/merge > tmp/table;
#     # Compute the perplexities for each merge of cluster labels, and dump these ppls to the ppl files.
#     python local/table2ppl.py tmp/table fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl;
# done

# # remove the tmp directory with tmp files
# rm -rf tmp

# # Create he dendrogram of cluster labels based on fl.
# # ssh with -Y; and run on machine with python-tk such as ahcclp02.
# python local/dend.py "fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/fl.txt" "fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/dendrogram_complete_fl_tri.png"

# # Read the perplexity table from the ppl_dir,
# # print the phoneme ppl table, the feature ppl table and the normalized ones.
# sed -e 's/_u//g' -e 's/_v//g' conf/feature2phone.map > conf/simplefeature2phone.map 
# python local/create_norm_ppl_table.py fl/test/data/03.raw.vtln.cmvn.deltas.mfcc/order3/ppl conf/simplefeature2phone.map
