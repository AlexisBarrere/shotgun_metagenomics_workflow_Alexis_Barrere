#!/bin/bash

# Folder containing FastQC results
FASTQC_DIR=~/Stage_Copenhague/fastqc_results

# Output folder for the MultiQC report
OUT_DIR=${FASTQC_DIR}/multiqc_report

# Create the output folder if it does not exist
mkdir -p "OUT_DIR"

# Go to the FastQC results folder
cd "$FASTQC_DIR" || { echo "File not found : $FASTQC_DIR"; exit 1; }

# Run MultiQC
multiqc . -o "$OUT_DIR"

echo "Report generated in : $OUT_DIR"
