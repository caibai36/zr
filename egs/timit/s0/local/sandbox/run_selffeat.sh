# num_sources=2
# num_targets=3
# input_file=dpgmm/test3/timit_test3_raw.mfcc
# echo ${input_file}
# echo ${input_file}.s${num_sources}t${num_targets}
# python local/self_feat.py \
#        --input_file=$input_file \
#        --output_file=${input_file}.s${num_sources}t${num_targets} \
#        --num_sources=$num_sources \
#        --num_targets=$num_targets \
#        --print_interval=1
# num_sources=4
# num_targets=1
# input_file=dpgmm/test3/timit_test3_raw.mfcc
# num_epochs=10
# batch_size=2
# echo ${input_file}
# echo ${input_file}.s${num_sources}t${num_targets}
# python local/self_feat.py \
#        --input_file=$input_file \
#        --output_file=${input_file}.s${num_sources}t${num_targets} \
#        --num_sources=$num_sources \
#        --num_targets=$num_targets \
#        --num_epochs=$num_epochs \
#        --print_interval=1 \
#        --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=4
num_targets=4
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.mfcc
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=4
num_targets=4
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.reverse
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=8
num_targets=8
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.mfcc
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=8
num_targets=8
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.reverse
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=4
num_targets=1
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=4
num_targets=4
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=8
num_targets=1
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=8
num_targets=4
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

num_sources=8
num_targets=8
input_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
num_epochs=10
batch_size=20
echo ${input_file}
echo ${input_file}.s${num_sources}t${num_targets}
python local/self_feat.py \
       --input_file=$input_file \
       --output_file=${input_file}.s${num_sources}t${num_targets} \
       --num_sources=$num_sources \
       --num_targets=$num_targets \
       --num_epochs=$num_epochs \
       --batch_size=$batch_size | tee ${input_file}.s${num_sources}t${num_targets}.log

paste <(cat dpgmm/test/timit_test_raw.vtln.cmvn.mfcc) <(cat dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.s4t4) <(cat dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.reverse.s4t4) | tr -s '\t' ' ' > dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.merge.s4t4

paste <(cat dpgmm/test/timit_test_raw.vtln.cmvn.mfcc) <(cat dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.s8t8) <(cat dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.reverse.s8t8) | tr -s '\t' ' ' > dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.merge.s8t8
