#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env

# === Inputs ===
ROOT=~/Stage_Copenhague/binning/sample_01

MAXBIN2_DIR=$ROOT/maxbin2_bins/

METABAT2_DIR=$ROOT/metabat2_bins/

CONCOCT_DIR=$ROOT/concoct_bins/

# === Output ===
OUT_DIR=~/Stage_Copenhague/binning/sample_01/bin_refinement_test2/
mkdir -p $OUT_DIR

# === Running the bin_refinement module ===

metawrap bin_refinement -o $OUT_DIR -t 24 -A $MAXBIN2_DIR \
  -B $METABAT2_DIR -C $CONCOCT_DIR \
  -c 0 -x 1000

echo "The bin_refinement process of sample 01 is finished. You can find the results in : $OUT_DIR."


