export KALDI_ROOT=/export/b17/snidada1/kaldi_jsalt_2019
export PATH=$KALDI_ROOT/egs/sre16/v2/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/sph2pipe_v2.5:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

#HYP_PATH=/home/snidada1/usr/src/phani_hyperion
HYP_PATH=/export/b17/janto/hyperion/hyperion-jsalt19
KERAS_PATH=/home/snidada1/usr/local/keras
LASYAM_PATH=/home/snidada1/usr/src/lasyam
KALDI_IO_PATH=/home/snidada1/usr/src/kaldi-io-for-python
KALDI_STEPS_PATH=/export/b15/snidada1/kaldi_mixed_bw/egs/wsj/s5/steps
KALDI_UTILS_PATH=/export/b15/snidada1/kaldi_mixed_bw/egs/wsj/s5/utils
WORKSPACE_PATH=/home/snidada1/usr/src/workspace

#
DOMAIN_ADAPTATION_BIN_DIR=/home/snidada1/usr/src/workspace/workspace/pytorch_utils/domain_adaptation/bin
ENHANCEMENT_BIN_DIR=/home/snidada1/usr/src/workspace/workspace/pytorch_utils/enhancement_bwe/bin


export PATH=$HYP_PATH/hyperion/bin:/usr/local/cuda/bin:$LASYAM_PATH/lasyam/nnet_tools:$PATH
export PYTHONPATH=$HYP_PATH:$KERAS_PATH:$LASYAM_PATH:$KALDI_IO_PATH:$KALDI_STEPS_PATH:$KALDI_UTILS_PATH:$WORKSPACE_PATH:$PYTHONPATH
export LD_LIBRARY_PATH
export LC_ALL=C

source ~/.bashrc
