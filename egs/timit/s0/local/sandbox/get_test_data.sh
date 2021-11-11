stage=3
#feat=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
feat_name=mfcc_vtln

st_dir=data/test_time/test_source_target
cur_dir=$st_dir/$feat_name
mkdir -p $cur_dir/tmp/time_feat

if [ $stage -le 1 ]; then
    # get feat with time of each utterance, each frame has one label in annotation.
    [ -f local/split_post_with_abx_time ] || g++ local/split_post_with_abx_time.cpp -o local/split_post_with_abx_time
    ./local/split_post_with_abx_time data/test/utt2num_frames $feat data/test_time/test_abx_time $cur_dir/tmp/time_feat
fi

if [ $stage -le 2 ]; then
    # Create source and target (with utt2num_frames)
    awk '{print $1}' data/test/feats.scp  | while read -r uttid; do cat $cur_dir/tmp/time_feat/${uttid}.post | tr -s ' ' | sed -e 's/^ //g' -e 's/ $//' | cut -d' ' -f2- ; done > $cur_dir/sources.txt
    awk '{print $1}' data/test/feats.scp  | while read -r uttid; do echo "$uttid\t$(wc -l $cur_dir/tmp/time_feat/${uttid}.post | cut -d' ' -f1)"; done > $cur_dir/utt2num_frames
    awk '{print $1}' data/test/feats.scp  | while read -r uttid; do cat data/test_time/test_time_phn/${uttid}.PHN.abx | awk '{print $2}'; done > $cur_dir/target_phns.txt
fi

if [ $stage -le 3 ]; then
    # Convert phone to id
    cat $cur_dir/target_phns.txt | sort -u | awk '{print $0"\t"NR-1}' > $cur_dir/phn2id.txt
    awk -v f1=$cur_dir/phn2id.txt -v f2=$cur_dir/target_phns.txt 'BEGIN {while(getline < f1) {split($0, a, "\t"); phn2id[a[1]]=a[2]} while(getline < f2) {print(phn2id[$0])}}' > $cur_dir/target_ids.txt
fi

if [$stage -le 4 ]; then
    mv data/test_time/test_source_target/mfcc_vtln/tmp/time_feat/ data/test_time/test_time_mfcc_vtln
fi
