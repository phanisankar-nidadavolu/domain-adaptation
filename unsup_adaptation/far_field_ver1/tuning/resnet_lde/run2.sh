#!/bin/bash

. ./cmd.sh
. ./path.sh
set -e

stage=-1

# Data preprocessing steps is skipped here

# Define all possible paths to store data
storage='storage.txt'

. parse_options.sh || exit 1;

# Now we prepare the features to generate examples for xvector training.
if [ $stage -le 4 ]; then
  # This script applies CMVN and removes nonspeech frames.  Note that this is somewhat
  # wasteful, as it roughly doubles the amount of training data on disk.  After
  # creating training examples, this can be removed.
  ./prepare_feats_for_egs.sh --nj 40 --cmd "$train_cmd -l \"hostname=b[01]*\" -V" \
    data/train_combined data/train_combined_no_sil exp/train_combined_no_sil
  #utils/fix_data_dir.sh data/train_combined_no_sil
  exit
fi

# Now we split all data into two parts: training and cv
if [ $stage -le 5 ]; then
  mkdir -p cnx_temp
  
  awk 'NR==FNR{a[$1]=$2;next}{if(a[$1]>=800)print}' data/train_combined_no_sil/utt2num_frames data/train_combined_no_sil/utt2spk > cnx_temp/utt2spk
  awk '{if(!($2 in a))a[$2]=0;a[$2]+=1;}END{for(i in a)print i,a[i]}' cnx_temp/utt2spk > cnx_temp/spk2num
  awk -v seed=$RANDOM 'BEGIN{srand(seed);}NR==FNR{a[$1]=$2;next}{if(a[$2]<10)print $1>>"cnx_temp/train.list";else{if(rand()<=0.1)print $1>>"cnx_temp/cv.list";else print $1>>"cnx_temp/train.list"}}' cnx_temp/spk2num cnx_temp/utt2spk
  
  awk 'NR==FNR{a[$1]=1;next}{if($1 in a)print}' cnx_temp/train.list data/train_combined_no_sil/feats.scp | shuf > cnx_temp/train_orig.scp
  awk 'NR==FNR{a[$1]=1;next}{if($1 in a)print}' cnx_temp/cv.list data/train_combined_no_sil/feats.scp | shuf > cnx_temp/cv_orig.scp
  
  awk 'BEGIN{s=0;}{if(!($2 in a)){a[$2]=s;s+=1;}print $1,a[$2]}' cnx_temp/utt2spk > cnx_temp/utt2spkid
fi

# Next we transform kaldi compressed format to user defined format: I removed the head and change data from column-majored to row-majored
# since we need to read a subutterance each time
if [ $stage -le 6 ]; then
  awk '{print $0"/sre18_train";}' $storage > cnx_temp/train_path.txt
  awk '{print $0"/sre18_cv";}' $storage > cnx_temp/cv_path.txt
  $train_cmd cnx_temp/convert_train.log python scripts/convert_compressed.py cnx_temp/train_orig.scp cnx_temp/train_path.txt cnx_temp/train.scp
  $train_cmd cnx_temp/convert_cv.log python scripts/convert_compressed.py cnx_temp/cv_orig.scp cnx_temp/cv_path.txt cnx_temp/cv.scp
fi

# After this you don't need to keep data/train_combined_no_sil for *this experiment*
# So you can delete it
export PYTHONPATH="${PYTHONPATH}:scripts/"
num_spk=`awk 'BEGIN{s=0;}{if($2>s)s=$2;}END{print s+1}' cnx_temp/utt2spkid`

# Network Training
if [ $stage -le 7 ]; then
  mkdir -p mdl2
  $cuda_cmd mdl2/train.log python scripts/main9.py --train cnx_temp/train.scp --cv cnx_temp/cv.scp --mlf cnx_temp/utt2spkid --num $num_spk
fi

# Network Decoding
# Do this for all your data
if [ $stage -le 8 ]; then
  mkdir -p ivs
  mdl=`ls -t mdl2/*.h5 | head -n 1`
  $cuda_cmd mdl2/decode.log python scripts/decode2.py $mdl $num_spk decode2.scp ivs/embedding2.ark
fi
