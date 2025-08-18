#!/bin/bash

# === Time the script ===
SECONDS=0

# === Activating the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate megahit_env

# === Parallel function

run_megahit() {
   i=$1
   SAMPLE_ID="sample_$i"

   # === Directories ===
   IN_DIR=~/Stage_Copenhague/decontamination/$SAMPLE_ID/contaminant_free
   OUT_DIR=~/Stage_Copenhague/assembly/$SAMPLE_ID

   # === Launch MEGAHIT ===
   echo "Launching MEGAHIT for $SAMPLE_ID..."

   megahit \
      -1 "$IN_DIR/${SAMPLE_ID}_contaminant_free_read1_paired.fq.gz" \
      -2 "$IN_DIR/${SAMPLE_ID}_contaminant_free_read2_paired.fq.gz" \
      -r "$IN_DIR/${SAMPLE_ID}_contaminant_free_read1_unpaired.fq.gz","$IN_DIR/${SAMPLE_ID}_contaminant_free_read2_unpaired.fq.gz" \
      -o "$OUT_DIR" \
      --min-contig-len 1000 \
      --presets meta-large \
      -t 8

   echo "Assembly complete for $SAMPLE_ID."
}

# === Export the function so it's available to subshells ===
export -f run_megahit

# === Parallel execution of MEGAHIT ===
seq -w 1 24 | parallel -j 3 run_megahit

echo
echo "Assembly complete for all samples."

# Total time
duration=$SECONDS
echo
echo "Analysis completed in $((duration / 60)) minutes and $(($duration % 60)) seconds."

