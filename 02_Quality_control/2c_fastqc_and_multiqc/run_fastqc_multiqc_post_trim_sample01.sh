#!/bin/bash

SECONDS=0

# === Input files ===
TRIM_DIR=~/Stage_Copenhague/trimming/clean_reads/sample_01_sixth_test/after_trimmomatic
FASTP_DIR=~/Stage_Copenhague/trimming/clean_reads/sample_01_sixth_test/after_fastp

# === FASTQC output files ===
FASTQC_TRIM_OUT=~/Stage_Copenhague/trimming/fastqc_post_trim/sample_01_sixth_test/after_trimmomatic
mkdir -p $FASTQC_TRIM_OUT

FASTQC_FASTP_OUT=~/Stage_Copenhague/trimming/fastqc_post_trim/sample_01_sixth_test/after_fastp
mkdir -p $FASTQC_FASTP_OUT

# === MULTIQC output files ===
MULTIQC_TRIM_OUT=~/Stage_Copenhague/trimming/MultiQC_Post_Trimming/multiqc_post_trim_V6/after_trimmomatic
mkdir -p $MULTIQC_TRIM_OUT

MULTIQC_FASTP_OUT=~/Stage_Copenhague/trimming/MultiQC_Post_Trimming/multiqc_post_trim_V6/after_fastp
mkdir -p $MULTIQC_FASTP_OUT


# === FastQC analysis after Trimmomatic ===
echo "--> FastQC on files after Trimmomatic..."
find "$TRIM_DIR" -name "*.fq.gz" | parallel -j 4 "fastqc -o \"$FASTQC_TRIM_OUT\" {}"

# === FastQC analysis after Fastp ===
echo "--> FastQC on files after Trimmomatic + Fastp..."
find "$FASTP_DIR" -name "*.fq.gz" | parallel -j 4 "fastqc -o \"$FASTQC_FASTP_OUT\" {}"

# === MultiQC analysis ===
echo "--> MultiQC (after Trimmomatic)..."
multiqc "$FASTQC_TRIM_OUT" -o "$MULTIQC_TRIM_OUT"

echo "--> MultiQC (after Trimmomatic + Fastp)..."
multiqc "$FASTQC_FASTP_OUT" -o "$MULTIQC_FASTP_OUT"

# Total time
duration=$SECONDS
echo
echo "Analysis completed in $((duration / 60)) minutes and $(($duration % 60)) seconds."
