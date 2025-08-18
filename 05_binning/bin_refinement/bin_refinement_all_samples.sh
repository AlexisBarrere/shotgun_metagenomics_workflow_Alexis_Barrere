#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env

run_bin_refinement() {

  i=$1

  # === Inputs ===
  ROOT=~/Stage_Copenhague/binning/sample_$i

  MAXBIN2_DIR=$ROOT/maxbin2_bins/

  METABAT2_DIR=$ROOT/metabat2_bins/

  CONCOCT_DIR=$ROOT/concoct_bins/

  # === Output ===
  OUT_DIR=~/Stage_Copenhague/binning/sample_${i}/bin_refinement/
  mkdir -p $OUT_DIR

  # === Running the bin_refinement module ===
   metawrap bin_refinement -o $OUT_DIR -t 24 -A $MAXBIN2_DIR \
     -B $METABAT2_DIR -C $CONCOCT_DIR \
     -c 1 -x 1000
}

export -f run_bin_refinement

seq -w 1 24 | parallel -j 2 --bar run_bin_refinement {}

echo "The bin_refinement module is done for samples 01 to 24."

echo "You can find the output files by following this path : ~/Stage_Copenhague/binning/sample_xx/bin_refinement/"
