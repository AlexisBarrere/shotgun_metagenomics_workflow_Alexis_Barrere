#!/bin/bash

SECONDS=0

# === Working directories ===
CLEAN_DIR=~/Stage_Copenhague/trimming/clean_reads_final

FASTQC_ROOT=~/Stage_Copenhague/trimming/fastqc_post_trim_final
mkdir -p "$FASTQC_ROOT"

MULTIQC_OUT=~/Stage_Copenhague/trimming/MultiQC_Post_Trimming/multiqc_post_trim_final
mkdir -p "$MULTIQC_OUT"

echo "--> Running FastQC only on re-trimmed unpaired files..."

# === FastQC analysis for each sample ===
for i in $(seq -w 1 24); do
        SAMPLE_ID="sample_$i"
        SAMPLE_DIR="$CLEAN_DIR/$SAMPLE_ID"
        FASTQC_OUT="$FASTQC_ROOT/$SAMPLE_ID"

        mkdir -p "$FASTQC_OUT"

        # Only analyze unpaired reads
        for READ in read1_unpaired_cleaned read2_unpaired_cleaned; do
                FILE="$SAMPLE_DIR/${SAMPLE_ID}_${READ}.fq.gz"

                if [[ -f "$FILE" ]]; then
                        echo "FastQC on $SAMPLE_ID - $READ"
                        fastqc "$FILE" -o "$FASTQC_OUT"
                else
                        echo "File not found: $FILE"
                fi
        done
done

# === Run MultiQC ===
echo "Running MultiQC on all FastQC results..."
multiqc "$FASTQC_ROOT" -o "$MULTIQC_OUT"

# Total time
duration=$SECONDS
echo
echo "Analysis completed in $((duration / 60)) minutes and $(($duration % 60)) seconds."
