#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

# === Inputs ===
ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

MAGS_GENOMES=~/Stage_Copenhague/drep_analysis/drep_output_without_reference/dereplicated_genomes

# === Outputs ===

REFORMATTED_MAGS=$ROOT/reformatted_MAGs_genomes
mkdir -p $REFORMATTED_MAGS

cd $MAGS_GENOMES

for f in *.fa; do
  base=$(basename "$f" -contigs.fa)
  anvi-script-reformat-fasta "$f" \
   -o $REFORMATTED_MAGS/${base}_renamed.fa \
    --simplify-names \
    --report-file "$REFORMATTED_MAGS/${base}_report.txt" \
    --prefix "$base"
done 