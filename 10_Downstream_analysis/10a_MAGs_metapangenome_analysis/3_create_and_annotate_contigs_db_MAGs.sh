#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
MAGS_FASTA="$ROOT/combined_genomes/all_MAGs.fa"

# === Outputs ===
CONTIG_DB=$ROOT/contigs_db
mkdir -p $CONTIG_DB

# === Create a contigs database for the 12 MAGs ===
anvi-gen-contigs-database -f $MAGS_FASTA \
                          -o $CONTIG_DB/MAGs_contigs.db \
                          -n "The 12 isolated archaeal genomes"

# === anvi-run-hmms to identify archaeal single core genes (SCGs) in the 12 MAGs genomes ===
anvi-run-hmms -c $CONTIG_DB/MAGs_contigs.db \
              -T 16

# === functional annotation with DIAMOND against NCBI's COGs for 12 MAGs ===
anvi-run-ncbi-cogs -c $CONTIG_DB/MAGs_contigs.db  --cog-data-dir ~/anvio_cogs -T 16

