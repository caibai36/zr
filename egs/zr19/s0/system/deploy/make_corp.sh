#!bin/bash

# cd to ZR19_DATASETS/speech
cd $1
if [ ! -d $1 ]; then
    echo "Enter path to ZR19_DATASETS/speech"
    exit
fi
export TMP=$(mktemp -d)
correspondance="../lst/data3.train.wav.scp"
correspondance_test="../lst/data3.test.wav.scp"
DEST_DIR="../../zs19_indo"
mkdir -p $DEST_DIR/train $DEST_DIR/test
mkdir -p $DEST_DIR/train/unit $DEST_DIR/train/parallel/source $DEST_DIR/train/parallel/voice
mkdir -p $DEST_DIR/train/voice
mkdir -p $DEST_DIR/synthesis_comparison/

# all files in DATA2/train and DATA2/test go to train/unit and test/
count=0
for f in DATA2/train/SPK*/*.wav; do
    spk_id=$(echo $f | cut -d "/" -f 3)
    count=$((count+1))
    id=$(seq -f "%06g" $count $count)
    cp $f $DEST_DIR/train/unit/$spk_id"_"$id".wav"
done
# loop over correspondance file
# get pair from DAT3 and DATA1 and copy to train/parallel
# and change SPK000 to V001
IFS=$'\n'
set -f 
for i in $(cat < "$correspondance"); do
  # echo $i
   count=$((count+1))
   id=$(seq -f "%06g" $count $count)
  
   source_path=$(echo $i | cut -d " " -f 1)
   source_path=$(echo $source_path | cut -d "/" -f2-) #removing "speech/"
   source_spk=$(echo $source_path | cut -d "/" -f 3)
   
   voice_path=$(echo $i | cut -d " " -f 2)
   voice_path=$(echo $voice_path | cut -d "/" -f2-) #removing "speech/"
   echo $source_path $voice_path $source_spk   
   cp $source_path".wav" $DEST_DIR/train/parallel/source/$source_spk"_"$id".wav"
   cp $voice_path".wav" $TMP 
   mv $voice_path".wav" $DEST_DIR/train/parallel/voice/"V001_"$id".wav"
done
# all remaining files in DATA1 go to train/voice, some of them will be deleted later
# changing SPK000 to V001
set +f
for file in ./DATA1/train/*
do
    count=$((count+1))
    id=$(seq -f "%06g" $count $count)
    echo $file 
    cp $file $DEST_DIR/train/voice/"V001_"$id".wav"
done
ls $TMP/*
cp $TMP/* DATA1/train/ # restoring original archive
rm -rf $TMP
# creating test set (need alignments to create short wavs)
# get pairs from DATA3 and DATA1 and copy only DATA1 to test/
set -f
for i in $(cat < $correspondance_test); do
   count=$((count+1))
   id=$(seq -f "%06g" $count $count)
   source_path=$(echo $i | cut -d " " -f 1)
   source_path=$(echo $source_path | cut -d "/" -f2-) #removing "speech/"
   source_spk=$(echo $source_path | cut -d "/" -f 3)
   
   voice_path=$(echo $i | cut -d " " -f 2)
   voice_path=$(echo $voice_path | cut -d "/" -f2-) #removing "speech/"
   cp $source_path".wav" $DEST_DIR/test/$source_spk"_"$id".wav"
   echo $source_spk"_"$id "V001" >> $DEST_DIR/synthesis.txt
   cp $voice_path".wav" $DEST_DIR/synthesis_comparison/"V001_"$id".wav"
done

set +f
# copy all test files from DATA2 to test
for f in DATA2/test/SPK*/*.wav; do
    spk_id=$(echo $f | cut -d "/" -f 3)
    count=$((count+1))
    id=$(seq -f "%06g" $count $count)
    cp $f $DEST_DIR/test/$spk_id"_"$id".wav"
done

cd $DEST_DIR

#### Evaluation files####
# TODO : files in DEST_DIR/test should be splitted into triphones once we have the annotations

# TODO : create abx task, .item, bitrate_filelist, files_to_embed
