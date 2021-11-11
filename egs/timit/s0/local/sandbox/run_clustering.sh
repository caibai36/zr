for iter in $(seq 10);do
    echo "iter:" $iter;

    exp="timit"
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    seed=$((8*$iter))
    epochs=200
    batch_size=256
    hidden_dim=512
    output_dim=39
    num_layers=3
    num_left_context=0
    learning_rate=0.001
    exp_dir=exp/test_clustering/context
    log_dir=logs
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir $log_dir
    python local/clustering.py \
	   --exp=$exp \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --epochs=$epochs \
	   --batch_size=$batch_size \
	   --hidden_dim=$hidden_dim \
	   --output_dim=$output_dim \
	   --num_layers=$num_layers \
	   --num_left_context=$num_left_context \
	   --learning_rate=$learning_rate \
	   --exp_dir=$exp_dir \
	   --log_dir=$log_dir | tee logs/clustering/${exp}_bs${batch_size}_seed${seed}_hd${hidden_dim}_od${output_dim}_nl${num_layers}_lc${num_left_context}_lr${learning_rate}.log

    exp="timit"
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    seed=$((8*$iter))
    epochs=200
    batch_size=256
    hidden_dim=512
    output_dim=39
    num_layers=3
    num_left_context=16
    learning_rate=0.001
    exp_dir=exp/test_clustering/context
    log_dir=logs
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir $log_dir
    python local/clustering.py \
	   --exp=$exp \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --epochs=$epochs \
	   --batch_size=$batch_size \
	   --hidden_dim=$hidden_dim \
	   --output_dim=$output_dim \
	   --num_layers=$num_layers \
	   --num_left_context=$num_left_context \
	   --learning_rate=$learning_rate \
	   --exp_dir=$exp_dir \
	   --log_dir=$log_dir | tee logs/clustering/${exp}_bs${batch_size}_seed${seed}_hd${hidden_dim}_od${output_dim}_nl${num_layers}_lc${num_left_context}_lr${learning_rate}.log

    exp="timit"
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    seed=$((8*$iter))
    epochs=200
    batch_size=256
    hidden_dim=512
    output_dim=39
    num_layers=3
    num_left_context=32
    learning_rate=0.001
    exp_dir=exp/test_clustering/context
    log_dir=logs
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir $log_dir
    python local/clustering.py \
	   --exp=$exp \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --epochs=$epochs \
	   --batch_size=$batch_size \
	   --hidden_dim=$hidden_dim \
	   --output_dim=$output_dim \
	   --num_layers=$num_layers \
	   --num_left_context=$num_left_context \
	   --learning_rate=$learning_rate \
	   --exp_dir=$exp_dir \
	   --log_dir=$log_dir | tee logs/clustering/${exp}_bs${batch_size}_seed${seed}_hd${hidden_dim}_od${output_dim}_nl${num_layers}_lc${num_left_context}_lr${learning_rate}.log

    exp="timit"
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    seed=$((8*$iter))
    epochs=200
    batch_size=256
    hidden_dim=512
    output_dim=39
    num_layers=3
    num_left_context=48
    learning_rate=0.001
    exp_dir=exp/test_clustering/context
    log_dir=logs
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir $log_dir
    python local/clustering.py \
	   --exp=$exp \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --epochs=$epochs \
	   --batch_size=$batch_size \
	   --hidden_dim=$hidden_dim \
	   --output_dim=$output_dim \
	   --num_layers=$num_layers \
	   --num_left_context=$num_left_context \
	   --learning_rate=$learning_rate \
	   --exp_dir=$exp_dir \
	   --log_dir=$log_dir | tee logs/clustering/${exp}_bs${batch_size}_seed${seed}_hd${hidden_dim}_od${output_dim}_nl${num_layers}_lc${num_left_context}_lr${learning_rate}.log

    exp="timit"
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    seed=$((8*$iter))
    epochs=200
    batch_size=256
    hidden_dim=512
    output_dim=39
    num_layers=3
    num_left_context=64
    learning_rate=0.001
    exp_dir=exp/test_clustering/context
    log_dir=logs
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir $log_dir
    python local/clustering.py \
	   --exp=$exp \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --epochs=$epochs \
	   --batch_size=$batch_size \
	   --hidden_dim=$hidden_dim \
	   --output_dim=$output_dim \
	   --num_layers=$num_layers \
	   --num_left_context=$num_left_context \
	   --learning_rate=$learning_rate \
	   --exp_dir=$exp_dir \
	   --log_dir=$log_dir | tee logs/clustering/${exp}_bs${batch_size}_seed${seed}_hd${hidden_dim}_od${output_dim}_nl${num_layers}_lc${num_left_context}_lr${learning_rate}.log

    exp="timit"
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    seed=$((8*$iter))
    epochs=200
    batch_size=256
    hidden_dim=512
    output_dim=39
    num_layers=3
    num_left_context=80
    learning_rate=0.001
    exp_dir=exp/test_clustering/context
    log_dir=logs
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir $log_dir
    python local/clustering.py \
	   --exp=$exp \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --epochs=$epochs \
	   --batch_size=$batch_size \
	   --hidden_dim=$hidden_dim \
	   --output_dim=$output_dim \
	   --num_layers=$num_layers \
	   --num_left_context=$num_left_context \
	   --learning_rate=$learning_rate \
	   --exp_dir=$exp_dir \
	   --log_dir=$log_dir | tee logs/clustering/${exp}_bs${batch_size}_seed${seed}_hd${hidden_dim}_od${output_dim}_nl${num_layers}_lc${num_left_context}_lr${learning_rate}.log

    exp="timit"
    source_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/sources.txt
    target_file=data/test_time_trim_sil/test_source_target/mfcc_vtln/target_ids.txt
    seed=$((8*$iter))
    epochs=200
    batch_size=256
    hidden_dim=512
    output_dim=39
    num_layers=3
    num_left_context=96
    learning_rate=0.001
    exp_dir=exp/test_clustering/context
    log_dir=logs
    echo ${source_file}
    echo ${target_file}
    mkdir -p $exp_dir $log_dir
    python local/clustering.py \
	   --exp=$exp \
	   --source_file=$source_file \
	   --target_file=$target_file \
	   --seed=$seed \
	   --epochs=$epochs \
	   --batch_size=$batch_size \
	   --hidden_dim=$hidden_dim \
	   --output_dim=$output_dim \
	   --num_layers=$num_layers \
	   --num_left_context=$num_left_context \
	   --learning_rate=$learning_rate \
	   --exp_dir=$exp_dir \
	   --log_dir=$log_dir | tee logs/clustering/${exp}_bs${batch_size}_seed${seed}_hd${hidden_dim}_od${output_dim}_nl${num_layers}_lc${num_left_context}_lr${learning_rate}.log

done
