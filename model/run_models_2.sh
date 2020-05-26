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
	# check that report file was created to confirm model ran
	FILE=./Report.sso
    if [ -f "$FILE" ]; then
        echo "$FILE exist"
    else 
        echo "$FILE does not exist"
		exit 1
    fi
	cd ..
done
