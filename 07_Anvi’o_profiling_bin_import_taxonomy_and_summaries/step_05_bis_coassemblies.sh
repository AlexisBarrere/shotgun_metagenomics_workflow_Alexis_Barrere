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

  # --- 05/BIS - Anvi-merge ---

  # === Inputs ===

  CONTIG_DB=~/Stage_Copenhague/anvio_db/anvio_contigs_db/${GROUP}_contigs_copy.db

  # === Outputs ===

  OUT_MERGED_PROFILE=~/Stage_Copenhague/anvio_db/anvio_multi_profile_db/${GROUP}_merged_profile

  ROOT=~/Stage_Copenhague/anvio_db/anvio_multi_profile_db

  echo "[INFO] $(date) Running the anvi-merge command on samples of the $GROUP group..."
  anvi-merge -c $CONTIG_DB \
             $ROOT/sample_${S1}/PROFILE.db \
             $ROOT/sample_${S2}/PROFILE.db \
             $ROOT/sample_${S3}/PROFILE.db \
             $ROOT/sample_${S4}/PROFILE.db \
             -o $OUT_MERGED_PROFILE \
             -S ${GROUP}_PROFILE \
             --skip-hierarchical-clustering
  echo "[INFO] $(date) The anvi-merge command is done for the $GROUP group. You can find the merged profile database in $OUT_MERGED_PROFILE."

}

# === Exporting the function ===
export -f run_latest_analyses

# === Create a folder for the logs ===
mkdir -p ~/Stage_Copenhague/logs/step_05_to_08_coassemblies

# === Run in parallel, with one log file per group ===
tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 2 --bar --colsep '\t' 'run_latest_analyses {1} {2} {3} {4} {5} &> ~/Stage_Copenhague/logs/step_05_to_08_coassemblies/{1}_latest_analyses_step_05_bis_with_HC.log'

echo "[INFO] $(date) The profiling step is done for all the coassembly groups."

