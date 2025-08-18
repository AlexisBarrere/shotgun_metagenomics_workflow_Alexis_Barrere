#!/bin/bash

# === Activating the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate quast_env

process_metaquast_coassemblies() {

  GROUP=$1

  # === Define input directory ===
  ROOT=~/Stage_Copenhague/assembly/$GROUP

  # === Define input/output ===
  ASSEMBLY=$ROOT/${GROUP}_contigs_fixed.fa
  OUT_DIR=$ROOT/metaquast_results
  mkdir -p $OUT_DIR

  # === Launch MetaQUAST ===
  echo "Launching MetaQUAST for $GROUP co-assembly evaluation..."

  metaquast $ASSEMBLY -o $OUT_DIR --threads 8 --contig-thresholds 1000,5000,10000,25000 \
    --max-ref-number 0

  echo "Analysis completed for $GROUP co-assembly ! The results are available in : $OUT_DIR"
}

export -f process_metaquast_coassemblies

tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 4 --colsep '\t' process_metaquast_coassemblies {1}

