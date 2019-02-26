###################################################################################
# File: kaldi_conf.sh
# Implemented at 22:30 on 08 January 2018 by bin-wu.
# Script to create the basic directory structure
###################################################################################
# Please set custom kaldi root.
KALDI_ROOT=/project/nakamura-lab08/Work/bin-wu/share/tools/kaldi # CHECKME

# Set path.sh: contains the path to the Kaldi source directory
#      replace the first line of path.sh with your custom kaldi root.
#      append at the end of file with the main root and related directories to PATH
sed -e "1 c export KALDI_ROOT=$KALDI_ROOT" \
    -e "$ a \ " \
    -e "$ a export MAIN_ROOT=\$PWD/../../.." \
    -e "$ a export PATH=\${MAIN_ROOT}/utils:\$PATH" $KALDI_ROOT/egs/wsj/s5/path.sh > path.sh

# Set cmd.sh: contains different commands.
echo 'export train_cmd="run.pl --mem 4G"\nexport decode_cmd="run.pl --mem 4G"\nexport cuda_cmd="run.pl --gpu 1"' > cmd.sh

# Create symbolic links to essential scripts to build kaldi system.
# steps: contains essential scripts for creating an ASR system
# utils: contains scripts to modify Kaldi files in certain ways
ln -sf $KALDI_ROOT/egs/wsj/s5/steps/ steps
ln -sf $KALDI_ROOT/egs/wsj/s5/utils/ utils

