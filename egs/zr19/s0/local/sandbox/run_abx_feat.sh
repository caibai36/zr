stage=5
if [ $stage -le 5 ]; then
    echo "---------------------------------------------------"
    echo "Evaluate the representation by ABX test"
    echo "---------------------------------------------------"

    mkdir -p local/bin
    [ -f local/bin/split_post_seg ] || g++ local/split_post_seg.cpp -o local/bin/split_post_seg

    file=exp/dpgmm/data/test.vtln.deltas.mfcc
    echo $(basename $file)
    base=$(basename $file)
    root=exp/dpgmm/mfcc/${base}
    evalids=conf/eval_uttids.txt

    abx_post=eval/abx/post/${root}/
    abx_result_cos=eval/abx/result/${root}/cos
    abx_result_kl=eval/abx/result/${root}/kl
    post_file=$file
    segments_sorted=exp/dpgmm/data/test_segments_sorted

    mkdir -p $abx_post $abx_result_cos $abx_result_kl
    ./local/bin/split_post_seg data/test/utt2num_frames $post_file $segments_sorted $abx_post

    while read -r line; do
    	file=$abx_post/${line}.pos;
	# modify postfix. eg: 146f_0584.pos -> 146f_0584.txt
	# Remove the first time column, squeeze the spaces and cut the head and tail blanks
    	cat $file  | tr -s ' ' | cut -d' ' -f2- | sed -e 's/^ //' -e 's/ $//' > $(echo $file | sed "s:pos$:txt:")
    done < $evalids
    rm $abx_post/*.pos

    source activate eval

     # cp -r ../zs19_docker/system/ .
    ./local/eval.sh --DIST 'cos' --EMB $abx_post --RES $abx_result_cos
fi

# if [ $stage -le 5 ]; then
#     echo "---------------------------------------------------"
#     echo "Evaluate the representation by ABX test"
#     echo "---------------------------------------------------"

#     mkdir -p local/bin
#     [ -f local/bin/split_post_seg ] || g++ local/split_post_seg.cpp -o local/bin/split_post_seg

#     file=exp/dpgmm/data/test.vtln.mfcc
#     echo $(basename $file)
#     base=$(basename $file)
#     root=exp/dpgmm/mfcc/${base}
#     evalids=conf/eval_uttids.txt

#     abx_post=eval/abx/post/${root}/
#     abx_result_cos=eval/abx/result/${root}/cos
#     abx_result_kl=eval/abx/result/${root}/kl
#     post_file=$file
#     segments_sorted=exp/dpgmm/data/test_segments_sorted

#     mkdir -p $abx_post $abx_result_cos $abx_result_kl
#     ./local/bin/split_post_seg data/test/utt2num_frames $post_file $segments_sorted $abx_post

#     while read -r line; do
#     	file=$abx_post/${line}.pos;
# 	# modify postfix. eg: 146f_0584.pos -> 146f_0584.txt
# 	# Remove the first time column, squeeze the spaces and cut the head and tail blanks
#     	cat $file  | tr -s ' ' | cut -d' ' -f2- | sed -e 's/^ //' -e 's/ $//' > $(echo $file | sed "s:pos$:txt:")
#     done < $evalids
#     rm $abx_post/*.pos

#     source activate eval

#      # cp -r ../zs19_docker/system/ .
#     ./local/eval.sh --DIST 'cos' --EMB $abx_post --RES $abx_result_cos
# fi
