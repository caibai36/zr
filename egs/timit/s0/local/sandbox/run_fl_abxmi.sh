abx=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/tools/abx/ABXpy-zerospeech2015  # CHECKME
stage=1

run_fl_abxmi() {
    num=$1
    # cluster label of each frame
    paste  <(cat exp/test_fl/local/$num/label_seq)  <(awk '{print $2}' exp/test_fl/segcountb16.txt) | python local/seg2frames.py > exp/test_fl/local/$num/frames
    # cluster label to onehot representation to eval abx
    cat exp/test_fl/local/$num/frames | python local/labelseq2onehot.py > exp/test_fl/local/$num/frames_onehot

    echo ============================================================================
    echo "              Evaluate the representation by ABX test                     "
    echo ============================================================================
    [ -f local/split_post ] || g++ local/split_post.cpp  -o local/split_post

    file=exp/test_fl/local/${num}/frames_onehot
    echo $file
    base=$(basename $file)

    root=exp/test_fl/local/${num}/${base}
    post_file=$file

    abx_post=eval/abx/post/${root}_post/
    abx_result_cos=eval/abx/result/${root}_post/cos
    abx_result_kl=eval/abx/result/${root}_post/kl
    abx_result_edit=eval/abx/result/${root}_post/edit

    mkdir -p $abx_post $abx_result_cos $abx_result_kl $abx_result_edit
    ./local/split_post data/test/utt2num_frames_abx_time $post_file $abx_post
    # some timit annotation not start from time 0
    for file in MCMB0_SI638 MGJF0_SI641 MGJF0_SX101 MGJF0_SX281 MSFH1_SI640; do paste data/test_time/test_abx_time/$file <(cut -d' ' -f2- eval/abx/post/exp/test_fl/local/${num}/frames_onehot_post/${file}.post) | tr '\t' ' ' > bak/tmp; mv bak/tmp eval/abx/post/exp/test_fl/local/${num}/frames_onehot_post/$file.post; done

    source activate zr15
    python $abx/bin/timit_eval1.py --distance $abx/resources/distance.distance      $abx_post $abx_result_cos -j 10 --csv
    python $abx/bin/timit_eval1.py --distance $abx/resources/distance.kl_divergence $abx_post $abx_result_kl -j 10 --csv
    python $abx/bin/timit_eval1.py --distance $abx/resources/distance.edit_distance $abx_post $abx_result_edit -j 10 --csv

    echo ============================================================================
    echo "                 Evaluate the representation by MI                        "
    echo ============================================================================
    source activate mlp
    mi_result=eval/abx/result/${root}_post/mi
    mkdir -p $mi_result
    paste exp/test_fl/local/${num}/frames exp/test_fl/phone.txt > $mi_result/pair.txt
    python local/eval_mi.py $mi_result/pair.txt | tee $mi_result/mi_result.txt
}

for num in 88 86 84 82 80 78 76 74 72 70; do
    echo "number of labels: " $num;
    run_fl_abxmi $num
done
