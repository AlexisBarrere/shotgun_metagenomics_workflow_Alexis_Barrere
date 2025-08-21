#!/bin/bash

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
CONTIG_DB_1=$ROOT/contigs_db/MAGs_contigs.db

PROFILE_DB_1=$ROOT/profile_db/MAGs_MERGED/PROFILE.db

COLLECTION_NAME_1=Archaeal_MAGs

BINS_INFO_1=$ROOT/collections/MAGs_bins_info.txt

# === Outputs ===
OUTFILE_1=$ROOT/pangenome/internal-genomes_MAGs.txt
mkdir -p $(dirname "$OUTFILE_1")

# === Write headers ===
echo -e "name\tbin_id\tcollection_id\tprofile_db_path\tcontigs_db_path" > "$OUTFILE_1"

# === Process MAGs only ===
cut -f1 "$BINS_INFO_1" | while read bin_id; do
  echo -e "${bin_id}\t${bin_id}\t${COLLECTION_NAME_1}\t${PROFILE_DB_1}\t${CONTIG_DB_1}"
done >> "$OUTFILE_1"  
  
echo "[INFO] internal-genomes_MAGs.txt generated at $OUTFILE_1"