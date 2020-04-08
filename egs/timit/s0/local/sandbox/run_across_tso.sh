tso=/project/nakamura-lab08/Work/bin-wu/workspace/projects/bak/dpgmm/zerospeech/xitsonga
mkdir -p exp/across_tso/data
cp $tso/dpgmm/test/tso_test_raw.vtln.cmvn.deltas.mfcc  exp/across_tso/data/
cp $tso/dpgmm/test/frames_per_utt exp/across_tso/data/utt2num_frames
cp $tso/dpgmm/test/segments_sorted exp/across_tso/data/segment_sorted
cp $tso/local/split_post_seg.cpp local/split_post_seg.cpp
mkdir -p abx/across_tso_post/dpgmm_post

source activate mlp
source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
test_source_file=exp/across_tso/data/tso_test_raw.vtln.cmvn.deltas.mfcc
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=16
output_file=exp/across_tso/data/tso_test_raw.vtln.cmvn.deltas.mfcc.across.flable.b16.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce_across.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --test_source_file=$test_source_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file}

g++ local/split_post_seg.cpp -o local/split_post_seg
./local/split_post_seg exp/across_tso/data/utt2num_frames exp/across_tso/data/tso_test_raw.vtln.cmvn.deltas.mfcc.across.flable.b16.post exp/across_tso/data/segment_sorted abx/across_tso_post/dpgmm_post

# add prefix. eg: 146f_0584.pos -> nchlt_tso_146f_0584.pos
for file in abx/across_tso_post/dpgmm_post/*;do
    mv $file $(echo $file | sed -r "s:(.*/)(.*).pos:\1nchlt_tso_\2.pos:");
done

echo ============================================================================
echo "         Evaluate the posteriorgram of dpgmm using abx test               "
echo ============================================================================
mkdir -p abx/across_tso_result/dpgmm_post_kl/
abx=../../../tools/abx
source activate zr15
python $abx/ABXpy-zerospeech2015/bin/xitsonga_eval1.py -kl abx/across_tso_post/dpgmm_post/ abx/across_tso_result/dpgmm_post_kl/ -j 5
