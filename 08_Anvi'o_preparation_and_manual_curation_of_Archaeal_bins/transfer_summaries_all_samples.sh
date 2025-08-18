#!/bin/bash

transfer_summaries() {

  i=$1

  # === Inputs ===
  THOTH_PATH_ARCHAEA_V2=alexis@thoth:/home/alexis/Stage_Copenhague/visualisation_anvio/sample_${i}/anvi_summarize/sample_${i}_Archaea_V2_summarize

  THOTH_PATH_MAGS=alexis@thoth:/home/alexis/Stage_Copenhague/visualisation_anvio/sample_${i}/anvi_summarize/sample_${i}_MAGs_summarize

  WSL_PATH=/home/alexis/Stage_Copenhague/visualisation_anvio/sample_${i}/anvi_summarize

  # === Transfer the data ===
  scp -r $THOTH_PATH_ARCHAEA_V2 $WSL_PATH

  scp -r $THOTH_PATH_MAGS $WSL_PATH

  echo "The transfer for sample $i is done."
}

# === Exporting the function ===
export -f transfer_summaries

# === Run the function ===
for i in $(seq -w 1 24); do
  transfer_summaries $i
done 