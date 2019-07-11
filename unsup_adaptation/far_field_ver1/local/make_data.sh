stage=14

./env.sh

if [ $stage -eq 0 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voices dev
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_voices_dev

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp $srcdir/voices19/voices19_challenge_dev_no_sil_h5/feats.scp > $desdir/feats.scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/voices19/voices19_challenge_dev_no_sil_h5/feats.scp > $desdir/feats_tgt.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  paste -d " " $srcdir/voices19/voices19_challenge_dev_no_sil_h5_tr/utt2num_frames $srcdir/voices19/voices19_challenge_dev_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.tgt.scp
  paste -d " " $srcdir/voices19/voices19_challenge_dev_no_sil_h5_cv/utt2num_frames $srcdir/voices19/voices19_challenge_dev_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.tgt.scp
  wc -l $desdir/*.tgt.scp

  echo None > $desdir/src2tgt.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 1 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb with real rirs
  # min_len: 410

  min_len=410
  dir_name=data/fbank_wb_mel_40/SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/voxceleb_wada_snr_reverb_train/voxceleb1_and_2_wada_snr_reverb_real_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  awk '{print $0"-reverb"}' $desdir/train.src.scp > $desdir/train.tgt.scp
  awk '{print $0"-reverb"}' $desdir/val.src.scp > $desdir/val.tgt.scp
  wc -l $desdir/*.tgt.scp

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | awk -F "-reverb" '{print $1" "$0}' > $desdir/src2tgt.map

  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 2 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb with small room rirs
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_small

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/voxceleb_wada_snr_reverb_train/voxceleb1_and_2_wada_snr_reverb_small_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  awk '{print $0"-reverb"}' $desdir/train.src.scp > $desdir/train.tgt.scp
  awk '{print $0"-reverb"}' $desdir/val.src.scp > $desdir/val.tgt.scp
  wc -l $desdir/*.tgt.scp

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | awk -F "-reverb" '{print $1" "$0}' > $desdir/src2tgt.map

  wc -l $desdir/src2tgt.map
  exit 0;
fi


if [ $stage -eq 3 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voices dev and point source one copy
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_voices_dev_ps_num_copies_1

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/voices19_ps1/voices19_challenge_dev_{enroll,test}_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  awk '{print $0"-noise1"}' $feadir/SRC_vox_wada_snr_TGT_voices_dev/train.tgt.scp > $desdir/train.tgt.scp
  awk '{print $0"-noise1"}' $feadir/SRC_vox_wada_snr_TGT_voices_dev/val.tgt.scp > $desdir/val.tgt.scp

  wc -l $desdir/*.tgt.scp

  echo None > $desdir/src2tgt.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 4 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voices dev and point source num copies 3
  # min_len: 410

  min_len=410
  num_copies=3
  dir_name=SRC_vox_wada_snr_TGT_voices_dev_ps_num_copies_${num_copies}

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/voices19_ps{1,2,3}/voices19_challenge_dev_{enroll,test}_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  for copy in `seq 1 $num_copies`; do
    awk -v copy=$copy '{print $0"-noise"copy}' $feadir/SRC_vox_wada_snr_TGT_voices_dev/train.tgt.scp
  done | sort -k1,1 > $desdir/train.tgt.scp
  for copy in `seq 1 $num_copies`; do
    awk -v copy=$copy '{print $0"-noise"copy}' $feadir/SRC_vox_wada_snr_TGT_voices_dev/val.tgt.scp
  done | sort -k1,1 > $desdir/val.tgt.scp

  wc -l $desdir/*.tgt.scp

  echo None > $desdir/src2tgt.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 5 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voices dev and point source num copies 3
  # min_len: 410

  min_len=410
  num_copies=5
  dir_name=SRC_vox_wada_snr_TGT_voices_dev_ps_num_copies_${num_copies}

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/voices19_ps{1,2,3,4,5}/voices19_challenge_dev_{enroll,test}_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  for copy in `seq 1 $num_copies`; do
    awk -v copy=$copy '{print $0"-noise"copy}' $feadir/SRC_vox_wada_snr_TGT_voices_dev/train.tgt.scp
  done | sort -k1,1 > $desdir/train.tgt.scp
  for copy in `seq 1 $num_copies`; do
    awk -v copy=$copy '{print $0"-noise"copy}' $feadir/SRC_vox_wada_snr_TGT_voices_dev/val.tgt.scp
  done | sort -k1,1 > $desdir/val.tgt.scp

  wc -l $desdir/*.tgt.scp

  echo None > $desdir/src2tgt.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 6 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: SITW DEV reverb small
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_sitw_dev_reverb_small

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/sitw_reverb_train/sitw_dev_reverb_small_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  paste -d " " $srcdir/sitw_reverb_train/sitw_dev_reverb_small_no_sil_h5_tr/utt2num_frames $srcdir/sitw_reverb_train/sitw_dev_reverb_small_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.tgt.scp
  paste -d " " $srcdir/sitw_reverb_train/sitw_dev_reverb_small_no_sil_h5_cv/utt2num_frames $srcdir/sitw_reverb_train/sitw_dev_reverb_small_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.tgt.scp
  wc -l $desdir/*.tgt.scp

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | awk -F "-reverb" '{print $1" "$0}' > $desdir/src2tgt.map

  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 7 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: SITW DEV reverb real
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_sitw_dev_reverb_real

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/sitw_reverb_train/sitw_dev_reverb_real_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  paste -d " " $srcdir/sitw_reverb_train/sitw_dev_reverb_real_no_sil_h5_tr/utt2num_frames $srcdir/sitw_reverb_train/sitw_dev_reverb_real_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.tgt.scp
  paste -d " " $srcdir/sitw_reverb_train/sitw_dev_reverb_real_no_sil_h5_cv/utt2num_frames $srcdir/sitw_reverb_train/sitw_dev_reverb_real_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.tgt.scp
  wc -l $desdir/*.tgt.scp

  #cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | awk -F "-reverb" '{print $1" "$0}' > $desdir/src2tgt.map

  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 8 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: SITW DEV reverb real with noise added
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/sitw_reverb_train_ps/sitw_dev_reverb_real_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  awk '{print $0"-noise"}' $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real/train.tgt.scp > $desdir/train.tgt.scp
  awk '{print $0"-noise"}' $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real/val.tgt.scp > $desdir/val.tgt.scp
  wc -l $desdir/*.tgt.scp

  #cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | awk -F "-reverb" '{print $1" "$0}' > $desdir/src2tgt.map
  echo None > $desdir/src2tgt.map

  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 9 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: SITW DEV reverb small
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_sitw_dev_reverb_small_ps

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/sitw_reverb_train_ps/sitw_dev_reverb_small_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  awk '{print $0"-noise"}' $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.tgt.scp > $desdir/train.tgt.scp
  awk '{print $0"-noise"}' $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.tgt.scp > $desdir/val.tgt.scp
  wc -l $desdir/*.tgt.scp

  echo None > $desdir/src2tgt.map

  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 10 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb with real rirs
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real_noise

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank
  feadir=data/fbank_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5/feats.scp > $desdir/feats_src.scp
  cat $srcdir/voxceleb_wada_snr_reverb_train/voxceleb1_and_2_wada_snr_reverb_real_noise_no_sil_h5/feats.scp > $desdir/feats_tgt.scp
  cat $desdir/feats_src.scp $desdir/feats_tgt.scp > $desdir/feats.scp

  wc -l $desdir/feats*scp

  # Make the scp files for src domain
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_tr/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/train.src.scp
  paste -d " " $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2num_frames $srcdir/voxceleb_wada_snr/voxceleb1_and_2_wada_snr_no_sil_h5_cv/utt2spk | \
    awk -v ml=$min_len '$2 > ml {print $4" "$1}' > $desdir/val.src.scp
  wc -l $desdir/*.src.scp

  # Make the scp files for tgt domain
  awk '{print $0"-reverb-noise"}' $desdir/train.src.scp > $desdir/train.tgt.scp
  awk '{print $0"-reverb-noise"}' $desdir/val.src.scp > $desdir/val.tgt.scp

  wc -l $desdir/*.tgt.scp

  echo None > $desdir/src2tgt.map

  wc -l $desdir/src2tgt.map
  exit 0;
fi


if [ $stage -eq 11 ]; then
  # STAGE 2: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb with small room rirs and noise
  # min_len: 410

  min_len=410
  dir_name=data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_small

  cp -r ${dir_name} ${dir_name}_noise

  cat  ${dir_name}_noise/{train,val}.tgt.scp | awk '{print $2}'  | utils/filter_scp.pl - /export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation/data/fbank/voxceleb_cat_reverb_ps_train/voxcelebcat_reverb_small_no_sil_h5/feats.scp > ${dir_name}_noise/feats_tgt.scp

  cat ${dir_name}_noise/feats_{src,tgt}.scp > ${dir_name}_noise/feats.scp

  wc -l ${dir_name}_noise/feats*.scp

  wc -l ${dir_name}_noise/*.src.scp

  wc -l ${dir_name}_noise/*.tgt.scp

  echo None > ${dir_name}_noise/src2tgt.map

  exit 0;
fi

if [ $stage -eq 12 ]; then
  # This stage combines two data directories 1) sitw_dev with real rirs and noise 2) wada_snr with real rirs and noises
  # Used as data augmentation in ASRU experiments

  feadir=data/fbank_wb_mel_40/train_dirs
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_sitw_dev_rev_real_ps
  [ ! -d $feadir/$dir_name ] && mkdir -p $feadir/$dir_name
  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps/feats_src.scp > $feadir/$dir_name/feats_src.scp
  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real_noise,SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps}/feats_tgt.scp > $feadir/$dir_name/feats_tgt.scp
  cat $feadir/$dir_name/feats_{src,tgt}.scp > $feadir/$dir_name/feats.scp

  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps/train.src.scp > $feadir/$dir_name/train.src.scp
  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps/val.src.scp > $feadir/$dir_name/val.src.scp

  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real_noise,SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps}/train.tgt.scp > $feadir/$dir_name/train.tgt.scp
  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real_noise,SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps}/val.tgt.scp > $feadir/$dir_name/val.tgt.scp

  echo None > $feadir/$dir_name/src2tgt.map

  wc -l $feadir/$dir_name/feats*.scp

  wc -l $feadir/$dir_name/*.src.scp

  wc -l $feadir/$dir_name/*.tgt.scp
fi

if [ $stage -eq 13 ]; then
  # This stage combines two data directories 1) sitw_dev with real rirs and noise 2) wada_snr with real rirs and noises
  # Used as data augmentation in ASRU experiments

  feadir=data/fbank_wb_mel_40/train_dirs
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_rev_real_voices_dev_ps
  [ ! -d $feadir/$dir_name ] && mkdir -p $feadir/$dir_name
  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps/feats_src.scp > $feadir/$dir_name/feats_src.scp
  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real_noise,SRC_vox_wada_snr_TGT_voices_dev_ps_num_copies_1}/feats_tgt.scp > $feadir/$dir_name/feats_tgt.scp
  cat $feadir/$dir_name/feats_{src,tgt}.scp > $feadir/$dir_name/feats.scp

  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps/train.src.scp > $feadir/$dir_name/train.src.scp
  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_real_ps/val.src.scp > $feadir/$dir_name/val.src.scp

  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real_noise,SRC_vox_wada_snr_TGT_voices_dev_ps_num_copies_1}/train.tgt.scp > $feadir/$dir_name/train.tgt.scp
  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_real_noise,SRC_vox_wada_snr_TGT_voices_dev_ps_num_copies_1}/val.tgt.scp > $feadir/$dir_name/val.tgt.scp

  echo None > $feadir/$dir_name/src2tgt.map

  wc -l $feadir/$dir_name/feats*.scp
  wc -l $feadir/$dir_name/*.src.scp
  wc -l $feadir/$dir_name/*.tgt.scp
fi

if [ $stage -eq 14 ]; then
  # This stage combines two data directories 1) sitw_dev with real rirs and noise 2) wada_snr with real rirs and noises
  # Used as data augmentation in ASRU experiments

  feadir=data/fbank_wb_mel_40/train_dirs
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_sitw_dev_rev_small_ps
  [ ! -d $feadir/$dir_name ] && mkdir -p $feadir/$dir_name
  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small_ps/feats_src.scp > $feadir/$dir_name/feats_src.scp
  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_small_noise,SRC_vox_wada_snr_TGT_sitw_dev_reverb_small_ps}/feats_tgt.scp > $feadir/$dir_name/feats_tgt.scp
  cat $feadir/$dir_name/feats_{src,tgt}.scp > $feadir/$dir_name/feats.scp

  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small_ps/train.src.scp > $feadir/$dir_name/train.src.scp
  cat $feadir/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small_ps/val.src.scp > $feadir/$dir_name/val.src.scp

  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_small_noise,SRC_vox_wada_snr_TGT_sitw_dev_reverb_small_ps}/train.tgt.scp > $feadir/$dir_name/train.tgt.scp
  cat $feadir/{SRC_vox_wada_snr_TGT_vox_wada_snr_reverb_small_noise,SRC_vox_wada_snr_TGT_sitw_dev_reverb_small_ps}/val.tgt.scp > $feadir/$dir_name/val.tgt.scp

  echo None > $feadir/$dir_name/src2tgt.map

  wc -l $feadir/$dir_name/feats*.scp

  wc -l $feadir/$dir_name/*.src.scp

  wc -l $feadir/$dir_name/*.tgt.scp
fi
