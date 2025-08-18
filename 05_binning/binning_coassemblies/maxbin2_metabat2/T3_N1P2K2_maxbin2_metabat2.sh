#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env

run_binning() {
  GROUP=$1
  S1=$2
  S2=$3
  S3=$4
  S4=$5

  # === Directories ===
  OUT_DIR=~/Stage_Copenhague/binning/$GROUP
  mkdir -p $OUT_DIR

  ASSEMBLY=~/Stage_Copenhague/assembly/$GROUP/${GROUP}_contigs_fixed.fa

  INDIR_S1=~/Stage_Copenhague/decontamination/sample_${S1}/contaminant_free
  INDIR_S2=~/Stage_Copenhague/decontamination/sample_${S2}/contaminant_free
  INDIR_S3=~/Stage_Copenhague/decontamination/sample_${S3}/contaminant_free
  INDIR_S4=~/Stage_Copenhague/decontamination/sample_${S4}/contaminant_free

  for i in $S1 $S2 $S3 $S4; do
    # === Go to the read directory ===
    WORKDIR_READS=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free

    cd $WORKDIR_READS

    # === Prepare input files ===
    if [ ! -f sample_${i}_1.fastq ]; then
      echo "Decompressing read1..."
      gunzip -c sample_${i}_contaminant_free_read1_paired.fq.gz > sample_${i}_1.fastq
    fi

    if [ ! -f sample_${i}_2.fastq ]; then
      echo "Decompressing read2..."
      gunzip -c sample_${i}_contaminant_free_read2_paired.fq.gz > sample_${i}_2.fastq
    fi
  done

  # === Run the binning ===
  echo "Beginning the binning for $GROUP group..."

  metawrap binning \
    -o $OUT_DIR \
    -t 8 \
    -a $ASSEMBLY \
    --metabat2 --maxbin2 \
    $INDIR_S1/sample_${S1}_1.fastq \
    $INDIR_S1/sample_${S1}_2.fastq \
    $INDIR_S2/sample_${S2}_1.fastq \
    $INDIR_S2/sample_${S2}_2.fastq \
    $INDIR_S3/sample_${S3}_1.fastq \
    $INDIR_S3/sample_${S3}_2.fastq \
    $INDIR_S4/sample_${S4}_1.fastq \
    $INDIR_S4/sample_${S4}_2.fastq

echo "[`date`] Binning finished for $GROUP"
}

export -f run_binning

# Read the third line (the T3_N1P2K2 group) and pass the columns to the function
read GROUP S1 S2 S3 S4 < <(sed -n '3p' ~/Stage_Copenhague/assembly/coassembly_groups.tsv)

# Calling the function with the correct arguments
run_binning $GROUP $S1 $S2 $S3 $S4

