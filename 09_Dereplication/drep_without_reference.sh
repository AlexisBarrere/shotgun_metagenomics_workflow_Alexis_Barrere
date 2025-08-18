#!/bin/bash

source ~/miniconda3/etc/profile.d/conda.sh
conda activate drep_env

# === Inputs ===
GENOMES_FOLDER="/home/alexis/Stage_Copenhague/drep_analysis/genomes_symlinks_without_reference/"

# === outputs ===
OUT_DIR="/home/alexis/Stage_Copenhague/drep_analysis/drep_output_without_reference"

dRep dereplicate $OUT_DIR \
  -g $GENOMES_FOLDER/*.fa \
  -p 8 \
  -comp 50 \
  -con 10 \
  -sa 0.95


