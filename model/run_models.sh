#!/bin/sh

# put ss in path
SS_HOME=./ss
export SS_HOME
PATH=$SS_HOME:$PATH

# loop through the models
cd models
for dir in */; do
    echo $dir
	cd $dir
	ss
	cd ..
done
