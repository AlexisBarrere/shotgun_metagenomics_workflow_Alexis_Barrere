#!/bin/bash

create_MAGS_collection_all_samples() {

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  i=$1

  # === Inputs ===
  ROOT=~/Stage_Copenhague/visualisation_anvio/sample_${i}

  PROFILE_DB=$ROOT/input_files/PROFILE.db

  CONTIG_DB=$ROOT/input_files/sample_${i}_contigs_copy.db

  COLLECTION_TO_READ=metawrap_bins_sample_${i}_single_assembly_Archaea_V2

  # === Outputs ===
  COLLECTION_TO_WRITE=sample_${i}_MAGs

  REPORT_FILE=$ROOT/sample_${i}_collections/rename.txt

  # === Create collection ===
  anvi-rename-bins -c $CONTIG_DB \
                 -p $PROFILE_DB \
                 --prefix sample_${i} \
                 --collection-to-read $COLLECTION_TO_READ \
                 --collection-to-write $COLLECTION_TO_WRITE \
                 --report-file $REPORT_FILE \
                 --min-completion-for-MAG 50 \
                 --call-MAGs \
                 --exclude-bins

  echo "The MAG collection was created for sample $i."
}

# === Exporting the function ===

export -f create_MAGS_collection_all_samples

# === Run the function ===
for i in $(seq -w 1 24); do
  create_MAGS_collection_all_samples $i
done

