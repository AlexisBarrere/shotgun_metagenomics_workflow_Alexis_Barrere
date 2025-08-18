#!/bin/bash

run_latest_analyses() {

  GROUP=$1
  S1=$2
  S2=$3
  S3=$4
  S4=$5

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  # === Inputs ===

  CONTIG_DB=~/Stage_Copenhague/anvio_db/anvio_contigs_db/${GROUP}_contigs_copy.db

  # === Output ===

  # --- 05 - Profiling ---
  for i in $S1 $S2 $S3 $S4; do
    BAM_FILE=~/Stage_Copenhague/mapping/${GROUP}/sam_and_bam/sample_${i}.bam

    OUT_DIR=~/Stage_Copenhague/anvio_db/anvio_multi_profile_db/sample_${i}
    mkdir -p $OUT_DIR

    echo "[INFO] $(date) Running anvi-profile for sample $i of the $GROUP group..."

    anvi-profile -i $BAM_FILE \
               -c $CONTIG_DB \
               --min-contig-length 1000 \
               --sample-name sample_${i}_coassembly \
               --output-dir $OUT_DIR \
               --force-overwrite \
               -T 8

    echo "[INFO] $(date) The Anvi'o profile database for sample $i is created. You can find it in $OUT_DIR."
  done

}

# === Exporting the function ===
export -f run_latest_analyses

# === Create a folder for the logs ===
mkdir -p ~/Stage_Copenhague/logs/step_05_to_08_coassemblies

# === Run in parallel, with one log file per group ===
tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 2 --bar --colsep '\t' 'run_latest_analyses {1} {2} {3} {4} {5} &> ~/Stage_Copenhague/logs/step_05_to_08_coassemblies/{1}_latest_analyses_step_05.log'

echo "[INFO] $(date) The profiling step is done for all the coassembly groups."
