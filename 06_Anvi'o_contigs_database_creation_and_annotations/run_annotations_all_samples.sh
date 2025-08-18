#!/bin/bash

run_annotations() {

  i=$1

  cp ~/Stage_Copenhague/anvio_db/anvio_contigs_db/sample_${i}_contigs.db \
   ~/Stage_Copenhague/anvio_db/anvio_contigs_db/sample_${i}_contigs_copy.db

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  # === Inputs ===
  CONTIG_DB=~/Stage_Copenhague/anvio_db/anvio_contigs_db/sample_${i}_contigs_copy.db
  CENTRIFUGE_DB=~/Stage_Copenhague/databases/centrifuge_db/p_compressed+h+v

  # === Outputs ===
  OUT_DIR_CENTRIFUGE=~/Stage_Copenhague/centrifuge_results/sample_${i}
  mkdir -p $OUT_DIR_CENTRIFUGE

  # --- 01 - anvi-run-hmms ---
  # Annotation with HMMs (universal taxonomic and functional markers), searching for
  # single-copy genes and rRNAs.
  echo "[INFO] $(date) Running anvi-run-hmms for sample $i..."
  anvi-run-hmms -c $CONTIG_DB -T 8
  echo "[INFO] $(date) The anvi-run-hmms command is finished for sample $i."

  # --- 02 - anvi-run-ncbi-cogs ---
  # functional annotation with DIAMOND against NCBI's COGs
  echo "[INFO] $(date) Running anvi-run-ncbi-cogs for sample $i..."
  anvi-run-ncbi-cogs -c $CONTIG_DB --cog-data-dir ~/anvio_cogs -T 4
  echo "[INFO] $(date) The anvi-run-ncbi-cogs command is finished for sample $i."

  # --- 03 - centrifuge ---
  # Taxonomy annotations
  echo "[INFO] $(date) Exporting gene calls for Centrifuge (sample $i)..."
  anvi-get-sequences-for-gene-calls -c $CONTIG_DB -o $OUT_DIR_CENTRIFUGE/sample_${i}_gene_calls.fa
  echo "[INFO] $(date) Gene calls are now exported for sample $i."

  conda deactivate
  conda activate centrifuge_env

  echo "[INFO] $(date) Running Centrifuge classification for sample $i..."
  centrifuge -f \
    -x $CENTRIFUGE_DB \
    -U $OUT_DIR_CENTRIFUGE/sample_${i}_gene_calls.fa \
    -S $OUT_DIR_CENTRIFUGE/sample_${i}_centrifuge_hits.tsv \
    --report-file $OUT_DIR_CENTRIFUGE/sample_${i}_centrifuge_report.tsv \
    -p 4
  echo "[INFO] $(date) Centrifuge classification is done for sample $i."

  conda deactivate
  conda activate anvio8_env

  echo "[INFO] $(date) Importing Centrifuge results from sample $i into Anvi’o..."
  anvi-import-taxonomy-for-genes \
    -c $CONTIG_DB \
    -i $OUT_DIR_CENTRIFUGE/sample_${i}_centrifuge_report.tsv $OUT_DIR_CENTRIFUGE/sample_${i}_centrifuge_hits.tsv \
    -p centrifuge
  echo "[INFO] $(date) Centrifuge results for sample $i are now imported into Anvi'o."

  # --- 04 - anvi-run-scg-taxonomy ---
  # Run SCG taxonomy annotation on the contigs database.
  echo "[INFO] $(date) Running anvi-run-scg-taxonomy on $CONTIG_DB (sample $i)..."
  anvi-run-scg-taxonomy -c $CONTIG_DB -T 4
  echo "[INFO] $(date) SCG taxonomy annotation complete for sample $i."

}

# === Exporting the function ===
export -f run_annotations

# === Create a folder for logs ===
mkdir -p ~/Stage_Copenhague/logs

# === Run in parallel, with one log file per sample ===
seq -w 1 24 | parallel -j 4 --bar 'run_annotations {} &> ~/Stage_Copenhague/logs/sample_{}_annotations.log'

echo "[INFO] $(date) All the contig databases annotations are done for sample 02 to 24."
