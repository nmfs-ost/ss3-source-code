#!/bin/sh

# put ss in path
export PATH=$PATH:/var/lib/jenkins/workspace/stock-synthesis-model/ss_bin

# loop through the models
cd models
for dir in */; do
    echo $dir
	cd $dir
	ss -nox
	cd ..
done
for dir in */; do
    echo $dir
	cd $dir
		# check report file exists to confirm model ran, write result to screen
	FILE=./Report.sso
    if [ -f "$FILE" ]; then
        echo "$FILE exists"
    else 
        echo "$FILE does not exist"
    fi
	cd ..
done
for dir in */; do # fail the test if any report files are missing
	cd $dir
	FILE=./Report.sso
    if [ ! -f "$FILE" ]; then
	  exit 1
    fi
	cd ..
done
