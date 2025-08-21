#!/bin/bash

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
MAGS=$ROOT/reformatted_MAGs_genomes

# === Outputs ===
COMBINED_GENOMES=$ROOT/combined_genomes
mkdir -p "$COMBINED_GENOMES"


ALL_MAGS=$ROOT/combined_genomes/all_MAGs.fa

# === Combine all MAGs genomes ===
cat "$MAGS"/*.fa > "$ALL_MAGS"

echo "The fasta file containing the genomes of the 12 identified MAGs was created here : $ALL_MAGS"