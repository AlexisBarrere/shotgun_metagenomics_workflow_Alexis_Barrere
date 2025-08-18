#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metawrap_env

run_bin_refinement() {

  GROUP=$1

  # === Inputs ===
  ROOT=~/Stage_Copenhague/binning

  MAXBIN2_DIR=$ROOT/$GROUP/maxbin2_bins/

  METABAT2_DIR=$ROOT/$GROUP/metabat2_bins/

  CONCOCT_DIR=$ROOT/${GROUP}_concoct/concoct_bins/

  # === Outputs ===
  OUT_DIR=~/Stage_Copenhague/binning/$GROUP/bin_refinement/
  mkdir -p $OUT_DIR

  LOG_FILE=$OUT_DIR/bin_refinement.log

  # === Running the bin_refinement module ===
  metawrap bin_refinement -o $OUT_DIR -t 24 -A $MAXBIN2_DIR \
    -B $METABAT2_DIR -C $CONCOCT_DIR \
    -c 1 -x 1000 2>&1 | tee $LOG_FILE
}

export -f run_bin_refinement

tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 2 --bar --colsep '\t' run_bin_refinement {1}

echo "The bin_refinement module is done for all the co-assembly groups."


