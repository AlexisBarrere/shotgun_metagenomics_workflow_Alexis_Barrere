#!/bin/bash

run_latest_analyses() {

  i=$1

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  # === Inputs ===
  BAM_FILE=~/Stage_Copenhague/mapping/sample_${i}/sam_and_bam/sample_${i}.bam

  CONTIG_DB=~/Stage_Copenhague/anvio_db/anvio_contigs_db/sample_${i}_contigs_copy.db

  IN_BIN=~/Stage_Copenhague/binning/sample_${i}/bin_refinement/metawrap_1_1000_bins.contigs

  OUT_BIN=~/Stage_Copenhague/anvio_collections/sample_${i}_bins.txt
  mkdir -p "$(dirname "$OUT_BIN")"

  PROFILE_DB=~/Stage_Copenhague/anvio_db/anvio_single_profile_db/sample_${i}/PROFILE.db

  COLLECTION_NAME=metawrap_bins_sample_${i}_single_assembly

  # === Output ===
  OUT_DIR=~/Stage_Copenhague/anvio_db/anvio_single_profile_db/sample_${i}
  mkdir -p $OUT_DIR

  OUTPUT_TAX=~/Stage_Copenhague/anvio_collections/sample_${i}_scg_taxonomy.txt
  mkdir -p $(dirname "$OUTPUT_TAX")

  OUT_ANVIO_SUMMARY=~/Stage_Copenhague/anvio_summary/sample_${i}_summary

  # --- 05 - Profiling ---
  echo "[INFO] $(date) Running anvi-profile for sample $i..."

  anvi-profile -i $BAM_FILE \
             -c $CONTIG_DB \
             --min-contig-length 2000 \
             --sample-name sample_${i}_single_assembly \
             --output-dir $OUT_DIR \
             --force-overwrite \
             -T 4 \
             --cluster-contigs

  echo "[INFO] $(date) The Anvi'o profile database for sample $i is created. You can find it in $OUT_DIR."

  # --- 06 - Import collection ---
  # Replace . by _ in bin names and save as a new file
  awk -F'\t' '{gsub(/\./, "_", $2); print $1"\t"$2}' "$IN_BIN" > "$OUT_BIN"
  echo "[INFO] $(date) Formatted contig-to-bin file saved as $OUT_BIN"
  echo "[INFO] $(date) Running anvi-import-collection for sample $i..."
  anvi-import-collection $OUT_BIN \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C $COLLECTION_NAME \
    --contigs-mode

  echo "[INFO] $(date) Collection $COLLECTION_NAME successfully imported into Anvi'o."

  # --- 07 - Estimate scg taxonomy ---
  echo "[INFO] $(date) Estimating bin taxonomy for collection $COLLECTION_NAME..."

  anvi-estimate-scg-taxonomy \
  -c $CONTIG_DB \
  -p $PROFILE_DB \
  -C $COLLECTION_NAME \
  -o $OUTPUT_TAX

  echo "[INFO] $(date) SCG-based taxonomy estimation complete. Output written to: $OUTPUT_TAX"

  # --- 08 - Summarize with Anvi'o ---
  echo "[INFO] $(date) Beginning the anvi-summarize command for sample $i..."
  anvi-summarize \
  -c $CONTIG_DB \
  -p $PROFILE_DB \
  -C $COLLECTION_NAME \
  -o $OUT_ANVIO_SUMMARY \
  --report-aa-seqs-for-gene-calls

  echo "[INFO] $(date) The anvi-summarize process is complete for sample $i. You can find the results in : $OUT_ANVIO_SUMMARY"

}

# === Exporting the function ===
export -f run_latest_analyses

# === Create a folder for the logs ===
mkdir -p ~/Stage_Copenhague/logs/step_05_to_08

# === Run in parallel, with one log file per sample ===
seq -w 1 24 | parallel -j 4 --bar 'run_latest_analyses {} &> ~/Stage_Copenhague/logs/step_05_to_08/sample_{}_latest_analyses.log'

echo "[INFO] $(date) All the latest analyses are done for sample 02 to 24."

