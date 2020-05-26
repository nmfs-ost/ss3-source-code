#!/bin/sh

# put ss in path
echo $PATH
export PATH=$PATH:/var/lib/jenkins/workspace/stock-synthesis-model/ss_bin
echo $PATH

# loop through the models
cd models
for dir in */; do
    echo $dir
	cd $dir
	ss
	cd ..
done
