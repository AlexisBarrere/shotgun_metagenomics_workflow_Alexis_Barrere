#!/bin/bash

create_files_and_collections_for_all_groups() {
  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio-8

  GROUP=$1

  # === Create the main directory ===
  ROOT=~/Stage_Copenhague/visualisation_anvio/$GROUP
  mkdir -p $ROOT

  # === copy important files ===
  INPUT_FILES=$ROOT/input_files/
  mkdir -p $INPUT_FILES

  cp -r "/mnt/c/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/Anvi_summarize/$GROUP/PROFILE.db" $INPUT_FILES

  cp -r "/mnt/c/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/Anvi_summarize/$GROUP/AUXILIARY-DATA.db" $INPUT_FILES

  cp -r "/mnt/c/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/Anvi_summarize/$GROUP/${GROUP}_contigs_copy.db" $INPUT_FILES

  cp -r "/mnt/c/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/Anvi_summarize/$GROUP/${GROUP}_summary/bins_summary.txt" $INPUT_FILES

  # --- Collections directory ---
  COLLECTION_DIR=$ROOT/${GROUP}_collections/
  mkdir -p $COLLECTION_DIR

  # === Inputs ===
  COLLECTION_NAME=metawrap_bins_${GROUP}_coassembly

  COLLECTION_NAME_ARCHAEA=metawrap_bins_${GROUP}_coassembly_Archaea

  BINS_SUMMARY=$INPUT_FILES/bins_summary.txt

  INITIAL_COLLECTION=$COLLECTION_DIR/${COLLECTION_NAME}.txt

  INITIAL_INFO=$COLLECTION_DIR/${COLLECTION_NAME}-info.txt

  ANVI_SUMMARIZE_DIR=$ROOT/anvi_summarize
  mkdir -p $ANVI_SUMMARIZE_DIR

  CONTIG_DB=$INPUT_FILES/${GROUP}_contigs_copy.db

  PROFILE_DB=$INPUT_FILES/PROFILE.db

  # === Outputs ===
  ARCHAEA_COLLECTION_V1=$COLLECTION_DIR/${COLLECTION_NAME_ARCHAEA}_V1.txt

  ARCHAEA_INFO_V1=$COLLECTION_DIR/${COLLECTION_NAME_ARCHAEA}_V1-info.txt

  SUMMARIZE_V1=$ANVI_SUMMARIZE_DIR/${GROUP}_Archaea_V1_summarize

  # === 1) Export the initial collection from the PROFILE.db ===
  anvi-export-collection -C $COLLECTION_NAME -p $INPUT_FILES/PROFILE.db -O $COLLECTION_DIR/$COLLECTION_NAME

  # === 2) Extract bin names for Archaea ===
  echo "Extracting Archaea bin names from summary..."
  awk -F'\t' '$8 == "Archaea" { print $1 }' "$BINS_SUMMARY" > "$COLLECTION_DIR/tmp_archaea_bins.txt"

  # === 3) Filter INITIAL_COLLECTION (match on 2nd column) ===
  echo "Filtering contig-to-bin file to keep only Archaea bins..."
  awk 'FNR==NR { bins[$1]; next } $2 in bins' "$COLLECTION_DIR/tmp_archaea_bins.txt" "$INITIAL_COLLECTION" > "$ARCHAEA_COLLECTION_V1"

  # === 4) Filter INITIAL_INFO (match on 1st column) ===
  echo "Filtering bin-info file to keep only Archaea bins..."
  awk 'FNR==NR { bins[$1]; next } $1 in bins' "$COLLECTION_DIR/tmp_archaea_bins.txt" "$INITIAL_INFO" > "$ARCHAEA_INFO_V1"

  # === 5) Clean up the temporary file ===
  # rm "$COLLECTION_DIR/tmp_archaea_bins.txt"

  echo "Done. Archaea-specific collection and info files created:"
  echo "$ARCHAEA_COLLECTION_V1"
  echo "$ARCHAEA_INFO_V1"

  # === 6) Import collection into PROFILE.db ===
  echo "[INFO] $(date) Running anvi-import-collection for the ${COLLECTION_NAME_ARCHAEA}_V1 collection..."

  anvi-import-collection $ARCHAEA_COLLECTION_V1 \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C ${COLLECTION_NAME_ARCHAEA}_V1 \
    --bins-info $ARCHAEA_INFO_V1

  echo "[INFO] $(date) Collection ${COLLECTION_NAME_ARCHAEA}_V1 successfully imported into Anvi'o."

  echo "[INFO] $(date) Running anvi-import-collection for the ${COLLECTION_NAME_ARCHAEA}_V2 collection..."

  anvi-import-collection $ARCHAEA_COLLECTION_V1 \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C ${COLLECTION_NAME_ARCHAEA}_V2 \
    --bins-info $ARCHAEA_INFO_V1

  echo "[INFO] $(date) Collection ${COLLECTION_NAME_ARCHAEA}_V2 successfully imported into Anvi'o."

  # === ) Summarize with Anvi'o ===
  echo "[INFO] $(date) Beginning the anvi-summarize command for the ${COLLECTION_NAME_ARCHAEA}_V1 collection..."

  anvi-summarize \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C ${COLLECTION_NAME_ARCHAEA}_V1 \
    -o $SUMMARIZE_V1 \
    --report-aa-seqs-for-gene-calls

  echo "[INFO] $(date) The anvi-summarize command worked successfully."
  echo "You can find the folder containing the summary here : $SUMMARIZE_V1"
}

# === Exporting the function ===
export -f create_files_and_collections_for_all_groups

# === Run the function ===
tail -n +2 ~/Stage_Copenhague/visualisation_anvio/coassembly_groups.tsv | \
cut -f1 | \
parallel -j 1 --bar 'create_files_and_collections_for_all_groups {}'
