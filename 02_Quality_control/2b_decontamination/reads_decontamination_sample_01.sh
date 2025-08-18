#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate bowtie2_env

IN_DIR=~/Stage_Copenhague/trimming/clean_reads/sample_01/after_fastp

OUT_DIR=~/Stage_Copenhague/decontamination/sample_01
mkdir -p "$OUT_DIR"
mkdir -p "$OUT_DIR/no_wheat"
mkdir -p "$OUT_DIR/no_human"
mkdir -p "$OUT_DIR/contaminant_free"

R1_PAIRED=$IN_DIR/sample_01_read1_paired_cleaned.fq.gz

R2_PAIRED=$IN_DIR/sample_01_read2_paired_cleaned.fq.gz

R1_UNPAIRED=$IN_DIR/sample_01_read1_unpaired_cleaned.fq.gz

R2_UNPAIRED=$IN_DIR/sample_01_read2_unpaired_cleaned.fq.gz

# === paths to indexes ===
WHEAT_INDEX=~/Stage_Copenhague/contaminants/wheat/wheat_index
HUMAN_INDEX=~/Stage_Copenhague/contaminants/human/human_index
PHIX_INDEX=~/Stage_Copenhague/contaminants/PhiX/phix_index

# === Wheat decontamination ===
# For PAIRED reads :
bowtie2 -x $WHEAT_INDEX \
 -1 $R1_PAIRED -2 $R2_PAIRED \
 --very-sensitive -p 4 \
 --un-conc-gz $OUT_DIR/no_wheat/sample_01_no_wheat_paired.fq.gz \
 -S /dev/null

# For UNPAIRED reads1 :
bowtie2 -x $WHEAT_INDEX \
 -U $R1_UNPAIRED \
 --very-sensitive -p 4 \
 --un-gz $OUT_DIR/no_wheat/sample_01_no_wheat_read1_unpaired.fq.gz \
 -S /dev/null

# For UNPAIRED reads 2 :
bowtie2 -x $WHEAT_INDEX \
 -U $R2_UNPAIRED \
 --very-sensitive -p 4 \
 --un-gz $OUT_DIR/no_wheat/sample_01_no_wheat_read2_unpaired.fq.gz \
 -S /dev/null

# === Human decontamination ===
# for PAIRED reads :
bowtie2 -x $HUMAN_INDEX \
 -1 $OUT_DIR/no_wheat/sample_01_no_wheat_paired.fq.1.gz -2 $OUT_DIR/no_wheat/sample_01_no_wheat_paired.fq.2.gz \
 --very-sensitive -p 4 \
 --un-conc-gz $OUT_DIR/no_human/sample_01_no_wheat_no_human_paired.fq.gz \
 -S /dev/null

# for UNPAIRED reads 1 :
bowtie2 -x $HUMAN_INDEX \
 -U $OUT_DIR/no_wheat/sample_01_no_wheat_read1_unpaired.fq.gz \
 --very-sensitive -p 4 \
 --un-gz $OUT_DIR/no_human/sample_01_no_wheat_no_human_read1_unpaired.fq.gz \
 -S /dev/null

# for UNPAIRED reads 2 :
bowtie2 -x $HUMAN_INDEX \
 -U $OUT_DIR/no_wheat/sample_01_no_wheat_read2_unpaired.fq.gz \
 --very-sensitive -p 4 \
 --un-gz $OUT_DIR/no_human/sample_01_no_wheat_no_human_read2_unpaired.fq.gz \
 -S /dev/null

# === PhiX decontamination ===
# for PAIRED reads :
bowtie2 -x $PHIX_INDEX \
 -1 $OUT_DIR/no_human/sample_01_no_wheat_no_human_paired.fq.1.gz -2 $OUT_DIR/no_human/sample_01_no_wheat_no_human_paired.fq.2.gz \
 --very-sensitive -p 4 \
 --un-conc-gz $OUT_DIR/contaminant_free/sample_01_contaminant_free_paired.fq.gz \
 -S /dev/null

# for UNPAIRED reads 1 :
bowtie2 -x $PHIX_INDEX \
 -U $OUT_DIR/no_human/sample_01_no_wheat_no_human_read1_unpaired.fq.gz \
 --very-sensitive -p 4 \
 --un-gz $OUT_DIR/contaminant_free/sample_01_contaminant_free_read1_unpaired.fq.gz \
 -S /dev/null

# for UNPAIRED reads 2 :
bowtie2 -x $PHIX_INDEX \
 -U $OUT_DIR/no_human/sample_01_no_wheat_no_human_read2_unpaired.fq.gz \
 --very-sensitive -p 4 \
 --un-gz $OUT_DIR/contaminant_free/sample_01_contaminant_free_read2_unpaired.fq.gz \
 -S /dev/null

echo "-----> Sample 01 decontamination complete. Clean files are in: $OUT_DIR/contaminant_free"
