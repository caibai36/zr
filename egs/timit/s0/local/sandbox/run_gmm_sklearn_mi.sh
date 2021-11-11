for seed in 2021 3021 4021 5021 6021; do
    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="full"
    num_epochs=100
    init_params="kmeans"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

    # python local/run_gmm_sklearn.py \
    # 	   --train_file=$train_file \
    # 	   --test_file=$test_file \
    # 	   --test_post=$test_post \
    # 	   --K=$K \
    # 	   --seed=$seed \
    # 	   --cov_type=$cov_type \
    # 	   --epochs=$num_epochs \
    # 	   --init_params=$init_params \
    # 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
    # date

    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post

# diag

    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="diag"
    num_epochs=100
    init_params="kmeans"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

    
#     python local/run_gmm_sklearn.py \
# 	   --train_file=$train_file \
# 	   --test_file=$test_file \
# 	   --test_post=$test_post \
# 	   --K=$K \
# 	   --seed=$seed \
# 	   --cov_type=$cov_type \
# 	   --epochs=$num_epochs \
# 	   --init_params=$init_params \
# 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
#     date

    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post


# init_para random

    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="full"
    num_epochs=100
    init_params="random"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

    # python local/run_gmm_sklearn.py \
    # 	   --train_file=$train_file \
    # 	   --test_file=$test_file \
    # 	   --test_post=$test_post \
    # 	   --K=$K \
    # 	   --seed=$seed \
    # 	   --cov_type=$cov_type \
    # 	   --epochs=$num_epochs \
    # 	   --init_params=$init_params \
    # 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
    # date

    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post
    
# diag random

    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="diag"
    num_epochs=100
    init_params="random"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

#     python local/run_gmm_sklearn.py \
# 	   --train_file=$train_file \
# 	   --test_file=$test_file \
# 	   --test_post=$test_post \
# 	   --K=$K \
# 	   --seed=$seed \
# 	   --cov_type=$cov_type \
# 	   --epochs=$num_epochs \
# 	   --init_params=$init_params \
# 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
#     date

    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post
    

# # diag random 50

#     # Arguments for GMM
#     K=98 # number of DPGMM clusters
#     seed=$seed
#     cov_type="diag"
#     num_epochs=50
#     init_params="random"
#     verbose=2

#     train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
#     test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
#     test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

#     date
#     echo $train_file
#     echo $test_file
#     echo $test_post

#     python local/run_gmm_sklearn.py \
# 	   --train_file=$train_file \
# 	   --test_file=$test_file \
# 	   --test_post=$test_post \
# 	   --K=$K \
# 	   --seed=$seed \
# 	   --cov_type=$cov_type \
# 	   --epochs=$num_epochs \
# 	   --init_params=$init_params \
# 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
#     date


# tied

    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="tied"
    num_epochs=100
    init_params="kmeans"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

#     python local/run_gmm_sklearn.py \
# 	   --train_file=$train_file \
# 	   --test_file=$test_file \
# 	   --test_post=$test_post \
# 	   --K=$K \
# 	   --seed=$seed \
# 	   --cov_type=$cov_type \
# 	   --epochs=$num_epochs \
# 	   --init_params=$init_params \
# 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
#     date

    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post
    
# tied random

    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="tied"
    num_epochs=100
    init_params="random"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

#     python local/run_gmm_sklearn.py \
# 	   --train_file=$train_file \
# 	   --test_file=$test_file \
# 	   --test_post=$test_post \
# 	   --K=$K \
# 	   --seed=$seed \
# 	   --cov_type=$cov_type \
# 	   --epochs=$num_epochs \
# 	   --init_params=$init_params \
# 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
#     date

    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post
    

# spherical

    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="spherical"
    num_epochs=100
    init_params="kmeans"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

#     python local/run_gmm_sklearn.py \
# 	   --train_file=$train_file \
# 	   --test_file=$test_file \
# 	   --test_post=$test_post \
# 	   --K=$K \
# 	   --seed=$seed \
# 	   --cov_type=$cov_type \
# 	   --epochs=$num_epochs \
# 	   --init_params=$init_params \
# 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
#     date

    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post
    

# spherical random

    # Arguments for GMM
    K=98 # number of DPGMM clusters
    seed=$seed
    cov_type="spherical"
    num_epochs=100
    init_params="random"
    verbose=2

    train_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_file=dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
    test_post=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt

    date
    echo $train_file
    echo $test_file
    echo $test_post

#     python local/run_gmm_sklearn.py \
# 	   --train_file=$train_file \
# 	   --test_file=$test_file \
# 	   --test_post=$test_post \
# 	   --K=$K \
# 	   --seed=$seed \
# 	   --cov_type=$cov_type \
# 	   --epochs=$num_epochs \
# 	   --init_params=$init_params \
# 	   --verbose=$verbose | tee exp/logs/test_mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.log
    #     date
    post_file=exp/gmm/timit_test_raw.vtln.cmvn.deltas.mfcc_K$K.seed$seed.cov$cov_type.epoch$num_epochs.init$init_params.txt
    abx_post=eval/abx/post/exp/gmm/gmm.K$K.$cov_type.$init_params.$seed
    mkdir -p $abx_post
    ./local/split_post_with_abx_time data/test/utt2num_frames $post_file data/test_time/test_abx_time $abx_post
    bash local/sandbox/eval_mi.sh --post_dir $abx_post
done
