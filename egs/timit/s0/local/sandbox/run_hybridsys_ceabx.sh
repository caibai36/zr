abx=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/tools/abx # CHECKME
stage=1

echo ============================================================================
echo "              Evaluate the representation by ABX test                     "
echo ============================================================================
[ -f local/split_post_with_abx_time ] || g++ local/split_post_with_abx_time.cpp -o local/split_post_with_abx_time

for file in exp/hybrid/ce/*post; do
    echo $(basename $file)
    base=$(basename $file)
    
    root=exp/hybrid/ce/${base}
    post_file=$file
    
    abx_post=eval/abx/post/${root}_post/
    abx_result_cos=eval/abx/result/${root}_post/cos
    abx_result_kl=eval/abx/result/${root}_post/kl

    mkdir -p $abx_post $abx_result_cos $abx_result_kl
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post

    source activate zr15
    python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py $abx_post $abx_result_cos -j 5 --csv
    python $abx/ABXpy-zerospeech2015/bin/timit_eval1.py -kl $abx_post $abx_result_kl -j 5 --csv
done
