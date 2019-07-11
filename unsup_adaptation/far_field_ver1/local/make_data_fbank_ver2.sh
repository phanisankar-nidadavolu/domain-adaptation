
if  [ $# -ne 1 ]; then
    echo USAGE: $0 stage
    exit 1;
fi

stage=$1

./env.sh

if [ $stage -eq 0 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr 0.0 < rt60 < 0.5 and 0.5 < rt60 < 1.0
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_rt60_min_0_max_1

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.0-0.5_no_sil_h5,voxcelebcat_reverb_rt60-0.5-1.0_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-reverb-rt60-0.0-0.5"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part1
    awk '{print $0"-reverb-rt60-0.5-1.0"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part2
    cat $desdir/${mode}.tgt.scp.part* | utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-reverb-rt60-0.0-0.5 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part1
    awk '{print $1"-reverb-rt60-0.5-1.0 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part2

    rm $desdir/${mode}.tgt.scp.part*
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map.part* > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map.part*
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi


if [ $stage -eq 1 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb and noise, reverb rt60 range: 0.0 < rt60 < 0.5 and 0.5 < rt60 < 1.0
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_rt60_min_0_max_1_noise

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  #cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.0-0.5_no_sil_h5,voxcelebcat_reverb_rt60-0.5-1.0_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.5-1.0_noise_snr0-15_no_sil_h5,voxcelebcat_reverb_rt60-0.0-0.5_noise_snr0-15_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-reverb-rt60-0.0-0.5-noise-snr0-15"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part1
    awk '{print $0"-reverb-rt60-0.5-1.0-noise-snr0-15"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part2
    cat $desdir/${mode}.tgt.scp.part* | utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-reverb-rt60-0.0-0.5-noise-snr0-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part1
    awk '{print $1"-reverb-rt60-0.0-0.5-noise-snr0-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part2

    rm $desdir/${mode}.tgt.scp.part*
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map.part* > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map.part*
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 2 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb and noise, reverb rt60 range: 0.0 < rt60 < 0.5 and 0.5 < rt60 < 1.0
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_rt60_min_0_max_1_music

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  #cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.0-0.5_no_sil_h5,voxcelebcat_reverb_rt60-0.5-1.0_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.0-0.5_music_snr5-15_no_sil_h5,voxcelebcat_reverb_rt60-0.5-1.0_music_snr5-15_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-reverb-rt60-0.0-0.5-music-snr5-15"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part1
    awk '{print $0"-reverb-rt60-0.5-1.0-music-snr5-15"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part2
    cat $desdir/${mode}.tgt.scp.part* | utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-reverb-rt60-0.0-0.5-music-snr5-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part1
    awk '{print $1"-reverb-rt60-0.0-0.5-music-snr5-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part2

    rm $desdir/${mode}.tgt.scp.part*
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map.part* > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map.part*
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 3 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb and noise, reverb rt60 range: 0.0 < rt60 < 0.5 and 0.5 < rt60 < 1.0
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_rt60_min_0_max_1_chime3bg

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  #cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.0-0.5_no_sil_h5,voxcelebcat_reverb_rt60-0.5-1.0_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.5-1.0_chime3bg_snr5-15_no_sil_h5,voxcelebcat_reverb_rt60-0.0-0.5_chime3bg_snr5-15_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-reverb-rt60-0.5-1.0-chime3bg-snr5-15"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part1
    awk '{print $0"-reverb-rt60-0.0-0.5-chime3bg-snr5-15"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part2
    cat $desdir/${mode}.tgt.scp.part* | utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-reverb-rt60-0.5-1.0-chime3bg-snr5-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part1
    awk '{print $1"-reverb-rt60-0.0-0.5-chime3bg-snr5-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part2

    rm $desdir/${mode}.tgt.scp.part*
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map.part* > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map.part*
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 4 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb wada snr reverb and noise, reverb rt60 range: 0.0 < rt60 < 0.5 and 0.5 < rt60 < 1.0
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_rt60_min_0_max_1_babble

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  #cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.0-0.5_no_sil_h5,voxcelebcat_reverb_rt60-0.5-1.0_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $srcdir/voxceleb_cat_simulated_rirs/{voxcelebcat_reverb_rt60-0.5-1.0_babble_snr10-20_no_sil_h5,voxcelebcat_reverb_rt60-0.0-0.5_babble_snr10-20_no_sil_h5}/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-reverb-rt60-0.0-0.5-babble-snr10-20"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part1
    awk '{print $0"-reverb-rt60-0.5-1.0-babble-snr10-20"}' $desdir/${mode}.src.scp > $desdir/${mode}.tgt.scp.part2
    cat $desdir/${mode}.tgt.scp.part* | utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-reverb-rt60-0.0-0.5-babble-snr10-20 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part1
    awk '{print $1"-reverb-rt60-0.5-1.0-babble-snr10-20 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map.part2

    rm $desdir/${mode}.tgt.scp.part*
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map.part* > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map.part*
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 5 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb noise ony
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_noise

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  cat $srcdir/voxceleb_cat_additive/voxcelebcat_noise_snr0-15_no_sil_h5/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-noise-snr0-15"}' $desdir/${mode}.src.scp | \
        utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-noise-snr0-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 6 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb music only
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_music

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  cat $srcdir/voxceleb_cat_additive/voxcelebcat_music_snr5-15_no_sil_h5/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-music-snr5-15"}' $desdir/${mode}.src.scp | \
        utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-music-snr5-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 7 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb babble only
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_babble

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  cat $srcdir/voxceleb_cat_additive/voxcelebcat_babble_snr10-20_no_sil_h5/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-babble-snr10-20"}' $desdir/${mode}.src.scp | \
        utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-babble-snr10-20 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi

if [ $stage -eq 8 ]; then
  # STAGE 1: SRC DOMAIN: Voxceleb wada snr
  #          TGT DOMAIN: Voxceleb chime3bg only
  # min_len: 410

  min_len=410
  dir_name=SRC_vox_wada_snr_TGT_vox_wada_snr_chime3bg

  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/feature_extraction_for_adaptation_ver2/data/fbank
  feadir=data/fbank_ver2_wb_mel_40/train_dirs
  desdir=$feadir/$dir_name

  [ ! -d $desdir ] && mkdir -p $desdir
  #[ -d $desdir ] && echo $desdir already exists && exit 1;
  # Make the feats scp
  cat $srcdir/voxceleb_cat/voxcelebcat_no_sil_h5/feats.scp > $desdir/feats_src.scp.full
  cat $srcdir/voxceleb_cat_additive/voxcelebcat_chime3bg_snr5-15_no_sil_h5/feats.scp > $desdir/feats_tgt.scp.full
  cat $desdir/feats_*.full > $desdir/feats.scp.full

  # Make the scp files for src domain
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/train.src.scp > $desdir/train.src.scp
  awk '{print $0}' data/fbank_wb_mel_40/train_dirs/SRC_vox_wada_snr_TGT_sitw_dev_reverb_small/val.src.scp > $desdir/val.src.scp

  cat $desdir/{train,val}.src.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_src.scp.full > $desdir/feats_src.scp

  # make tgt domain data
  for mode in train val; do
    awk '{print $0"-chime3bg-snr5-15"}' $desdir/${mode}.src.scp | \
        utils/filter_scp.pl -f 2  $desdir/feats_tgt.scp.full - > $desdir/${mode}.tgt.scp

    awk '{print $1"-chime3bg-snr5-15 "$2}' $desdir/$mode.src.scp > $desdir/src2tgt.${mode}.map
  done

  cat $desdir/{train,val}.tgt.scp | awk '{print $2}' | utils/filter_scp.pl - $desdir/feats_tgt.scp.full > $desdir/feats_tgt.scp

  cat $desdir/feats_{src,tgt}.scp > $desdir/feats.scp

  cat $desdir/src2tgt.{train,val}.map > $desdir/src2tgt.map
  rm $desdir/src2tgt.{train,val}.map
  #cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map

  wc -l $desdir/{feats,feats_src,feats_tgt}.scp
  echo
  wc -l $desdir/{train,val}.src.scp
  echo
  wc -l $desdir/{train,val}.tgt.scp
  echo
  wc -l $desdir/src2tgt.map
  exit 0;
fi
