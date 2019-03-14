# source_file=dpgmm/test3/timit_test3_raw.mfcc
# target_file=dpgmm/test3/timit_test3_raw.mfcc.dpmm.flabel
# num_epochs=20
# batch_size=256
# print_interval=400
# hidden_dim=512
# num_layers=3
# num_left_context=0
# output_file=${target_file}.b${num_left_context}.post
# echo ${source_file}
# echo ${target_file}
# echo ${output_file}
# python local/hybird_sys_ce.py \
#        --source_file=$source_file \
#        --target_file=$target_file \
#        --num_epochs=$num_epochs \
#        --batch_size=$batch_size \
#        --print_interval=$print_interval \
#        --hidden_dim=$hidden_dim \
#        --num_layers=$num_layers \
#        --num_left_context=$num_left_context \
#        --output_file=${output_file} | tee ${input_file}.s${num_sources}t${num_targets}.log

# mkdir -p exp/hybrid/ce
# cp dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc* exp/hybrid/ce/
# cp exp/selffeat/post/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
# cp exp/selffeat/post/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.post

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=0
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=0
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=4
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=4
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=8
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=8
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=16
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=16
output_file=${target_file}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

# cat exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel | python local/labelseq2onehot.py > exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post
# cat exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel | python local/labelseq2onehot.py > exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel.onehot.post
