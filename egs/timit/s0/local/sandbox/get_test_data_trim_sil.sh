stage=3
#feat=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
feat_name=mfcc_vtln

root_dir=data/test_time_trim_sil
cur_dir=$root_dir/test_source_target/$feat_name
mkdir -p $root_dir $cur_dir

if [ $stage -le 1 ]; then
    # get index with silence trimed (eg "sil sil I'm here sil sil" with begin index 2(included) 4(not included))
    cmd='import sys; phns = [line.strip().split()[1] for line in sys.stdin]; indexes = [pos for pos, phn in enumerate(phns) if phn != "sil"]; print("{} {}".format(min(indexes), max(indexes) + 1))'
    awk '{print $1}' data/test/feats.scp  | while read -r uttid; do cat data/test_time/test_time_phn/${uttid}.PHN.abx | echo $uttid $(python -c "$cmd"); done > $root_dir/timit_trim_sil_index
fi

if [ $stage -le 2 ]; then
    # trim the sil frames
    feat_dir=$root_dir/test_time_mfcc_vtln
    phn_dir=$root_dir/test_time_phn
    time_dir=$root_dir/test_abx_time
    mkdir -p $feat_dir $phn_dir $time_dir
    
    cat $root_dir/timit_trim_sil_index | while read -r line; \
	do uttid=$(cut -d' ' -f1 <<<"$line");begin=$(cut -d' ' -f2 <<<"$line");end=$(cut -d' ' -f3 <<<"$line"); \
	   awk -v begin=$begin -v end=$end '(NR-1)>=begin && (NR-1)<end {print}' data/test_time/test_time_mfcc_vtln/${uttid}.post > $feat_dir/${uttid}.post; done

    cat $root_dir/timit_trim_sil_index | while read -r line; \
    	do uttid=$(cut -d' ' -f1 <<<"$line");begin=$(cut -d' ' -f2 <<<"$line");end=$(cut -d' ' -f3 <<<"$line"); \
    	   awk -v begin=$begin -v end=$end '(NR-1)>=begin && (NR-1)<end {print}' data/test_time/test_time_phn/${uttid}.PHN.abx > $phn_dir/${uttid}.PHN.abx; done

    cat $root_dir/timit_trim_sil_index | while read -r line; \
    	do uttid=$(cut -d' ' -f1 <<<"$line");begin=$(cut -d' ' -f2 <<<"$line");end=$(cut -d' ' -f3 <<<"$line"); \
    	   awk -v begin=$begin -v end=$end '(NR-1)>=begin && (NR-1)<end {print}' data/test_time/test_abx_time/${uttid} > $time_dir/${uttid}; done
fi

if [ $stage -le 3 ]; then
    # Create source and target (with utt2num_frames)
    awk '{print $1}' data/test/feats.scp  | while read -r uttid; do cat $root_dir/test_time_mfcc_vtln/${uttid}.post | tr -s ' ' | sed -e 's/^ //g' -e 's/ $//' | cut -d' ' -f2- ; done > $cur_dir/sources.txt
    awk '{print $1}' data/test/feats.scp  | while read -r uttid; do echo -e "$uttid\t$(wc -l $root_dir/test_time_mfcc_vtln/${uttid}.post | cut -d' ' -f1)"; done > $cur_dir/utt2num_frames
    awk '{print $1}' data/test/feats.scp  | while read -r uttid; do cat $root_dir/test_time_phn/${uttid}.PHN.abx | awk '{print $2}'; done > $cur_dir/target_phns.txt
fi

if [ $stage -le 4 ]; then
    # Convert phone to id
    cat $cur_dir/target_phns.txt | sort -u | awk '{print $0"\t"NR-1}' > $cur_dir/phn2id.txt
    awk -v f1=$cur_dir/phn2id.txt -v f2=$cur_dir/target_phns.txt 'BEGIN {while(getline < f1) {split($0, a, "\t"); phn2id[a[1]]=a[2]} while(getline < f2) {print(phn2id[$0])}}' > $cur_dir/target_ids.txt
fi
