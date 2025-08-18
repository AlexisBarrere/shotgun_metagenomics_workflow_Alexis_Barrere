#!/bin/bash

# === Activating the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

# === Output directory ===
OUT_DIR=~/Stage_Copenhague/anvio_db/anvio_contigs_db
mkdir -p $OUT_DIR

create_contigs_db() {
  i=$1
  out_dir=$2

  IN_FILE=~/Stage_Copenhague/assembly/sample_$i/sample_${i}_contigs_fixed.fa
  OUT_DB=$out_dir/sample_${i}_contigs.db

  # === Creation of the anvio database ===

  echo "Creating the anvio database for sample $i..."

  anvi-gen-contigs-database -f $IN_FILE \
                            -o $OUT_DB -n "Assembly of sample $i"

  echo "Database created for sample $i."
}

export -f create_contigs_db

seq -w 1 24 | parallel -j 4 --verbose --bar create_contigs_db {} $OUT_DIR

echo
echo "Creation of the 24 databases completed. You can find them in the following folder : $OUT_DIR"

