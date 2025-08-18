#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

# === Inputs ===
ROOT=~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/NCBI_genomes

INPUT=~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/NCBI_genomes/fasta_final.txt

NCBI_FASTA=$ROOT/NCBI-GENOMES

# === Outputs ===
OUT_DIR=$ROOT/NCBI-GENOMES-REFORMATTED
mkdir -p $OUT_DIR

REPORT=$ROOT/NCBI-GENOMES-REFORMATTED/report_files
mkdir $REPORT

OUTPUT=~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/NCBI_genomes/fasta_final_reformatted.txt

cd $NCBI_FASTA
for f in *.fa; do
  base=$(basename "$f" -contigs.fa)
  anvi-script-reformat-fasta "$f" \
   -o $OUT_DIR/${base}.fa \
    --simplify-names \
    --report-file "$REPORT/${base}_report.txt" \
    --prefix "NCBI_${base}"
done

# === Reformat the final fasta file ===
sed 's|/NCBI-GENOMES/|/NCBI-GENOMES-REFORMATTED/|' "$INPUT" | sed 's/-contigs.fa$/.fa/' > "$OUTPUT"

echo "fasta files and final_fasta.txt files are now refformatted."
