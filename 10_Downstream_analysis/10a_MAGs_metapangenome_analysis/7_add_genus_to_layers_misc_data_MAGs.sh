#!/bin/bash

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
INPUT_FILE=$ROOT/anvio_summary/MAGs_summary/bins_summary.txt

# === Outputs ===
OUTPUT_FILE=$ROOT/misc_data/layers/layers_modified_with_genus.txt

# === Write header ===
echo -e "layers\tgenus" > "$OUTPUT_FILE"

# === Extract 'layer' and 'genus', replace empty genus by 'None' ===
awk -F'\t' 'NR>1 {
    layer=$1;
    genus=$13;
    if (genus == "") genus="None";
    print layer "\t" genus
}' "$INPUT_FILE" >> "$OUTPUT_FILE"

echo "[INFO] File created at: $OUTPUT_FILE"
