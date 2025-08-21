#!/bin/bash
ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
CONTIG_DB_1=$ROOT/contigs_db/MAGs_contigs.db

PROFILE_DB_1=$ROOT/profile_db/MAGs_MERGED/PROFILE.db

COLLECTION_NAME_1=Archaeal_MAGs

COLLECTION_1=$ROOT/collections/MAGs_collection.txt

# === Outputs ===
OUT_1=$ROOT/collections/MAGs_collection.txt
mkdir -p $(dirname $OUT_1)

COLLECTION_INFO_1=$ROOT/collections/MAGs_bins_info.txt


sqlite3 $CONTIG_DB_1 'SELECT split FROM splits_basic_info;' | while read split; do
  genome=$(echo "$split" | awk -F'_[0-9]+_split_' '{print $1}')
  echo -e "$split\t$genome"
done > "$OUT_1"

echo "Genome collection written to $OUT_1"

cut -f2 $COLLECTION_1 | sort -u | awk 'BEGIN{srand()}
{
  r = int(127 + 128 * rand());
  g = int(127 + 128 * rand());
  b = int(127 + 128 * rand());
  printf "%s\tMAGs\t#%02x%02x%02x\n", $1, r, g, b;
}' > $COLLECTION_INFO_1

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate anvio8_env

echo "Importing the $COLLECTION_NAME_1 collection in Anvi'o..."

# === Import the MAGs collection ===
anvi-import-collection $OUT_1 \
                       -c $CONTIG_DB_1 \
                       -p $PROFILE_DB_1 \
                       -C $COLLECTION_NAME_1 \
                       --bins-info $COLLECTION_INFO_1 

echo "The $COLLECTION_NAME_1 collection is now imported in Anvi'o."