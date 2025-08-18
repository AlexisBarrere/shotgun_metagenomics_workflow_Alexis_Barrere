#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
PROFILE_DB_1=$ROOT/profile_db/MAGs/*/PROFILE.db

CONTIG_DB_1=$ROOT/contigs_db/MAGs_contigs.db

# === Outputs ===
OUT_DIR_1=$ROOT/profile_db/MAGs_MERGED

# === anvi-merge ===
anvi-merge $PROFILE_DB_1 \
           -o $OUT_DIR_1 \
           -c $CONTIG_DB_1

echo "The anvi-merge command is done for all profiles (MAGs)."