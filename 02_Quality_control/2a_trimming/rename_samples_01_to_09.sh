#!/bin/bash

# Folder containing the samples :
DATA_DIR=~/Stage_Copenhague/raw_data_full

# Go into the folder :
cd "$DATA_DIR" || { echo "Error: file not found."; exit 1; }

# Rename loop for sample_1 to sample_9
for i in sample_{1..9}; do
	if [ -d "$i" ]; then
		new_name="sample_0${i#sample_}"
		echo "Renaming : $i --> $new_name"
		mv "$i" "$new_name"
	else
		echo "$i doesn't exist, ignored."
	fi
done

echo "All folders have been properly renamed."
