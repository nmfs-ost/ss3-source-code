#!/bin/sh

# put ss in path
echo $PATH
export PATH=$PATH:./ss
echo $PATH

# loop through the models
cd models
for dir in */; do
    echo $dir
	cd $dir
	ss
	cd ..
done
