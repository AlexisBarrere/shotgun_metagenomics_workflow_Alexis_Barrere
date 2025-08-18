#!/bin/bash

# === Load conda only once ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate quast_env

# === Function for one sample ===
run_metaquast() {
  i=$1

  # Define directories and filenames
  ROOT=~/Stage_Copenhague/assembly/sample_$i

  IN_DIR=$ROOT/sample_${i}_contigs_fixed.fa

  OUT_DIR=$ROOT/metaquast_results
  mkdir -p $OUT_DIR # Create output directory if it doesn't exist

  echo "Launch of MetaQUAST for assembly evaluation..."
  metaquast $IN_DIR -o $OUT_DIR --threads 8 --contig-thresholds 1000,1200,1679,2500,5000,10000,25000 \
  --max-ref-number 0

  echo "Analysis completed for sample $i! The results are available in : $OUT_DIR"

}

export -f run_metaquast # Each command executed with parallel is executed in a new bash process.
			# This process does not recognise the functions defined in the parent shell
			# unless they are explicitly exported, as shown here.

# === Launch in login shell to ensure conda works ===
echo -e "10\n17\n18\n20\n21\n22\n23\n24" | parallel -j 4 run_metaquast {}
echo
echo "MetaQUAST analysis completed."

