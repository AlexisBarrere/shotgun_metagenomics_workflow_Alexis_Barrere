#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate trim_env

IN_DIR=~/Stage_Copenhague/raw_data_full/sample_01

TRIMMOMATIC_OUT_DIR=~/Stage_Copenhague/trimming/clean_reads/sample_01_sixth_test/after_trimmomatic
mkdir -p $TRIMMOMATIC_OUT_DIR

FASTP_REPORT_DIR=~/Stage_Copenhague/trimming/fastp_reports/sample_01_sixth_test
mkdir -p $FASTP_REPORT_DIR

FASTP_OUT_DIR=~/Stage_Copenhague/trimming/clean_reads/sample_01_sixth_test/after_fastp
mkdir -p $FASTP_OUT_DIR

ADAPTERS=~/Stage_Copenhague/trimming/adapters/NexteraPE.fa

# === Step 1 - Trimmomatic ===
trimmomatic PE $IN_DIR/zr11927_1_read1.fastq $IN_DIR/zr11927_1_read2.fastq \
-threads 4 -phred33 \
$TRIMMOMATIC_OUT_DIR/read1_paired.fq.gz $TRIMMOMATIC_OUT_DIR/read1_unpaired.fq.gz \
$TRIMMOMATIC_OUT_DIR/read2_paired.fq.gz $TRIMMOMATIC_OUT_DIR/read2_unpaired.fq.gz \
ILLUMINACLIP:$ADAPTERS:3:15:5:1:true \
LEADING:20 \
TRAILING:20 \
SLIDINGWINDOW:4:25 \
MINLEN:80

# === Step 2a - Fastp on paired reads
fastp \
	--in1 "$TRIMMOMATIC_OUT_DIR"/read1_paired.fq.gz \
	--in2 "$TRIMMOMATIC_OUT_DIR"/read2_paired.fq.gz \
	--out1 "$FASTP_OUT_DIR"/read1_paired_cleaned.fq.gz \
	--out2 "$FASTP_OUT_DIR"/read2_paired_cleaned.fq.gz \
	--trim_poly_g \
	--length_required 80 \
  	--thread 4 \
  	--html "$FASTP_REPORT_DIR"/fastp_paired.html \
  	--json "$FASTP_REPORT_DIR"/fastp_paired.json

# === Step 2b - Fastp on unpaired read1
fastp \
 	--in1 "$TRIMMOMATIC_OUT_DIR"/read1_unpaired.fq.gz \
	--out1 "$FASTP_OUT_DIR"/read1_unpaired_cleaned.fq.gz \
	--trim_poly_g \
	--length_required 80 \
	--thread 2 \
	--html "$FASTP_REPORT_DIR"/fastp_unpaired_read1.html \
	--json "$FASTP_REPORT_DIR"/fastp_unpaired_read1.json


# === Step 2c - Fastp on unpaired read2
fastp \
	--in1 "$TRIMMOMATIC_OUT_DIR"/read2_unpaired.fq.gz \
	--out1 "$FASTP_OUT_DIR"/read2_unpaired_cleaned.fq.gz \
 	--trim_poly_g \
	--length_required 80 \
  	--thread 2 \
  	--html "$FASTP_REPORT_DIR"/fastp_unpaired_read2.html \
  	--json "$FASTP_REPORT_DIR"/fastp_unpaired_read2.json

echo "All files have been cleaned with fastp: paired + unpaired"



