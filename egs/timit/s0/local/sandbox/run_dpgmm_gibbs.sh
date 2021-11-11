# for K0 in 20 40 80 90 100 188 200 400; do
#     echo "K0:" $K0

#     seed=2020
#     alpha=1 # the concentration parameter
#     lmbda=1 # the belief of mean
    
#     source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
#     target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
#     num_iterations=1500
#     exp_dir=exp/test_dpgmm_gibbs/try/seed_${seed}_K0_${K0}
#     echo ${source_file}
#     echo ${target_file}
#     mkdir -p $exp_dir
#     python -u local/run_dpgmm_gibbs.py \
# 	   --source_file=$source_file \
# 	   --target_file=$target_file \
# 	   --seed=$seed \
# 	   --num_iterations=$num_iterations \
# 	   --K0=$K0 \
# 	   --alpha=$alpha \
# 	   --lmbda=$lmbda | tee ${exp_dir}/run.log
# done

# for iter in $(seq 5);do
#     echo "iter:" $iter;
    
#     seed=$((8*$iter))
#     K0=188
#     alpha=1 # the concentration parameter
#     lmbda=1 # the belief of mean
    
#     source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
#     target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
#     num_iterations=1500
#     exp_dir=exp/test_dpgmm_gibbs/try/seed_${seed}_K0_${K0}
#     echo ${source_file}
#     echo ${target_file}
#     mkdir -p $exp_dir
#     python -u local/run_dpgmm_gibbs.py \
# 	   --source_file=$source_file \
# 	   --target_file=$target_file \
# 	   --seed=$seed \
# 	   --num_iterations=$num_iterations \
# 	   --K0=$K0 \
# 	   --alpha=$alpha \
# 	   --lmbda=$lmbda | tee ${exp_dir}/run.log
# done

for alpha in 1 2 3 4 5 10 50 100; do
    echo "alpha:" $alpha

    seed=2020
    K0=40
    # alpha=1 # the concentration parameter
    lmbda=1 # the belief of mean
    
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    num_iterations=1500
    exp_dir=exp/test_dpgmm_gibbs/try/seed_${seed}_K0_${K0}_alpha_${alpha}
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir
    python -u local/run_dpgmm_gibbs.py \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --num_iterations=$num_iterations \
	   --K0=$K0 \
	   --alpha=$alpha \
	   --lmbda=$lmbda | tee ${exp_dir}/run.log
done

for alpha in 1 2 3 4 5 10 50 100; do
    echo "alpha:" $alpha

    seed=2020
    K0=80
    # alpha=1 # the concentration parameter
    lmbda=1 # the belief of mean
    
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    num_iterations=1500
    exp_dir=exp/test_dpgmm_gibbs/try/seed_${seed}_K0_${K0}_alpha_${alpha}
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir
    python -u local/run_dpgmm_gibbs.py \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --num_iterations=$num_iterations \
	   --K0=$K0 \
	   --alpha=$alpha \
	   --lmbda=$lmbda | tee ${exp_dir}/run.log
done
