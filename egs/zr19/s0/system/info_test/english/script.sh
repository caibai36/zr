#!bin/bash
IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat < "$1"); do
  filetxt=$(basename $i)
  filewav=${filetxt%.*}.wav
  dur=$(soxi -D $HOME/databases/english/test/$filewav)
  echo $filetxt $dur
done


