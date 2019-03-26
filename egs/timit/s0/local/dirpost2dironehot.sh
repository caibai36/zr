timepost2timeonehot() {
    # $1: post file with time index
    # $2: onehot file with time index
    # paste the time and onehot representation of posterigram of one post file
    # and write the onehot represenation to the onehot file
    paste <(cat $1 | awk '{print $1}') <(cat $1 |tr -s '\t' ' '| cut -d' ' -f2- | python local/post2onehot.py --delimiter=" ") | tr -s '\t' ' ' | sed 's: $::' > $2
}

dirpost2dironehot() {
    # $1: post directory of post files
    # $2: one hot directory of onehot files
    # convert files from post represenation to onehot representation
    for file in $1/*; do
	file=$(basename $file)
	timepost2timeonehot $1/$file $2/$file
    done
}

post_dir=$1
onehot_dir=$2
mkdir -p $onehot_dir
dirpost2dironehot $post_dir $onehot_dir
