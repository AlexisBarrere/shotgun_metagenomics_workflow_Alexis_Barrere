#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
INTERNAL_GENOMES_1=$ROOT/pangenome/internal-genomes_MAGs.txt

# === Outputs ===
OUT_FILE_1=$ROOT/pangenome/MAGs-PAN-GENOMES.db

OUT_DIR_1=$ROOT/pangenome/MAGs-PAN-COMPUTED

# === Generate a genomes storage ===
# --- MAGs ---
anvi-gen-genomes-storage -i $INTERNAL_GENOMES_1 \
                         -o $OUT_FILE_1

# === Compute the pangenome ===
# --- MAGs ---
anvi-pan-genome -g $OUT_FILE_1 \
                --use-ncbi-blast \
                --minbit 0.5 \
                --mcl-inflation 10 \
                --project-name MAGs-PAN \
                --num-threads 20 \
                -o $OUT_DIR_1