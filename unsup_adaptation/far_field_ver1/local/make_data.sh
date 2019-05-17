stage=0


if [ $stage -eq 0 ]; then
  srcdir=/export/b17/snidada1/kaldi_jsalt_2019/egs/voxceleb/v2/data/
  destdir=data/fbank_wb_mel_40/SRC_voxceleb_1_2_subset_clean_no_sil_TGT_voxceleb_1_2_subset_reverb_no_sil

  cat $srcdir/train_subset_fbank_40_tr_reverb_no_sil_min_len_260_h5/feats.scp $srcdir/train_subset_fbank_40_tr_no_sil_min_len_260_h5/feats.scp $srcdir/train_subset_fbank_40_cv_reverb_no_sil_min_len_260_h5/feats.scp $srcdir/train_subset_fbank_40_cv_no_sil_min_len_260_h5/feats.scp > $destdir/feats.scp
  awk '{print $2" "$1}' $srcdir/train_subset_fbank_40_tr_no_sil_min_len_260_h5/utt2spk > $destdir/train.tgt.scp
  awk '{print $2" "$1}' $srcdir/train_subset_fbank_40_tr_reverb_no_sil_min_len_260_h5/utt2spk > $destdir/train.src.scp
  awk '{print $2" "$1}' $srcdir/train_subset_fbank_40_cv_no_sil_min_len_260_h5/utt2spk > $destdir/val.tgt.scp
  awk '{print $2" "$1}' $srcdir/train_subset_fbank_40_cv_reverb_no_sil_min_len_260_h5/utt2spk > $destdir/val.src.scp
  cat $destdir/{train,val}.src.scp | awk '{print $2}' | awk -F "-reverb" '{print $0" "$1}' > $destdir/src2tgt.map
  wc -l $destdir/*
fi
