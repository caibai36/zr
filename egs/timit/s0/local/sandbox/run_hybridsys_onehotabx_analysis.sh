abx=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/tools/abx/ABXpy-zerospeech2015 # CHECKME
source activate zr15

echo ============================================================================
echo "              Evaluate the representation by ABX test                     "
echo ============================================================================

for dir in $(ls -d eval/abx/post/exp/hybrid_onehot/*/*flabel*{b16,onehot}*post); do
    abx_post=$dir
    abx_result=$(echo $dir | sed 's:post:result:')
    echo $abx_result

    abx_result_cos=$abx_result/cos/analysis
    abx_result_kl=$abx_result/kl/analysis
    abx_result_edit=$abx_result/edit/analysis

    mkdir -p $abx_result_cos $abx_result_kl $abx_result_edit

    source activate zr15
    python $abx/bin/timit_analysis_eval1.py --distance $abx/resources/distance.distance      $abx_post $abx_result_cos -j 10 --csv
    python $abx/bin/timit_analysis_eval1.py --distance $abx/resources/distance.kl_divergence $abx_post $abx_result_kl -j 10 --csv
    python $abx/bin/timit_analysis_eval1.py --distance $abx/resources/distance.edit_distance $abx_post $abx_result_edit -j 10 --csv
done
