#!/bin/bash

anvi_summarize_V2_and_MAGs_all_samples() {

  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  i=$1

  # === Inputs ===
  ROOT=~/Stage_Copenhague/visualisation_anvio/sample_${i}

  CONTIG_DB=$ROOT/input_files/sample_${i}_contigs_copy.db

  PROFILE_DB=$ROOT/input_files/PROFILE.db

  COLLECTION_NAME_ARCHAEA=metawrap_bins_sample_${i}_single_assembly_Archaea_V2

  COLLECTION_NAME_MAGS=sample_${i}_MAGs

  # === Outputs ===
  OUT_DIR_1=$ROOT/anvi_summarize/sample_${i}_Archaea_V2_summarize

  OUT_DIR_2=$ROOT/anvi_summarize/sample_${i}_MAGs_summarize

  # === Summarize the Archaea collection V2 ===

  echo "[INFO] $(date) Beginning the anvi-summarize command for the ${COLLECTION_NAME_ARCHAEA} collection..."

  anvi-summarize \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C $COLLECTION_NAME_ARCHAEA \
    -o $OUT_DIR_1 \
    --report-aa-seqs-for-gene-calls

  echo "[INFO] $(date) The anvi-summarize command worked successfully."
  echo "You can find the folder containing the summary here : $OUT_DIR_1"

  # === Summarize the MAGs collection (without the bad quality bins) ===

  echo "[INFO] $(date) Beginning the anvi-summarize command for the ${COLLECTION_NAME_ARCHAEA} collection..."

  anvi-summarize \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C $COLLECTION_NAME_MAGS \
    -o $OUT_DIR_2 \
    --report-aa-seqs-for-gene-calls

  echo "[INFO] $(date) The anvi-summarize command worked successfully."
  echo "You can find the folder containing the summary here : $OUT_DIR_2"
}

# === Exporting the function ===

export -f anvi_summarize_V2_and_MAGs_all_samples

# === Run the function ===
for i in $(seq -w 1 24); do
  anvi_summarize_V2_and_MAGs_all_samples $i
done


