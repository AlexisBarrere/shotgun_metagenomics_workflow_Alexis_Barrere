#!/bin/bash

create_MAGS_collection_all_coassemblies() {

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  GROUP=$1

  # === Inputs ===
  ROOT=~/Stage_Copenhague/visualisation_anvio/$GROUP

  PROFILE_DB=$ROOT/input_files/PROFILE.db

  CONTIG_DB=$ROOT/input_files/${GROUP}_contigs_copy.db

  COLLECTION_TO_READ=metawrap_bins_${GROUP}_coassembly_Archaea_V2

  # === Outputs ===
  COLLECTION_TO_WRITE=${GROUP}_MAGs

  REPORT_FILE=$ROOT/${GROUP}_collections/rename.txt

  # === Create collection ===
  anvi-rename-bins -c $CONTIG_DB \
                 -p $PROFILE_DB \
                 --prefix $GROUP \
                 --collection-to-read $COLLECTION_TO_READ \
                 --collection-to-write $COLLECTION_TO_WRITE \
                 --report-file $REPORT_FILE \
                 --min-completion-for-MAG 50 \
                 --call-MAGs \
                 --exclude-bins

  echo "The MAG collection was created for the $GROUP group."
}

# === Exporting the function ===

export -f create_MAGS_collection_all_coassemblies

# === Run the function ===
tail -n +2 ~/Stage_Copenhague/visualisation_anvio/coassembly_groups.tsv | \
cut -f1 | \
parallel -j 2 --bar 'create_MAGS_collection_all_coassemblies {}'


