#!/bin/sh

# loop through the reference files to rename.
cd ./ss_example_files/models
for dir in */; do
    echo $dir
	cd $dir
	rename 's/.sso/_ref.sso/' *.sso
	rename 's/.par/_ref.par/' *.par
	cd ..
done
