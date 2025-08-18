#!/bin/bash

# === Config ===
ROOT_DIR=~/Stage_Copenhague/visualisation_anvio
OUTPUT_DIR=~/Stage_Copenhague/drep_analysis/genomes_symlinks_without_reference

# === Create output directory ===
mkdir -p "$OUTPUT_DIR"

# === Loop over all summarize folders ===
echo "[INFO] Searching for MAG fasta files to symlink..."

find "$ROOT_DIR" -type f -path "*/anvi_summarize/*_MAGs_summarize/bin_by_bin/*/*-contigs.fa" | while read fa_file; do
    # Get the MAG ID (e.g., sample_01_MAG_00001)
    file_name=$(basename "$fa_file")

    # Create symbolic link in the output directory
    ln -s "$fa_file" "$OUTPUT_DIR/$file_name"
done

echo "[INFO] Total symlinks created: $(ls -1 "$OUTPUT_DIR" | wc -l)"

