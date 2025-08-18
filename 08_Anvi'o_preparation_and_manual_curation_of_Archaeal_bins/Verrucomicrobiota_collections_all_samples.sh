#!/bin/bash

create_Verrucomicrobiota_collections() {
  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio-8

  i=$1

  # === Create the main directory ===
  ROOT=~/Stage_Copenhague/visualisation_anvio/sample_${i}
  mkdir -p $ROOT

  # === Inputs ===
  INPUT_FILES=$ROOT/input_files/
  mkdir -p $INPUT_FILES

  COLLECTION_DIR=$ROOT/sample_${i}_collections/
  mkdir -p $COLLECTION_DIR

  ANVI_SUMMARIZE_DIR=$ROOT/anvi_summarize
  mkdir -p $ANVI_SUMMARIZE_DIR

  BINS_SUMMARY=$INPUT_FILES/bins_summary.txt

  INITIAL_COLLECTION=$COLLECTION_DIR/metawrap_bins_sample_${i}_single_assembly.txt
  INITIAL_INFO=$COLLECTION_DIR/metawrap_bins_sample_${i}_single_assembly-info.txt

  COLLECTION_NAME_VERRUCOMICROBIOTA=metawrap_bins_sample_${i}_single_assembly_Verrucomicrobiota

  CONTIG_DB=$INPUT_FILES/sample_${i}_contigs_copy.db

  PROFILE_DB=$INPUT_FILES/PROFILE.db

  # === Outputs ===
  VERRUCOMICROBIOTA_COLLECTION=$COLLECTION_DIR/${COLLECTION_NAME_VERRUCOMICROBIOTA}.txt
  VERRUCOMICROBIOTA_INFO=$COLLECTION_DIR/${COLLECTION_NAME_VERRUCOMICROBIOTA}-info.txt  

  SUMMARIZE_VERRUCOMICROBIOTA=$ANVI_SUMMARIZE_DIR/sample_${i}_Verrucomicrobiota_summarize

  # === Part I) create the Verrucomicrobiota collection ===

  # --- 1) Extract bin names for Verrucomicrobiota --- 
  echo "Extracting Verrucomicrobiota bin names from summary..."

  awk -F'\t' '$9 == "Verrucomicrobiota" { print $1 }' "$BINS_SUMMARY" > "$INPUT_FILES/tmp_Verrucomicrobiota_bins.txt"

  # --- 2) Filter INITIAL_COLLECTION (match on 2nd column) ---
  echo "Filtering contig-to-bin file to keep only Verrucomicrobiota bins..."
  awk 'FNR==NR { bins[$1]; next } $2 in bins' "$INPUT_FILES/tmp_Verrucomicrobiota_bins.txt" "$INITIAL_COLLECTION" > "$VERRUCOMICROBIOTA_COLLECTION"

  # --- 3) Filter INITIAL_INFO (match on 1st column) ---
  echo "Filtering bin-info file to keep only Verrucomicrobiota bins..."
  awk 'FNR==NR { bins[$1]; next } $1 in bins' "$INPUT_FILES/tmp_Verrucomicrobiota_bins.txt" "$INITIAL_INFO" > "$VERRUCOMICROBIOTA_INFO"

  # --- 4) Clean up ---
  # rm "$ROOT/tmp_Verrucomicrobiota_bins.txt"

  echo "Done. Verrucomicrobiota-specific collection and info files created for sample_$i :"
  echo "$VERRUCOMICROBIOTA_COLLECTION"
  echo "$VERRUCOMICROBIOTA_INFO"


  # === Part II) Import the collection ===
  echo "[INFO] $(date) Running anvi-import-collection for the $COLLECTION_NAME_VERRUCOMICROBIOTA collection..."

  anvi-import-collection $VERRUCOMICROBIOTA_COLLECTION \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C $COLLECTION_NAME_VERRUCOMICROBIOTA \
    --bins-info $VERRUCOMICROBIOTA_INFO

  echo "[INFO] $(date) Collection $COLLECTION_NAME_VERRUCOMICROBIOTA successfully imported into Anvi'o."

  # === Part III) Run anvi-summarize on the Verrucomicrobiota Collection ===
  echo "[INFO] $(date) Beginning the anvi-summarize command for the $COLLECTION_NAME_VERRUCOMICROBIOTA collection..."

  anvi-summarize \
    -c $CONTIG_DB \
    -p $PROFILE_DB \
    -C $COLLECTION_NAME_VERRUCOMICROBIOTA \
    -o $SUMMARIZE_VERRUCOMICROBIOTA \
  --report-aa-seqs-for-gene-calls

  echo "[INFO] $(date) The anvi-summarize process is complete for the $COLLECTION_NAME_VERRUCOMICROBIOTA collection. You can find the results in : $SUMMARIZE_VERRUCOMICROBIOTA"
}

# === Exporting the function ===
export -f create_Verrucomicrobiota_collections

# === Run the function ===
for i in $(seq -w 1 24); do
  create_Verrucomicrobiota_collections $i
done

