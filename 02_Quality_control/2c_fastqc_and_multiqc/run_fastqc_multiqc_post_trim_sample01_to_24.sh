#!/bin/bash

SECONDS=0

# === Working directories ===
CLEAN_DIR=~/Stage_Copenhague/trimming/clean_reads

FASTQC_ROOT=~/Stage_Copenhague/trimming/fastqc_post_trim
mkdir -p "$FASTQC_ROOT"

MULTIQC_OUT=~/Stage_Copenhague/trimming/MultiQC_Post_Trimming/multiqc_post_trim_final
mkdir -p "$MULTIQC_OUT"

echo "--> Running FastQC on the after_fastp files (paired + unpaired)..."

# === FastQC analysis for each sample ===
for i in $(seq -w 1 24); do
	SAMPLE_ID="sample_$i"
	SAMPLE_DIR="$CLEAN_DIR/$SAMPLE_ID/after_fastp"
	FASTQC_OUT="$FASTQC_ROOT/$SAMPLE_ID"

	mkdir -p "$FASTQC_OUT"

	# List of read types
	for READ in read1_paired_cleaned read2_paired_cleaned read1_unpaired_cleaned read2_unpaired_cleaned; do
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
echo "Running MultiQC on all FastQC results (after Trimmomatic + Fastp)..."
multiqc "$FASTQC_ROOT" -o "$MULTIQC_OUT"

# Total time
duration=$SECONDS
echo
echo "Analysis completed in $((duration / 60)) minutes and $(($duration % 60)) seconds."
