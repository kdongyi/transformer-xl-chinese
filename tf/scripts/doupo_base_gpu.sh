#!/usr/bin/env bash

#!/bin/bash

# Data
DATA_ROOT=../data/doupo/

# Model
DIV_VAL=1
N_LAYER=16
D_MODEL=410
D_EMBED=410
N_HEAD=10
D_HEAD=41
D_INNER=2100

# Training
TGT_LEN=100
MEM_LEN=100


BSZ=64
NUM_CORE=4

# Testing
#TEST_TGT_LEN=64
#TEST_MEM_LEN=640
#TEST_CLAMP_LEN=400

TEST_TGT_LEN=100
TEST_MEM_LEN=500
TEST_CLAMP_LEN=400

#TEST_BSZ=10
TEST_BSZ=1

TEST_NUM_CORE=1


if [[ $1 == 'train_data' ]]; then
    python data_utils_chinese.py \
        --data_dir=${DATA_ROOT}/ \
        --dataset=doupo \
        --tgt_len=${TGT_LEN} \
        --per_host_train_bsz=${BSZ} \
        --per_host_valid_bsz=${BSZ} \
        --num_passes=1 \
        --use_tpu=False \
        ${@:2}
elif [[ $1 == 'test_data' ]]; then
    python data_utils_chinese.py \
        --data_dir=${DATA_ROOT}/ \
        --dataset=doupo \
        --tgt_len=${TEST_TGT_LEN} \
        --per_host_test_bsz=${TEST_BSZ} \
        --num_passes=1 \
        --use_tpu=False \
        ${@:2}
elif [[ $1 == 'train' ]]; then
    echo 'Run training...'
    CUDA_VISIBLE_DEVICES='0,1,2,3' python train_gpu.py \
        --data_dir=${DATA_ROOT}/tfrecords \
        --record_info_dir=${DATA_ROOT}/tfrecords/ \
        --corpus_info_path=${DATA_ROOT}/corpus-info.json \
        --model_dir=EXP-doupo4-1_head-1e4 \
        --div_val=${DIV_VAL} \
        --untie_r=True \
        --proj_share_all_but_first=True \
        --n_layer=${N_LAYER} \
        --d_model=${D_MODEL} \
        --d_embed=${D_EMBED} \
        --n_head=${N_HEAD} \
        --d_head=${D_HEAD} \
        --d_inner=${D_INNER} \
        --dropout=0.1 \
        --dropatt=0.0 \
        --learning_rate=0.00010 \
        --warmup_steps=0 \
        --train_steps=1000000 \
        --tgt_len=${TGT_LEN} \
        --mem_len=${MEM_LEN} \
        --train_batch_size=${BSZ} \
        --num_core_per_host=${NUM_CORE} \
        --iterations=200 \
        --save_steps=4000 \
        ${@:2}
elif [[ $1 == 'eval' ]]; then
    echo 'Run evaluation...'
    python train_gpu.py \
        --data_dir=${DATA_ROOT}/tfrecords \
        --record_info_dir=${DATA_ROOT}/tfrecords/ \
        --corpus_info_path=${DATA_ROOT}/corpus-info.json \
        --model_dir=EXP-wt103 \
        --div_val=${DIV_VAL} \
        --untie_r=True \
        --proj_share_all_but_first=True \
        --n_layer=${N_LAYER} \
        --d_model=${D_MODEL} \
        --d_embed=${D_EMBED} \
        --n_head=${N_HEAD} \
        --d_head=${D_HEAD} \
        --d_inner=${D_INNER} \
        --dropout=0.0 \
        --dropatt=0.0 \
        --tgt_len=${TEST_TGT_LEN} \
        --mem_len=${TEST_MEM_LEN} \
        --clamp_len=${TEST_CLAMP_LEN} \
        --same_length=True \
        --eval_batch_size=${TEST_BSZ} \
        --num_core_per_host=${TEST_NUM_CORE} \
        --do_train=False \
        --do_eval=True \
        --eval_split=test \
        ${@:2}
elif [[ $1 == 'inference' ]]; then
    echo 'Run inference...'
 CUDA_VISIBLE_DEVICES='0'   python train_gpu.py \
        --data_dir=${DATA_ROOT}/tfrecords \
        --record_info_dir=${DATA_ROOT}/tfrecords/ \
        --corpus_info_path=${DATA_ROOT}/corpus-info.json \
        --model_dir=EXP-doupo4/lr1e4_new \
        --div_val=${DIV_VAL} \
        --untie_r=True \
        --proj_share_all_but_first=True \
        --n_layer=${N_LAYER} \
        --d_model=${D_MODEL} \
        --d_embed=${D_EMBED} \
        --n_head=${N_HEAD} \
        --d_head=${D_HEAD} \
        --d_inner=${D_INNER} \
        --dropout=0.0 \
        --dropatt=0.0 \
        --tgt_len=${TEST_TGT_LEN} \
        --mem_len=${TEST_MEM_LEN} \
        --clamp_len=${TEST_CLAMP_LEN} \
        --same_length=True \
        --eval_batch_size=${TEST_BSZ} \
        --num_core_per_host=${TEST_NUM_CORE} \
        --do_train=False \
        --do_inference=True \
        --eval_split=test \
        ${@:2}

#elif [[ $1 == 'inference' ]]; then
#    echo 'Run inference...'
# CUDA_VISIBLE_DEVICES='0'   python train_gpu.py \
#        --data_dir=${DATA_ROOT}/tfrecords \
#        --record_info_dir=${DATA_ROOT}/tfrecords/ \
#        --corpus_info_path=${DATA_ROOT}/corpus-info.json \
#        --model_dir=EXP-doupo4-1_head \
#        --div_val=${DIV_VAL} \
#        --untie_r=True \
#        --proj_share_all_but_first=True \
#        --n_layer=${N_LAYER} \
#        --d_model=${D_MODEL} \
#        --d_embed=${D_EMBED} \
#        --n_head=${N_HEAD} \
#        --d_head=${D_HEAD} \
#        --d_inner=${D_INNER} \
#        --dropout=0.0 \
#        --dropatt=0.0 \
#        --tgt_len=${TEST_TGT_LEN} \
#        --mem_len=${TEST_MEM_LEN} \
#        --clamp_len=${TEST_CLAMP_LEN} \
#        --same_length=True \
#        --eval_batch_size=${TEST_BSZ} \
#        --num_core_per_host=${TEST_NUM_CORE} \
#        --do_train=False \
#        --do_eval=True \
#        --eval_split=test \
#        ${@:2}

else
    echo 'unknown argment 1'
fi