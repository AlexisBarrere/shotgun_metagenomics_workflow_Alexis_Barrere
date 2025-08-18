#!/bin/bash

SECONDS=0

# === Working directories ===
CLEAN_DIR=~/Stage_Copenhague/decontamination

FASTQC_ROOT=~/Stage_Copenhague/decontamination/fastqc_post_decontamination
mkdir -p "$FASTQC_ROOT"

MULTIQC_OUT=~/Stage_Copenhague/decontamination/multiQC_post_decontamination
mkdir -p "$MULTIQC_OUT"

echo "--> Running FastQC on the decontaminated reads (paired + unpaired)..."

# === FastQC analysis for each sample ===
for i in $(seq -w 1 24); do
        SAMPLE_ID="sample_$i"
        SAMPLE_DIR="$CLEAN_DIR/$SAMPLE_ID/contaminant_free"
        FASTQC_OUT="$FASTQC_ROOT/$SAMPLE_ID"
        mkdir -p "$FASTQC_OUT"

        # List of read types
        for READ in contaminant_free_read1_paired.fq.gz contaminant_free_read2_paired.fq.gz \
	contaminant_free_read1_unpaired.fq.gz contaminant_free_read2_unpaired.fq.gz; do
                FILE="$SAMPLE_DIR/${SAMPLE_ID}_${READ}"

                echo "FastQC on $SAMPLE_ID - $READ"
                fastqc -t 16 "$FILE" -o "$FASTQC_OUT"
        done
done

# === Run MultiQC ===
echo "Running MultiQC on all FastQC results (from decontaminated reads)..."
multiqc "$FASTQC_ROOT" -o "$MULTIQC_OUT"

# Total time
duration=$SECONDS
echo
echo "Analysis completed in $((duration / 60)) minutes and $(($duration % 60)) seconds."
