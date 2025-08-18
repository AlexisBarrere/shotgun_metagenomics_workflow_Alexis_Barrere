#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

ROOT=~/Stage_Copenhague/downstream_analysis/NCBI_pangenome

# === Inputs ===
FASTA_DIR=$ROOT/NCBI_genomes/NCBI-GENOMES-REFORMATTED

CONTIGS_DB_DIR=$ROOT/contigs_db
mkdir -p $CONTIGS_DB_DIR

COG_DATA=~/anvio_cogs

# === Loop through all .fa files ===
for fasta in "$FASTA_DIR"/*.fa; do
  base=$(basename "$fasta" _1.fa)
  db="$CONTIGS_DB_DIR/${base}.db"

  # Step 1 - Generate contigs DB
  anvi-gen-contigs-database -f "$fasta" \
                            -o "$db"  \
                            -n "$base"
  # Step 2 - Run HMMs to identify SCGs
  anvi-run-hmms -c "$db" -T 16

  # Step 3 - Functional annotation (COGs)
  anvi-run-ncbi-cogs -c "$db" --cog-data-dir "$COG_DATA" -T 16

  # Step 4 - Estimate taxonomy from SCGs
  anvi-run-scg-taxonomy -c "$db" -T 16

  echo "Done with $base"
done

echo "All NCBI genome contigs databases processed."
