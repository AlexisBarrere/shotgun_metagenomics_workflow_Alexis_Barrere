#!/bin/bash

# Measures execution time
SECONDS=0

# Directory containing fastq files
DATA_DIR=~/Stage_Copenhague/raw_data_full

# Directory for results
OUT_DIR=~/Stage_Copenhague/fastqc_results
mkdir -p "$OUT_DIR"

# Auto-detection of the number of threads available
TOTAL_THREADS=$(nproc)

# We are only taking a quarter, to keep things reasonable
THREADS=$((TOTAL_THREADS / 4))

echo "$TOTAL_THREADS threads detected on this server."
echo "Use of $THREADS threads for parallel execution of FastQC."
echo "Files processed from : $DATA_DIR"
echo "Results saved in : $OUT_DIR"

# Parallel launch of FastQC
find "$DATA_DIR" -name "*.fastq" | parallel -j $THREADS '
    input_file={}
    # Retrieve the name of the parent folder (e.g. sample_1)
    sample_name=$(basename $(dirname "$input_file"))
    # Create a subfolder in OUT_DIR for this sample
    mkdir -p "'"$OUT_DIR"'/$sample_name"
    # Run FastQC on the file, output to this subfolder
    fastqc -o "'"$OUT_DIR"'/$sample_name" "$input_file"
'

# Display of execution time
duration=$SECONDS
echo
echo "Analysis completed in $(($duration / 60)) minutes and $(($duration % 60)) seconds."
