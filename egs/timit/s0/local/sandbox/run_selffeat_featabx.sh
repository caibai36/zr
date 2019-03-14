abx=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/tools/abx # CHECKME
stage=1

mkdir -p exp/selffeat/feat/
# cp dpgmm/test/*vtln*.mfcc{,.s*,.m*} exp/selffeat/feat/ # run on shell

echo ============================================================================
echo "              Evaluate the representation by ABX test                     "
echo ============================================================================
[ -f local/split_post_with_abx_time ] || g++ local/split_post_with_abx_time.cpp -o local/split_post_with_abx_time

for file in exp/selffeat/feat/*; do
    echo $(basename $file)
    base=$(basename $file)
    
    root=exp/selffeat/feat/${base}
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

# (mlp) [bin-wu@ahcgpc02 s0]$(master) ls  dpgmm/test/*vtln*.mfcc{,.s*,.m*} | tr -s ' ' '\n'
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s4t1
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s4t4
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s8t1
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s8t4
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s8t8
# dpgmm/test/timit_test_raw.vtln.cmvn.mfcc
# dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.merge.s4t4
# dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.merge.s8t8
# dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.s4t4
# dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.s8t8
