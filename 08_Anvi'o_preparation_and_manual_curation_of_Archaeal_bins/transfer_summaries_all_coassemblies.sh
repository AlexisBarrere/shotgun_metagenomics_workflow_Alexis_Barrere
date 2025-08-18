#!/bin/bash

transfer_summaries() {

  GROUP=$1

  # === Inputs ===
  THOTH_PATH_ARCHAEA_V2=alexis@thoth:/home/alexis/Stage_Copenhague/visualisation_anvio/${GROUP}/anvi_summarize/${GROUP}_Archaea_V2_summarize

  THOTH_PATH_MAGS=alexis@thoth:/home/alexis/Stage_Copenhague/visualisation_anvio/${GROUP}/anvi_summarize/${GROUP}_MAGs_summarize

  WSL_PATH=/home/alexis/Stage_Copenhague/visualisation_anvio/${GROUP}/anvi_summarize

  # === Transfer the data ===
  scp -r $THOTH_PATH_ARCHAEA_V2 $WSL_PATH

  scp -r $THOTH_PATH_MAGS $WSL_PATH

  echo "The transfer for the $GROUP group is done."
}

# === Exporting the function ===
export -f transfer_summaries

# === Run the function ===
tail -n +2 ~/Stage_Copenhague/visualisation_anvio/coassembly_groups.tsv | \
cut -f1 | \
parallel -j 2 --bar 'transfer_summaries {}'