#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

create_profile_db() {

  i=$1

  ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

  # === Inputs ===
  IN_DIR_1=$ROOT/mapping/MAGs/sam_and_bam/MAGs_sample_${i}.bam

  CONTIG_DB_1=$ROOT/contigs_db/MAGs_contigs.db

  # === Outputs ===
  OUT_ROOT=$ROOT/profile_db

  OUT_DIR_1=$OUT_ROOT/MAGs/sample_${i}

  # === Create the anvio profile database for MAGs ===
  echo "Start of profiling the results of mapping the reads from sample $i onto the MAGs..."
  anvi-profile -c $CONTIG_DB_1 \
               -i $IN_DIR_1 \
               -M 100 \
               -T 8 \
               --sample-name sample_${i}_reads_against_MAGs \
               -o $OUT_DIR_1 \
               --force-overwrite
  echo "[INFO] $(date) The Anvi'o profile database for sample $i reads against MAGs is created. You can find it in $OUT_DIR_1."
}

export -f create_profile_db

seq -w 1 24 | parallel --jobs 4 create_profile_db {}

echo "The profiling for all BAM files is completed."