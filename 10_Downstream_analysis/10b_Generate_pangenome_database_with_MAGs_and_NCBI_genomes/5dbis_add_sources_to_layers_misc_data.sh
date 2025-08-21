#!/bin/bash

ROOT=~/Stage_Copenhague/downstream_analysis/NCBI_pangenome_2

# === Inputs ===
LAYERS_FILE=$ROOT/misc_data/layers/layers_original_file.txt

# === Outputs ===
OUT_FILE=$ROOT/misc_data/layers/layers_modified_with_sources.txt

# === Write header ===
echo -e "layers\tsource" > "$OUT_FILE"

# === Parse each genome name and assign source ===
tail -n +2 "$LAYERS_FILE" | while read -r line; do
  genome=$(echo "$line" | cut -f1)
  if [[ "$genome" == *MAG* ]]; then
    source="MAG"
  else
    source="NCBI"
  fi
  echo -e "${genome}\t${source}" >> "$OUT_FILE"
done

echo "[INFO] layers_modified_with_sources.txt created at: $OUT_FILE" 
