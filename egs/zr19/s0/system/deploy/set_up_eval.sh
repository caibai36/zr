#!/bin/bash

HOME=$PWD
# install Python dependencies
conda create -n eval --yes python=2.7 \
      cython numpy scipy h5py=2.6.0 pandas pytest pytables matplotlib scikit-learn pyyaml
source activate eval
pip install --upgrade pip
pip install $HOME/system/deploy/read_zrsc2019
pip install editdistance
pip install h5features
pip install pyyaml

# install ABXpy
ABX_DIR="$HOME/system/eval/ABXpy" # ABX evaluation system
git clone https://github.com/bootphon/ABXpy.git $ABX_DIR
cd $ABX_DIR
make install
make test
cd -

echo "Set up for evaluation is done"
