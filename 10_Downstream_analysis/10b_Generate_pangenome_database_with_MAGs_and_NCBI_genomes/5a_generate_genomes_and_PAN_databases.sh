#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

ROOT=~/Stage_Copenhague/downstream_analysis/NCBI_pangenome

# === Inputs ===
INTERNAL_GENOME=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/pangenome/internal-genomes_MAGs.txt

EXTERNAL_GENOME=$ROOT/external-genomes_NCBI.txt

# === Outputs ===
PAN=$ROOT/PAN
mkdir -p $PAN

GENOME_STORAGE=$PAN/MAGs_NCBI-GENOMES.db

OUT_DIR_PAN_DB=$PAN/PAN_db

# === Create the genomes storage database ===
#echo "[INFO] Creating genomes storage..."
anvi-gen-genomes-storage \
  -i $INTERNAL_GENOME \
  -e $EXTERNAL_GENOME \
  -o $GENOME_STORAGE

# === Create the PAN database ===
echo "[INFO] Running anvi-pan-genome..."
anvi-pan-genome \
  -g $GENOME_STORAGE \
  --use-ncbi-blast \
  --minbit 0.5 \
  --mcl-inflation 10 \
  --project-name Pangenome_12_Archaeal_MAGs_31_NCBI_genomes \
  --num-threads 20 \
  -o $OUT_DIR_PAN_DB \
  --min-occurrence 2
echo "[DONE] Pan-genome analysis complete."
