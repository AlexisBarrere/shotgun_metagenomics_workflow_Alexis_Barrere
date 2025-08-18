#!/bin/bash

run_latest_analyses() {

  GROUP=$1
  S1=$2
  S2=$3
  S3=$4
  S4=$5

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  # === Inputs ===
  CONTIG_DB=~/Stage_Copenhague/anvio_db/anvio_contigs_db/${GROUP}_contigs_copy.db

  PROFILE_DB=~/Stage_Copenhague/anvio_db/anvio_multi_profile_db/${GROUP}_merged_profile/PROFILE.db

  COLLECTION_NAME=metawrap_bins_${GROUP}_coassembly

  IN_BIN=~/Stage_Copenhague/binning/$GROUP/bin_refinement/metawrap_1_1000_bins.contigs
  
  # === Output ===

  OUT_BIN=~/Stage_Copenhague/anvio_collections/$GROUP/${GROUP}_bins.txt
  mkdir -p "$(dirname "$OUT_BIN")"
  
  BIN_INFO=~/Stage_Copenhague/anvio_collections/$GROUP/${GROUP}_bins_info.txt

  OUTPUT_TAX=~/Stage_Copenhague/anvio_collections/$GROUP/${GROUP}_scg_taxonomy.txt
  mkdir -p $(dirname "$OUTPUT_TAX")

  OUT_ANVIO_SUMMARY=~/Stage_Copenhague/anvio_summary/${GROUP}_summary

  # --- 06 - Import collection ---    
  # Replace . by _ in bin names and save as a new file
  awk -F'\t' '{gsub(/\./, "_", $2); print $1"\t"$2}' "$IN_BIN" > "$OUT_BIN"
  
  echo "[INFO] $(date) Formatted contig-to-bin file saved as $OUT_BIN"
  
  cut -f2 "$OUT_BIN" | sort -u | awk 'BEGIN{srand()}
 {
  r = int(127 + 128 * rand());
  g = int(127 + 128 * rand());
  b = int(127 + 128 * rand());
  printf "%s\tMetaWRAP\t#%02x%02x%02x\n", $1, r, g, b;
 }' > "$BIN_INFO"
  
  
  echo "[INFO] $(date) Running anvi-import-collection for the $GROUP group..."
  anvi-import-collection $OUT_BIN \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C $COLLECTION_NAME \
    --contigs-mode \
    --bins-info $BIN_INFO

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
  echo "[INFO] $(date) Beginning the anvi-summarize command for the $GROUP group..."
  anvi-summarize \
  -c $CONTIG_DB \
  -p $PROFILE_DB \
  -C $COLLECTION_NAME \
  -o $OUT_ANVIO_SUMMARY \
  --report-aa-seqs-for-gene-calls

  echo "[INFO] $(date) The anvi-summarize process is complete for the $GROUP group. You can find the results in : $OUT_ANVIO_SUMMARY"

}

# === Exporting the function ===
export -f run_latest_analyses

# === Create a folder for the logs ===
mkdir -p ~/Stage_Copenhague/logs/step_05_to_08_coassemblies

# === Run in parallel, with one log file per group ===
tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 2 --bar --colsep '\t' 'run_latest_analyses {1} {2} {3} {4} {5} &> ~/Stage_Copenhague/logs/step_05_to_08_coassemblies/{1}_latest_analyses_steps_06_to_08.log'

echo "[INFO] $(date) All the latest analyses are done for the coassembly groups."

