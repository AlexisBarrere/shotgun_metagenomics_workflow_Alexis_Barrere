#!/bin/bash
set -euo pipefail

# CSV file containing links
CSV_FILE="$HOME/Stage_Copenhague/zr11927_Rawdatalinks_250506.csv"

# Destination folder
TEST_DIR="$HOME/Stage_Copenhague/raw_data_full"
mkdir -p "$TEST_DIR"

# Initialising the sample counter
sample_num=1

# Read all lines except the header
tail -n +2 "$CSV_FILE" | grep -v '^[[:space:]]*$' | while IFS=',' read -r sample_id customer_label read1_url read2_url
do
    # Clean carriage returns if present
    read1_url=$(echo "$read1_url" | tr -d '\r')
    read2_url=$(echo "$read2_url" | tr -d '\r')

    # Completeness check : skip incomplete lines
    if [[ -z "$read1_url" || -z "$read2_url" || -z "$sample_id" ]]; then
        echo "Line incomplete (sample $sample_num), move on to the next sample."
        sample_num=$((sample_num + 1))
        continue
    fi

    echo "Processing sample $sample_num : $sample_id"
    SAMPLE_DIR="$TEST_DIR/sample_$sample_num"
    mkdir -p "$SAMPLE_DIR"

    # Download and name directly the file (Read1)
    echo "Downloading Read1..."
    wget -q --show-progress -c -O "$SAMPLE_DIR/${sample_id}_read1.fastq.gz" "$read1_url"

    # Decompress and let gunzip overwrite the file
    echo "Decompressing Read1..."
    gunzip "$SAMPLE_DIR/${sample_id}_read1.fastq.gz"

    # Download Read2
    echo "Downloading Read2..."
    wget -q --show-progress -c -O "$SAMPLE_DIR/${sample_id}_read2.fastq.gz" "$read2_url"

    # Decompress Read2
    echo "Decompressing Read2..."
    gunzip "$SAMPLE_DIR/${sample_id}_read2.fastq.gz"

    echo "Sample $sample_num processed."
    echo

    sample_num=$((sample_num + 1))
done
