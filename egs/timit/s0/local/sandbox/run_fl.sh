. path.sh
mkdir -p exp/test_fl
mi_dir=eval/abx/result/exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.b16.post_post/mi
awk '{print $1}' $mi_dir/pair.txt > exp/test_fl/framelabelb16.txt
python local/frame2seg.py --input_file=exp/test_fl/framelabelb16.txt > exp/test_fl/segcountb16.txt
awk '{print $1}' exp/test_fl/segcountb16.txt > exp/test_fl/seg.txt
awk '{print $2}' eval/abx/result/exp/hybrid/mse/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post.b0.post_post/mi/pair.txt > exp/test_fl/phone.txt

echo ============================================================================
echo "       Greedily merge labels of text according to functional load         "
echo ============================================================================

# # Need python lib. to compute entropy.
# # source $abx/env/bin/activate

# Create pairs for a label set.
# Pairs symmetric, such as {a, b} {b, a}, only one will be included.
# Pairs of itself, such as {a, a}, will be excluded
[ -f local/create_pair ] || g++ local/create_pair.cpp -o local/create_pair
# replace pair (x, y) in the text.
# All labels x in text will be replaced by y.
[ -f local/replace_pair ] || g++ local/replace_pair.cpp -o local/replace_pair

text=exp/test_fl/seg.txt
# here order have to be 1, because we are not
# in the format of one line one sentence (<s>...<\s>)
order=1

local=exp/test_fl/local
log=exp/test_fl/logs
mkdir -p $local $log

echo -n > $log/log.txt
num=$(cat "$text" | tr ' ' '\n' | sed '/^$/d' | sort -ug | uniq | wc -l) 

while [[ $num -ne 1 ]]; do
    dir=$local/$num
    mkdir -p $dir

    # Create the label set, pairs, and text.
    cp "$text" $dir/text
    cat $dir/text > $dir/label_seq
    cat $dir/text | tr ' ' '\n' | sed '/^$/d' | sort -ug | uniq > $dir/label_set
    cat $dir/label_set | ./local/create_pair > $dir/label_pair

    # Print out functional load of all pairs of labels. (fl = ($ent -  $merge_ent) / $ent).
    # print out <pair, entropy, entropy_after_merge, functional load>
    ent=$(cat $dir/label_seq | ngram-count -text - -write-order $order | sort -k1,1g -k2,2g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py)
    echo "date: $(date)" |& tee -a $log/log.txt
    echo "#ofLabels: $(wc -l $dir/label_set | cut -d' ' -f1) Entropy: $ent"  |& tee -a $log/log.txt

    FLIsZero="" # if functional load is zero, then just stop.
    cat $dir/label_pair | \
        while read -r line && [[ $FLIsZero != "TRUE" ]]; do
    	echo -n "$line ";
    	merge_ent=$(echo $line | ./local/replace_pair $dir/label_seq | ngram-count -text - -write-order $order | sort -k1,1g -k2,2g | grep -vE '<s>|</s>' | rev | cut -f1 | rev | python local/counts2entropy.py);
    	echo -n "$ent $merge_ent ";python -c "print(($ent -  $merge_ent) / $ent)";
	FLIsZero=$(python -c "if (($ent -  $merge_ent) / $ent) == 0 : print('TRUE')")
        done > $dir/fl.txt

    echo "MergedPair: $(cat $dir/fl.txt | sort -k5,5g | head -1)" |& tee -a $log/log.txt

    # Find the pair with minimum functional load; merge them in current text to get the text for next iteration.
    echo $(cat $dir/fl.txt | sort -k5,5g | head -1 | cut -d' ' -f1-2) | ./local/replace_pair $dir/label_seq | tr '\t' ' ' > $dir/next_text
    text=$dir/next_text
    
    echo $((num--)) > /dev/null
done
