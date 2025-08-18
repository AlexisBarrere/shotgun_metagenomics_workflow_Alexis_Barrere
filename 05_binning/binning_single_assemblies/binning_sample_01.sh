#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env


# === Set working directories ===
WORKDIR=~/Stage_Copenhague/decontamination/sample_01/contaminant_free/
OUT_DIR=~/Stage_Copenhague/binning/sample_01
mkdir -p $OUT_DIR
ASSEMBLY=~/Stage_Copenhague/assembly/sample_01/sample_01_contigs_fixed.fa


# === Go to the read directory ===
cd $WORKDIR


# === Prepare input files ===
if [ ! -f sample_01_1.fastq ]; then
  echo "Decompressing read1..."
  gunzip -c sample_01_contaminant_free_read1_paired.fq.gz > sample_01_1.fastq
fi

if [ ! -f sample_01_2.fastq ]; then
  echo "Decompressing read2..."
  gunzip -c sample_01_contaminant_free_read2_paired.fq.gz > sample_01_2.fastq
fi

# === Binning step ===

echo "Beginning the binning for sample 01..."

# Limit OpenBLAS to 1 thread to avoid known CONCOCT bug
export OPENBLAS_NUM_THREADS=1

metawrap binning \
  -o $OUT_DIR \
  -t 24 \
  -a $ASSEMBLY \
  --metabat2 --maxbin2 --concoct \
  sample_01_1.fastq \
  sample_01_2.fastq

echo "Binning finished for sample 01."
echo
echo "Deleting unzipped files (to free up space)..."
rm sample_01_1.fastq sample_01_2.fastq



