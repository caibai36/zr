stage=4
curdir=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/egs/timit/s0/exp/sandbox/analysis/cmp # data and file dir
timit=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/egs/timit/s0
cd $timit # running dir

if [ $stage -le 0 ]; then
    # create a cmp file of line no. as frame index and with underground truth, DPGMM label and RNN label info
    dpgmm=eval/abx/result/exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post_post/mi
    rnn0=eval/abx/result/exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b0.post_post/mi
    rnn4=eval/abx/result/exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b4.post_post/mi
    rnn8=eval/abx/result/exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b8.post_post/mi
    rnn16=eval/abx/result/exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/mi
    echo {$dpgmm,$rnn0,$rnn4,$rnn8,$rnn16}/pair.txt
    echo -e "phoneme\tdpgmm\trnn0\trnn4\trnn8\trnn16" > $curdir/pairs.txt
    paste {$dpgmm,$rnn0,$rnn4,$rnn8,$rnn16}/pair.txt | awk '{print $2, $1, $3, $5, $7, $9}' OFS='\t' >> $curdir/pairs.txt
fi

if [ $stage -le 1 ]; then
    # create frame index for each utterance
    mkdir -p $curdir/time
    cp data/test/utt2num_frames_abx_time $curdir/time
    awk '{s+=$2} {print $1,s}' data/test/utt2num_frames_abx_time > $curdir/time/utt2accumulated_num_frames.txt
    awk 'BEGIN {s=0} {s0=s} {s+=$2} {print $1,s0,s}' data/test/utt2num_frames_abx_time > $curdir/time/utt2accumulated_beginframe_endframe.txt
fi

if [ $stage -le 2 ]; then
    # split the cmp file according to the different utterances
    mkdir -p $curdir/post
    sed '1 d' $curdir/pairs.txt > $curdir/pairs2.txt
    ./local/split_post $curdir/time/utt2num_frames_abx_time $curdir/pairs2.txt $curdir/post
    rm $curdir/pairs2.txt
fi

if [ $stage -le 3 ]; then
    outfile=${curdir}/utt2allvmeasure
    echo "utt DPGMM_homo DPGMM_comp DPGMM_v RNN0_homo RNN0_comp RNN0_v RNN4_homo RNN4_comp RNN4_v RNN8_homo RNN8_comp RNN8_v RNN16_homo RNN16_comp RNN16_v" | tr ' ' '\t' > $outfile
    awk '{print $1}' $curdir/time/utt2num_frames_abx_time | while read -r utt; do
	echo -ne "${utt}\t";
	file=$curdir/post/${utt}.post;
	paste -d' ' \
	      <(awk '{print $2, $3}' $file | python $curdir/homo_comp_v.py) \
	      <(awk '{print $2, $4}' $file | python $curdir/homo_comp_v.py) \
	      <(awk '{print $2, $5}' $file | python $curdir/homo_comp_v.py) \
	      <(awk '{print $2, $6}' $file | python $curdir/homo_comp_v.py) \
	      <(awk '{print $2, $7}' $file | python $curdir/homo_comp_v.py) ;
    done | tr ' ' '\t' >> $outfile
fi

if [ $stage -le 4 ]; then
    # add the feature as the first line
    # awk 'BEGIN {a["phoneme"] = "feature"} NR==FNR {a[$2]=$1; next} {print a[$1],$0}' OFS='\t' conf/feature2phone.map $curdir/pairs.txt > $curdir/fpairs.txt
    awk 'BEGIN {pid["phoneme"] = "phoneme_id"; p2f["phoneme"] = "feature"} NR==FNR {pid[$2] = NR; p2f[$2]=$1; next} {print p2f[$1], $0, pid[$1]}' OFS="\t" conf/feature2phone.map $curdir/pairs.txt > $curdir/pairs_all.txt
fi
