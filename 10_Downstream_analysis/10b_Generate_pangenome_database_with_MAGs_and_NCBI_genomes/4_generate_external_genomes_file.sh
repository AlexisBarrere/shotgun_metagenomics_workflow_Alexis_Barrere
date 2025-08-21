#!/bin/bash

# === Paths ===
ROOT=~/Stage_Copenhague/downstream_analysis/NCBI_pangenome
FASTA_DIR=$ROOT/NCBI_genomes/NCBI-GENOMES-REFORMATTED
CONTIGS_DB_DIR=$ROOT/contigs_db
OUTPUT_FILE=$ROOT/external-genomes_NCBI.txt

# === Header ===
echo -e "name\tcontigs_db_path" > "$OUTPUT_FILE"

# === Loop through all .fa files to get genome names ===
for fasta in "$FASTA_DIR"/*.fa; do
  base=$(basename "$fasta" .fa)
  db_path="$CONTIGS_DB_DIR/${base}.db"

  # === Check if DB exists ===
  if [ -f "$db_path" ]; then
    echo -e "${base}\t${db_path}" >> "$OUTPUT_FILE"
  else
    echo "[WARNING] Contigs DB not found for: $base"
  fi
done

echo "[INFO] external-genomes file generated at: $OUTPUT_FILE"


