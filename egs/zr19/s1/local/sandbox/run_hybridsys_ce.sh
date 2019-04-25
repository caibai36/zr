# mkdir -p exp/hybrid/ce
# cp exp/dpgmm/data/{train*vtln*,*vtln*post} exp/dpgmm/data/test.vtln.deltas.mfcc exp/hybrid/ce/
source_file=exp/hybrid/ce/train.vtln.deltas.mfcc
target_file=exp/hybrid/ce/train.vtln.deltas.mfcc.dpmm.flabel
test_source_file=exp/hybrid/ce/test.vtln.deltas.mfcc
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=0
output_file=${target_file/train/test}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --test_source_file=$test_source_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/train.vtln.deltas.mfcc
target_file=exp/hybrid/ce/train.vtln.deltas.mfcc.dpmm.flabel
test_source_file=exp/hybrid/ce/test.vtln.deltas.mfcc
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=4
output_file=${target_file/train/test}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --test_source_file=$test_source_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/train.vtln.deltas.mfcc
target_file=exp/hybrid/ce/train.vtln.deltas.mfcc.dpmm.flabel
test_source_file=exp/hybrid/ce/test.vtln.deltas.mfcc
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=8
output_file=${target_file/train/test}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --test_source_file=$test_source_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/train.vtln.deltas.mfcc
target_file=exp/hybrid/ce/train.vtln.deltas.mfcc.dpmm.flabel
test_source_file=exp/hybrid/ce/test.vtln.deltas.mfcc
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=16
output_file=${target_file/train/test}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --test_source_file=$test_source_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/train.vtln.deltas.mfcc
target_file=exp/hybrid/ce/train.vtln.deltas.mfcc.dpmm.flabel
test_source_file=exp/hybrid/ce/test.vtln.deltas.mfcc
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=24
output_file=${target_file/train/test}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --test_source_file=$test_source_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

source_file=exp/hybrid/ce/train.vtln.deltas.mfcc
target_file=exp/hybrid/ce/train.vtln.deltas.mfcc.dpmm.flabel
test_source_file=exp/hybrid/ce/test.vtln.deltas.mfcc
num_epochs=20
batch_size=256
print_interval=10000
hidden_dim=512
num_layers=3
num_left_context=32
output_file=${target_file/train/test}.b${num_left_context}.post
echo ${source_file}
echo ${target_file}
echo ${output_file}
python local/hybird_sys_ce.py \
       --source_file=$source_file \
       --target_file=$target_file \
       --test_source_file=$test_source_file \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size \
       --print_interval=$print_interval \
       --hidden_dim=$hidden_dim \
       --num_layers=$num_layers \
       --num_left_context=$num_left_context \
       --output_file=${output_file} | tee ${target_file}.b${num_left_context}.log

# for file in exp/hybrid/ce/train*post;do $(echo -en "mv $file "; echo $file | sed 's/train/test/'); done
