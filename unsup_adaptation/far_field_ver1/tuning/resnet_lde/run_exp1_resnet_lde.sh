
source ~/.bashrc

data_dir=data/resnet_lde/
num_spk=`awk 'BEGIN{s=0;}{if($2>s)s=$2;}END{print s+1}' $data_dir/utt2spkid`

echo NUM SPKS is $num_spk

python resnet_lde_scripts/main9.py --no-cuda --train $data_dir/train.scp --cv $data_dir/cv.scp --mlf $data_dir/utt2spkid --num $num_spk
