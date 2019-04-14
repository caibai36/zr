stage=0

date
if [ $stage -le 0 ]; then
    echo "Creating post file for posteriorgram"
    abx=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/tools/abx # CHECKME
    [ -f local/split_post_with_abx_time ] || g++ local/split_post_with_abx_time.cpp -o local/split_post_with_abx_time

    for file in exp/hybrid/ce/*f[0-9]*.post; do
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
fi

date
if [ $stage -le 1 ]; then
    echo "Convert posteriorgram to onehot representation."
    source activate mlp
    for dir in $(ls -d eval/abx/post/exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn*f[0-9]*post); do
	date
	echo $dir
	bash local/dirpost2dironehot.sh $dir $(echo $dir | sed 's/hybrid/hybrid_onehot/')
    done
fi

date
if [ $stage -le 2 ]; then
    echo "Evaluate the representation of ABX test"
    abx=/project/nakamura-lab08/Work/bin-wu/workspace/projects/zr/tools/abx/ABXpy-zerospeech2015 # CHECKME
    source activate zr15

    for dir in $(ls -d eval/abx/post/exp/hybrid_onehot/ce/*f[0-9]*post); do
	abx_post=$dir
	abx_result=$(echo $dir | sed 's:post:result:')
	echo $abx_result

	abx_result_cos=$abx_result/cos
	abx_result_kl=$abx_result/kl
	abx_result_edit=$abx_result/edit

	mkdir -p $abx_result_cos $abx_result_kl $abx_result_edit

	source activate zr15
	python $abx/bin/timit_eval1.py --distance $abx/resources/distance.distance      $abx_post $abx_result_cos -j 10 --csv
	python $abx/bin/timit_eval1.py --distance $abx/resources/distance.kl_divergence $abx_post $abx_result_kl -j 10 --csv
	python $abx/bin/timit_eval1.py --distance $abx/resources/distance.edit_distance $abx_post $abx_result_edit -j 10 --csv
    done
fi
