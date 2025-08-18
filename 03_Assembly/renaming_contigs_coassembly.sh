#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

run_renaming_with_anvio() {

  GROUP=$1

  ROOT=~/Stage_Copenhague/assembly/$GROUP

  IN_DIR=$ROOT/final.contigs.fa

  OUT_DIR=$ROOT/${GROUP}_contigs_fixed.fa

  REPORT=$ROOT/name_conversions.txt

  echo "Renaming contigs for $GROUP co-assembly..."

  anvi-script-reformat-fasta $IN_DIR \
                             -o $OUT_DIR \
                             --prefix ${GROUP}_contig \
                             --min-len 1000 \
                             --simplify-names \
                             --report $REPORT

  echo "Renaming completed for $GROUP group."
  echo

}

export -f run_renaming_with_anvio

tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 4 --colsep '\t' run_renaming_with_anvio {1}

