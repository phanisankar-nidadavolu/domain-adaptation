#!/bin/bash

. ./env.sh


src_dir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
# jsalt dirs
jsalt_ami=""
for name in ami_dev_enr15 ami_dev_enr30 ami_dev_enr5 ami_dev_test ami_eval_enr15 ami_eval_enr30 ami_eval_enr5 ami_eval_test; do
    utils/copy_data_dir.sh $src_dir/jsalt_spkdet_ami/jsalt19_spkdet_${name}_no_sil jsalt19/jsalt19_spkdet_${name}_no_sil
done

jsalt_babytrain=""
for name in babytrain_dev_enr15 babytrain_dev_enr30 babytrain_dev_enr5 babytrain_dev_test babytrain_eval_enr15 babytrain_eval_enr30 babytrain_eval_enr5 babytrain_eval_test; do
    utils/copy_data_dir.sh $src_dir/jsalt_spkdet_babytrain/jsalt19_spkdet_${name}_no_sil jsalt19/jsalt19_spkdet_${name}_no_sil
done

jsalt_sri=""
for name in ; do
    utils/copy_data_dir.sh $src_dir/jsalt_spkdet_sri/jsalt19_spkdet_${name}_no_sil jsalt19/jsalt19_spkdet_${name}_no_sil
done

