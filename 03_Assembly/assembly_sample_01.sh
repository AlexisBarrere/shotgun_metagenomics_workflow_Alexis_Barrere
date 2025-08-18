#!/bin/bash

# === Time the script ===
SECONDS=0

# === Activating the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate megahit_env

# === Directories ===
IN_DIR=~/Stage_Copenhague/decontamination/sample_01/contaminant_free
OUT_DIR=~/Stage_Copenhague/assembly/sample_01


# === Launch of assembly with MEGAHIT ===
megahit \
   -1 "$IN_DIR/sample_01_contaminant_free_read1_paired.fq.gz" \
   -2 "$IN_DIR/sample_01_contaminant_free_read2_paired.fq.gz" \
   -r "$IN_DIR/sample_01_contaminant_free_read1_unpaired.fq.gz","$IN_DIR/sample_01_contaminant_free_read2_unpaired.fq.gz" \
   -o "$OUT_DIR" \
   --min-contig-len 1000 \
   --presets meta-sensitive \
   -t 8

# === End ===
echo
echo "Assembly complete for sample_01."

# Total time
duration=$SECONDS
echo
echo "Analysis completed in $((duration / 60)) minutes and $(($duration % 60)) seconds."
