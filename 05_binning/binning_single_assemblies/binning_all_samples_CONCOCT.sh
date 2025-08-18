#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env

run_binning() {
  i=$1

  # === Set working directories ===
  WORKDIR=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free/
  OUT_DIR=~/Stage_Copenhague/binning/sample_$i
  mkdir -p $OUT_DIR
  ASSEMBLY=~/Stage_Copenhague/assembly/sample_$i/sample_${i}_contigs_fixed.fa


  # === Go to the read directory ===
  cd $WORKDIR


  # === Prepare input files ===
  if [ ! -f sample_${i}_1.fastq ]; then
    echo "Decompressing read1..."
    gunzip -c sample_${i}_contaminant_free_read1_paired.fq.gz > sample_${i}_1.fastq
  fi

  if [ ! -f sample_${i}_2.fastq ]; then
    echo "Decompressing read2..."
    gunzip -c sample_${i}_contaminant_free_read2_paired.fq.gz > sample_${i}_2.fastq
  fi


  # === Run the binning ===
  echo "Beginning the binning for sample $i..."

  # Limit OpenBLAS to 1 thread to avoid known CONCOCT bug
  export OPENBLAS_NUM_THREADS=1

  metawrap binning \
    -o $OUT_DIR \
    -t 8 \
    -a $ASSEMBLY \
    --concoct \
    sample_${i}_1.fastq \
    sample_${i}_2.fastq

  echo "Binning finished for sample $i."
  echo
}

export -f run_binning

seq -w 1 24 | parallel -j 4 --bar run_binning {}

echo "Binning is complete for samples 01 to 24."
echo "You can find the output files by following this path : ~/Stage_Copenhague/binning"
