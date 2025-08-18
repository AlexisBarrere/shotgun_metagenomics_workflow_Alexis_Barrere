#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

run_renaming_with_anvio() {

  i=$1

  ROOT=~/Stage_Copenhague/assembly/sample_$i

  IN_DIR=$ROOT/final.contigs.fa

  OUT_DIR=$ROOT/sample_${i}_contigs_fixed.fa

  REPORT=$ROOT/name_conversions.txt

  echo "Renaming contigs for sample $i..."

  anvi-script-reformat-fasta $IN_DIR -o $OUT_DIR \
   --prefix sample_${i}_contig \
   --min-len 1000 --simplify-names --report $REPORT

  echo "Renaming completed for sample $i."
  echo

}

export -f run_renaming_with_anvio

seq -w 1 24 | parallel -j 4 run_renaming_with_anvio


