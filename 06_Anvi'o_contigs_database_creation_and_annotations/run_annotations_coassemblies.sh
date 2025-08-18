#!/bin/bash

run_annotations() {
  GROUP=$1

  cp ~/Stage_Copenhague/anvio_db/anvio_contigs_db/${GROUP}_contigs.db \
   ~/Stage_Copenhague/anvio_db/anvio_contigs_db/${GROUP}_contigs_copy.db

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  # === Inputs ===
  CONTIG_DB=~/Stage_Copenhague/anvio_db/anvio_contigs_db/${GROUP}_contigs_copy.db
  CENTRIFUGE_DB=~/Stage_Copenhague/databases/centrifuge_db/p_compressed+h+v

  # === Outputs ===
  OUT_DIR_CENTRIFUGE=~/Stage_Copenhague/centrifuge_results/${GROUP}
  mkdir -p $OUT_DIR_CENTRIFUGE

  # --- 01 - anvi-run-hmms ---
  # Annotation with HMMs (universal taxonomic and functional markers), searching for
  # single-copy genes and rRNAs.
  echo "[INFO] $(date) Running anvi-run-hmms for the $GROUP group..."
  anvi-run-hmms -c $CONTIG_DB -T 8
  echo "[INFO] $(date) The anvi-run-hmms command is finished for the $GROUP group."

  # --- 02 - anvi-run-ncbi-cogs ---
  # functional annotation with DIAMOND against NCBI's COGs
  echo "[INFO] $(date) Running anvi-run-ncbi-cogs for the $GROUP group..."
  anvi-run-ncbi-cogs -c $CONTIG_DB --cog-data-dir ~/anvio_cogs -T 4
  echo "[INFO] $(date) The anvi-run-ncbi-cogs command is finished for the $GROUP group..."

  # --- 03 - centrifuge ---
  # Taxonomy annotations
  echo "[INFO] $(date) Exporting gene calls for Centrifuge ($GROUP group)..."
  anvi-get-sequences-for-gene-calls -c $CONTIG_DB -o $OUT_DIR_CENTRIFUGE/${GROUP}_gene_calls.fa
  echo "[INFO] $(date) Gene calls are now exported for the $GROUP group."

  conda deactivate
  conda activate centrifuge_env

  echo "[INFO] $(date) Running Centrifuge classification for the $GROUP group..."
  centrifuge -f \
    -x $CENTRIFUGE_DB \
    -U $OUT_DIR_CENTRIFUGE/${GROUP}_gene_calls.fa \
    -S $OUT_DIR_CENTRIFUGE/${GROUP}_centrifuge_hits.tsv \
    --report-file $OUT_DIR_CENTRIFUGE/${GROUP}_centrifuge_report.tsv \
    -p 4
  echo "[INFO] $(date) Centrifuge classification is done for the $GROUP group."

  conda deactivate
  conda activate anvio8_env

  echo "[INFO] $(date) Importing Centrifuge results from the $GROUP group into Anvi’o..."
  anvi-import-taxonomy-for-genes \
    -c $CONTIG_DB \
    -i $OUT_DIR_CENTRIFUGE/${GROUP}_centrifuge_report.tsv $OUT_DIR_CENTRIFUGE/${GROUP}_centrifuge_hits.tsv \
    -p centrifuge
  echo "[INFO] $(date) Centrifuge results for the $GROUP groups are now imported into Anvi'o."

  # --- 04 - anvi-run-scg-taxonomy ---
  # Run SCG taxonomy annotation on the contigs database.
  echo "[INFO] $(date) Running anvi-run-scg-taxonomy on $CONTIG_DB ($GROUP group)..."
  anvi-run-scg-taxonomy -c $CONTIG_DB -T 4
  echo "[INFO] $(date) SCG taxonomy annotation complete for the $GROUP group."

}

# === Exporting the function ===
export -f run_annotations

# === Create a folder for logs ===
mkdir -p ~/Stage_Copenhague/logs

# === Run in parallel, with one log file per group ===
tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 2 --bar --colsep '\t' 'run_annotations {1} &> ~/Stage_Copenhague/logs/{1}_annotations.log'

echo "[INFO] $(date) All the contig databases annotations are done for the coassembly groups."

