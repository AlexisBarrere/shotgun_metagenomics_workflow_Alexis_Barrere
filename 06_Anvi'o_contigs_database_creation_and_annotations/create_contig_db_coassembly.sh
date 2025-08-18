#!/bin/bash

# === Activating the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

# === Output directory ===
OUT_DIR=~/Stage_Copenhague/anvio_db/anvio_contigs_db
mkdir -p $OUT_DIR

create_contigs_db() {
  GROUP=$1

  OUT_DIR=$2

  IN_FILE=~/Stage_Copenhague/assembly/$GROUP/${GROUP}_contigs_fixed.fa
  OUT_DB=$OUT_DIR/${GROUP}_contigs.db

  # === Creation of the anvio database ===

  echo "Creating the anvio database for $GROUP group..."

  anvi-gen-contigs-database -f $IN_FILE \
                            -o $OUT_DB -n "Assembly of $GROUP group."

  echo "Database created for $GROUP group."
}

export -f create_contigs_db

tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 4 --bar  --colsep '\t' create_contigs_db {1} "$OUT_DIR"

echo
echo "Creation of the databases completed. You can find them in the following folder : $OUT_DIR"

