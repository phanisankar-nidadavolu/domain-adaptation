
sitw_fwd_pass_dirs=""
for name in sitw_dev_enroll sitw_dev_test sitw_eval_enroll sitw_eval_test; do
    sitw_fwd_pass_dirs="$sitw_fwd_pass_dirs sitw/${name}_no_sil"
done
for name in sitw_dev_test sitw_eval_test; do
    for kwrd in real rt60-0.0-0.5 rt60-0.5-1.0 rt60-1.0-1.5 rt60-1.5-4.0; do
        sitw_fwd_pass_dirs="$sitw_fwd_pass_dirs sitw_reverb/${name}_reverb_${kwrd}_no_sil"
    done
done
for name in sitw_dev_test sitw_eval_test; do
    for add_noise in noise music babble chime3bg; do
        for snr in 15 10 5 0 -5; do
            sitw_fwd_pass_dirs="$sitw_fwd_pass_dirs sitw_additive/${name}_${add_noise}_snr${snr}_no_sil"
        done
    done
done

# jsalt dirs
jsalt_ami=""
for name in ami_dev_enr15 ami_dev_enr30 ami_dev_enr5 ami_dev_test ami_eval_enr15 ami_eval_enr30 ami_eval_enr5 ami_eval_test; do
    jsalt_ami=$jsalt_ami" jsalt19/jsalt19_spkdet_${name}_no_sil"
done

jsalt_babytrain=""
for name in babytrain_dev_enr15 babytrain_dev_enr30 babytrain_dev_enr5 babytrain_dev_test babytrain_eval_enr15 babytrain_eval_enr30 babytrain_eval_enr5 babytrain_eval_test; do
    jsalt_babytrain=$jsalt_babytrain" jsalt19/jsalt19_spkdet_${name}_no_sil"
done

jsalt_sri=""
for name in sri_dev_enr30 sri_dev_test sri_eval_enr30 sri_eval_test; do
    jsalt_sri=$jsalt_sri" jsalt19/jsalt19_spkdet_${name}_no_sil"
done

jsalt_dirs="$jsalt_ami $jsalt_babytrain $jsalt_sri"
fwd_pass_dirs="$jsalt_dirs voices19/voices19_challenge_eval_enroll_no_sil voices19/voices19_challenge_eval_test_no_sil \
                voices19/voices19_challenge_dev_test_no_sil voices19/voices19_challenge_dev_enroll_no_sil $sitw_fwd_pass_dirs"


for dir in $fwd_pass_dirs; do
    echo $dir
done > data/fbank_ver2_wb_mel_40/fwd_pass_dirs/fwd_pass_dir.lst
