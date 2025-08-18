#!/bin/bash
# Run Centrifuge for taxonomy and import results

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
CONTIG_DB=$ROOT/contigs_db/MAGs_contigs.db

CENTRIFUGE_DB=~/Stage_Copenhague/databases/centrifuge_db/p_compressed+h+v

# === Outputs ===
OUT_DIR_CENTRIFUGE=$ROOT/taxonomy_results
mkdir -p $OUT_DIR_CENTRIFUGE

# === centrifuge ===
# Taxonomy annotations :

echo "Exporting gene calls from MAGs for Centrifuge..."
anvi-get-sequences-for-gene-calls -c $CONTIG_DB -o $OUT_DIR_CENTRIFUGE/MAGs_gene_calls.fa

conda deactivate
conda activate centrifuge_env

echo "Running Centrifuge classification (MAGs)..."
centrifuge -f \
  -x $CENTRIFUGE_DB \
  -U $OUT_DIR_CENTRIFUGE/MAGs_gene_calls.fa \
  -S $OUT_DIR_CENTRIFUGE/MAGs_centrifuge_hits.tsv \
  --report-file $OUT_DIR_CENTRIFUGE/MAGs_centrifuge_report.tsv \
  -p 4

conda deactivate
conda activate anvio8_env

echo "Importing Centrifuge results into Anvi'o (MAGs)..."
anvi-import-taxonomy-for-genes \
  -c $CONTIG_DB \
  -i $OUT_DIR_CENTRIFUGE/MAGs_centrifuge_report.tsv $OUT_DIR_CENTRIFUGE/MAGs_centrifuge_hits.tsv \
  -p centrifuge

echo "The centrifuge taxonomy is imported into Anvi'o for the 12 Archaeal MAGs."

# === anvi-run-scg-taxonomy ===
# Run SCG taxonomy annotation on the contigs database.
echo "Running anvi-run-scg-taxonomy on $CONTIG_DB (MAGs)..."
anvi-run-scg-taxonomy -c $CONTIG_DB -T 4
echo "SCG taxonomy annotation complete for MAGs."

