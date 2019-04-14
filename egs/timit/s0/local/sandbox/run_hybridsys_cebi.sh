date
source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=0
num_right_context=4
output_file=${target_file}.b${num_left_context}f${num_right_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_cebi.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --num_right_context=$num_right_context \
       --output_file=${output_file}
date
source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=0
num_right_context=8
output_file=${target_file}.b${num_left_context}f${num_right_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_cebi.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --num_right_context=$num_right_context \
       --output_file=${output_file}

date
source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=0
num_right_context=16
output_file=${target_file}.b${num_left_context}f${num_right_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_cebi.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --num_right_context=$num_right_context \
       --output_file=${output_file}

date
source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=2
num_right_context=2
output_file=${target_file}.b${num_left_context}f${num_right_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_cebi.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --num_right_context=$num_right_context \
       --output_file=${output_file}

date
source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=4
num_right_context=4
output_file=${target_file}.b${num_left_context}f${num_right_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_cebi.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --num_right_context=$num_right_context \
       --output_file=${output_file}

date
source_file=exp/hybrid/ce/timit_test_raw.vtln.cmvn.deltas.mfcc
target_file=exp/hybrid/ce/v2_timit_test_raw.vtln.cmvn.deltas.mfcc.dpmm.flabel
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=8
num_right_context=8
output_file=${target_file}.b${num_left_context}f${num_right_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_cebi.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --num_right_context=$num_right_context \
       --output_file=${output_file}
