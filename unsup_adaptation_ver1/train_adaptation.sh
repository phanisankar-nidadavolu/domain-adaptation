#!/bin/bash

source ~/.bashrc

CUDA_VISIBLE_DEVICES=`free-gpu` python "$@"

