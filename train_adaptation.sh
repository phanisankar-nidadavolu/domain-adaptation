#!/bin/bash

source ~/.bashrc

. ./env.sh

CUDA_VISIBLE_DEVICES=`free-gpu` python "$@"

