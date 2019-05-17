#!/bin/bash

. ./env.sh

stage=$1
expid=$2

if [ $# -ne 2 ]; then
    echo USAGE $0 stage expid
    exit 1;
fi

source /home/snidada1/.bashrc

bindir=$ENHANCEMENT_BIN_DIR

# ARGS
ftype=fbank_wb_mel_40
data_dir=data/$ftype/SRC_voxceleb_1_2_subset_clean_no_sil_TGT_voxceleb_1_2_subset_reverb_no_sil

# optional arguments for traing
optim_type=adam
adam_beta1=0.5
lr=0.0003
disc_lr=0.0001
batch_size=32
max_epochs=100
reg_type=l2
dropout_per=0.4
iters_per_epoch=1
seq_len=127
num_workers=1
alpha=0.3

reg_label=$reg_type
if [ "$reg_type" == "l2" ]; then
    reg_label=none
fi

# Loss wts
cycle_loss_wt=2.5
idt_loss_wt=0.0

print_freq=100
save_freq=1

# model options
num_res_blocks=9
nfilter=32
kernel_size_first_layer=3
norm_layer_type=instancenorm2d     # batchnorm2d or instancenorm2d

# common optional args for training and testing
data_format=nCFD
model_name=cycle_gan_cnn
model_ver=ver2
trainer_ver=ver1

splice=0
inp_fea_dim=40
out_fea_dim=40

# exp dir name
data_name=`basename $data_dir`
conv_label=num_res_${num_res_blocks}_nfilter_${nfilter}
loss_label=cycle_lwt_${cycle_loss_wt}_idt_lwt_${idt_loss_wt}_alpha_${alpha}
exp_name=exp_${expid}_model_trainer_${trainer_ver}_${conv_label}_data_name_${data_name}_optim_${optim_type}_lr_${lr}_reg_${reg_label}_df_${data_format}_bs_${batch_size}_seq_len_${seq_len}_adam_beta1_${adam_beta1}_${loss_label}
exp_dir=`pwd`/exp/${model_name}_${model_ver}_models/${exp_name}


python_script="$bindir/train-cycle-gan-cnn-for-enhancement-${trainer_ver}.py"

train_args="--setup-logger
        --data-dir $data_dir --exp-dir $exp_dir
        --gen-lr $lr
        --disc-lr $disc_lr
        --optim-type $optim_type
        --batch-size $batch_size
        --data-format $data_format
        --splice $splice
        --model-ver $model_ver
        --model-name $model_name
        --max-epochs $max_epochs
        --min-seq-length $seq_len
        --max-seq-length $seq_len
        --dropout-per $dropout_per
        --iters-per-epoch $iters_per_epoch
        --norm-layer-type $norm_layer_type
        --gen-num-res-blocks $num_res_blocks
        --identity-loss-wt $idt_loss_wt
        --cycle-loss-wt $cycle_loss_wt
        --alpha $alpha
        --reg-type $reg_type
        --src-inp-fea-dim $inp_fea_dim
        --tgt-inp-fea-dim $out_fea_dim
        --src-name src --tgt-name tgt
        --num-workers $num_workers
        --gen-nfilter $nfilter
        --adam-beta1 $adam_beta1
        --print-freq $print_freq
        --save-freq $save_freq
        --gen-kernel-size-first-layer $kernel_size_first_layer"


if [ $stage -eq 0 ]; then
    # BEFORE SUBMITTING THIS MAKE SURE YOU HAVE A GPU RESERVED VIA QLOGIN
    # qlogin -l 'hostname=b1*|c*,gpu=1' -now no
    # and then train the model
    source activate pytorch_gpu_test
    [ ! -f $python_script ] && echo "training script $python_script does not exist" && exit 1;
    [ ! -d submit_scripts/logs ] && mkdir -p submit_scripts/logs
    sub_script=submit_scripts/ffda_${expid}_${trainer_ver}_${model_name}_${model_ver}.sh
    cat train_adaptation.sh > $sub_script
    chmod 755 $sub_script

    qsub -e submit_scripts/logs/err${expid}_${model_name}_${model_ver}.log -o submit_scripts/logs/out${expid}_${model_name}_${model_ver}.log -cwd -l 'hostname=c*,gpu=1' $sub_script $python_script $train_args || exit 1;

    #python $python_script $train_args || exit 1;

    source deactivate
    exit 0;
fi


if [ $stage -eq 2 ]; then
    source ~/.bashrc
    extract_cmd="queue.pl --max-jobs-run 50 -l arch=*64* -l ram_free=6G,mem_free=6G,\"hostname=[bc]*[01]*[123456789]*\" -V"
    echo extract_cmd is $extract_cmd
    nj_test=10
    for test_epoch in 60 65 70 75 80; do

      for name in voices19_challenge_eval_enroll_no_sil voices19_challenge_dev_enroll_no_sil \
                    voices19_challenge_dev_test_no_sil voices19_challenge_eval_test_no_sil; do
        output_feats_type=tgt_gen

        test_data_dir=data/$ftype/$name
        [ ! -d $test_data_dir ] && echo $test_data_dir does not exist && exit 1;
        fwd_pass_dir=$exp_dir/predicted_feats/test_epoch_${test_epoch}/inp_dir_${name}_output_feats_type_${output_feats_type} || exit 1;
        [ ! -d $fwd_pass_dir/log ] && mkdir -p $fwd_pass_dir/log
        [ ! -d $exp_dir ] && echo "exp dir $exp_dir does not exist" && exit 1;
        echo fwd pass dir is $fwd_pass_dir

        if [ ! -d $fwd_pass_dir/storage ]; then
          utils/create_split_dir.pl \
            /export/b{14,15,16,17,18}/$USER/STORAGE_FOR_DOMAIN_ADAPTATION/sitw_no_aug_fwd_pass/cycle_gan_models_$(date +'%m_%d_%H_%M')/${exp_name}/test_dir_name_${name} $fwd_pass_dir/storage || exit 1;
        fi

        for n in `seq 1 $nj_test`; do
            utils/create_data_link.pl $fwd_pass_dir/predicted.feats_${output_feats_type}.${n}.ark
        done

        # Forward pass NB features through the model
        #source activate pytorch_gpu_test

        MY_PYTHON=$(which python)
        echo $MY_PYTHON
        $extract_cmd JOB=1:$nj_test $fwd_pass_dir/log/fwd_pass.JOB.log \
            $MY_PYTHON $bindir/test-cycle-gan-cnn-ver2.py $train_args \
                --test-epoch $test_epoch \
                --job-id JOB --max-jobs $nj_test \
                --forward-pass-in-chunks \
                --forward-pass-chunk-size 48 \
                --forward-pass-seq-length $seq_len \
                --output-feats-type $output_feats_type \
                --print-freq 5 \
                --trainer-ver $trainer_ver \
                --exp-dir $exp_dir --data-dir $data_dir \
                --feats-scp $test_data_dir/feats.scp \
                --fwd-pass-dir $fwd_pass_dir || exit 1;

        #source deactivate
      done
    done
    exit 0;
fi

if [ $stage -eq 3 ]; then
    source ~/.bashrc
    extract_cmd="queue.pl --max-jobs-run 61 -l arch=*64* -l ram_free=10G,mem_free=10G,\"hostname=[bc]*[1]*[123456789]*\" -V"
    echo extract_cmd is $extract_cmd
    nj_test=61
    for test_epoch in 100; do

      for name in swbd_sre_no_sil; do
        output_feats_type=tgt_gen

        test_data_dir=data/$ftype/$name
        [ ! -d $test_data_dir ] && echo $test_data_dir does not exist && exit 1;
        fwd_pass_dir=$exp_dir/predicted_feats/test_epoch_${test_epoch}/inp_dir_${name}_output_feats_type_${output_feats_type} || exit 1;
        [ ! -d $fwd_pass_dir/log ] && mkdir -p $fwd_pass_dir/log
        [ ! -d $exp_dir ] && echo "exp dir $exp_dir does not exist" && exit 1;
        echo fwd pass dir is $fwd_pass_dir

        if [ ! -d $fwd_pass_dir/storage ]; then
          utils/create_split_dir.pl \
            /export/b{14,15,16,17,18}/$USER/STORAGE_FOR_DOMAIN_ADAPTATION/swbd_sre_no_sil_fwd_pass/cycle_gan_models_$(date +'%m_%d_%H_%M')/${exp_name}/test_dir_name_${name} $fwd_pass_dir/storage || exit 1;
        fi

        for n in `seq 1 $nj_test`; do
            utils/create_data_link.pl $fwd_pass_dir/predicted.feats.${n}.ark
        done

        # Forward pass NB features through the model
        #source activate pytorch_gpu_test

        MY_PYTHON=$(which python)
        echo $MY_PYTHON
        $extract_cmd JOB=1:$nj_test $fwd_pass_dir/log/fwd_pass.JOB.log \
            $MY_PYTHON $bindir/test-cycle-gan-cnn.py $train_args \
                --test-epoch $test_epoch \
                --job-id JOB --max-jobs $nj_test \
                --forward-pass-in-chunks \
                --forward-pass-chunk-size 6 \
                --output-feats-type $output_feats_type \
                --print-freq 5 \
                --trainer-ver $trainer_ver \
                --exp-dir $exp_dir --data-dir $data_dir \
                --feats-scp $test_data_dir/feats.scp \
                --fwd-pass-dir $fwd_pass_dir || exit 1;

        #source deactivate
      done
    done
fi


if [ $stage -eq 4 ]; then
    extract_cmd="queue.pl --max-jobs-run 50 -l arch=*64* -l ram_free=6G,mem_free=6G,\"hostname=[bc]*[01]*[123456789]*\" -V"
    nj_test=50
    source ~/.bashrc
    for test_epoch in 75; do

      for output_feats_type  in tgt_rec src_gen; do
        for name in sitw_dev_enroll_no_sil sitw_dev_test_no_sil sitw_eval_enroll_no_sil sitw_eval_test_no_sil; do
            echo ""

            test_data_dir=data/$ftype/$name
            [ ! -d $test_data_dir ] && echo $test_data_dir does not exist && exit 1;
            fwd_pass_dir=$exp_dir/predicted_feats/test_epoch_${test_epoch}/inp_dir_${name}_output_feats_type_${output_feats_type} || exit 1;
            [ ! -d $fwd_pass_dir/log ] && mkdir -p $fwd_pass_dir/log
            [ ! -d $exp_dir ] && echo "exp dir $exp_dir does not exist" && exit 1;
            echo fwd pass dir is $fwd_pass_dir

            if [ ! -d $fwd_pass_dir/storage ]; then
                utils/create_split_dir.pl \
                /export/b{14,15,16,17,18}/$USER/STORAGE_FOR_DOMAIN_ADAPTATION/sitw_no_aug_fwd_pass/cycle_gan_models_$(date +'%m_%d_%H_%M')/${exp_name}/test_dir_name_${name} $fwd_pass_dir/storage || exit 1;
            fi

            for n in `seq 1 $nj_test`; do
                utils/create_data_link.pl $fwd_pass_dir/predicted.feats_${output_feats_type}.${n}.ark
            done

            # Forward pass NB features through the model
            #source activate pytorch_gpu_test

            MY_PYTHON=$(which python)
            echo $MY_PYTHON
            $extract_cmd JOB=1:$nj_test $fwd_pass_dir/log/fwd_pass.JOB.log \
                $MY_PYTHON $bindir/test-cycle-gan-cnn-ver2.py $train_args \
                    --test-epoch $test_epoch \
                    --job-id JOB --max-jobs $nj_test \
                    --forward-pass-in-chunks \
                    --forward-pass-chunk-size 48 \
                    --forward-pass-seq-length $seq_len \
                    --output-feats-type $output_feats_type \
                    --print-freq 5 \
                    --trainer-ver $trainer_ver \
                    --exp-dir $exp_dir --data-dir $data_dir \
                    --feats-scp $test_data_dir/feats.scp \
                    --fwd-pass-dir $fwd_pass_dir || exit 1;

            #source deactivate
        done
      done
    done
    exit 0;
fi

if [ $stage -eq 5 ]; then
    extract_cmd="queue.pl --max-jobs-run 61 -l arch=*64* -l ram_free=5G,mem_free=5G,\"hostname=[bc]*[01]*[123456789]*\" -V"
    echo extract_cmd is $extract_cmd
    nj_test=61
    source ~/.bashrc
    for test_epoch in 75; do

      for name in swbd_sre_no_sil; do
        for output_feats_type in tgt_gen src_rec; do
            test_data_dir=data/$ftype/$name
            [ ! -d $test_data_dir ] && echo $test_data_dir does not exist && exit 1;
            fwd_pass_dir=$exp_dir/predicted_feats/test_epoch_${test_epoch}/inp_dir_${name}_output_feats_type_${output_feats_type} || exit 1;
            [ ! -d $fwd_pass_dir/log ] && mkdir -p $fwd_pass_dir/log
            [ ! -d $exp_dir ] && echo "exp dir $exp_dir does not exist" && exit 1;
            echo fwd pass dir is $fwd_pass_dir

            if [ ! -d $fwd_pass_dir/storage ]; then
                utils/create_split_dir.pl \
                    /export/b{14,15,16,17,18}/$USER/STORAGE_FOR_DOMAIN_ADAPTATION/swbd_sre_no_sil_fwd_pass/cycle_gan_models_$(date +'%m_%d_%H_%M')/${exp_name}/test_dir_name_${name} $fwd_pass_dir/storage || exit 1;
            fi

            for n in `seq 1 $nj_test`; do
                utils/create_data_link.pl $fwd_pass_dir/predicted.feats.${n}.ark
            done

            # Forward pass NB features through the model
            MY_PYTHON=$(which python)
            echo $MY_PYTHON
            $extract_cmd JOB=1:$nj_test $fwd_pass_dir/log/fwd_pass.JOB.log \
                $MY_PYTHON $bindir/test-cycle-gan-cnn-ver2.py $train_args \
                    --test-epoch $test_epoch \
                    --job-id JOB --max-jobs $nj_test \
                    --forward-pass-in-chunks \
                    --forward-pass-chunk-size 6 \
                    --output-feats-type $output_feats_type \
                    --print-freq 5 \
                    --trainer-ver $trainer_ver \
                    --exp-dir $exp_dir --data-dir $data_dir \
                    --feats-scp $test_data_dir/feats.scp \
                    --fwd-pass-dir $fwd_pass_dir || exit 1;
        done
      done
    done
fi
