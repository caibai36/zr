stage=1

. local/kaldi_conf.sh
. path.sh

if [ $stage -le 0 ]; then
    sh local/download.sh
fi
