#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
CONTIG_DB_1=$ROOT/contigs_db/MAGs_contigs.db

PROFILE_DB_1=$ROOT/profile_db/MAGs_MERGED/PROFILE.db

COLLECTION_NAME_1=Archaeal_MAGs

# === Outputs ===
OUTPUT_TAX_1=$ROOT/taxonomy_results/MAGs_scg_taxonomy.txt

OUTPUT_SUMMARY_1=$ROOT/anvio_summary/MAGs_summary
mkdir -p $(dirname $OUTPUT_SUMMARY_1)

# === Estimate scg taxonomy ===
# --- For MAGs ---
echo "Estimating MAGs taxonomy for $COLLECTION_NAME_1 collection..."

anvi-estimate-scg-taxonomy \
  -c $CONTIG_DB_1 \
  -p $PROFILE_DB_1 \
  -C $COLLECTION_NAME_1 \
  -o $OUTPUT_TAX_1

echo "SCG-based taxonomy estimation complete. Output written to: $OUTPUT_TAX_1"

# === Summarize with Anvi'o ===

# --- For MAGs ---
echo "Beginning the anvi-summarize command for the $COLLECTION_NAME_1 collection..."

anvi-summarize \
  -c $CONTIG_DB_1 \
  -p $PROFILE_DB_1 \
  -C $COLLECTION_NAME_1 \
  -o $OUTPUT_SUMMARY_1 \
  --report-aa-seqs-for-gene-calls \
  --init-gene-coverages \
  --force-overwrite

echo "The anvi-summarize process is complete for the $COLLECTION_NAME_1 collection. You can find the results in : $OUTPUT_SUMMARY_1"