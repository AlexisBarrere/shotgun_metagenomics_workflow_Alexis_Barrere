#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate trim_env

ADAPTERS=~/Stage_Copenhague/trimming/adapters/NexteraPE.fa

OUTPUT_READS=~/Stage_Copenhague/trimming/clean_reads_final
mkdir -p $OUTPUT_READS

for i in $(seq -w 1 24); do

        SAMPLE_ID="sample_$i"

        IN_DIR=~/Stage_Copenhague/trimming/clean_reads/$SAMPLE_ID/after_fastp
        OUT_DIR=$OUTPUT_READS/$SAMPLE_ID
        mkdir -p "$OUT_DIR"

        echo "Processing unpaired reads from $SAMPLE_ID..."

        # === read1 unpaired ===
        trimmomatic SE -threads 4 -phred33 \
        "$IN_DIR/${SAMPLE_ID}_read1_unpaired_cleaned.fq.gz" \
        "$OUT_DIR/${SAMPLE_ID}_read1_unpaired_cleaned.fq.gz" \
        ILLUMINACLIP:$ADAPTERS:5:30:2 \
	MINLEN:80

        # === read2 unpaired ===
        trimmomatic SE -threads 4 -phred33 \
        "$IN_DIR/${SAMPLE_ID}_read2_unpaired_cleaned.fq.gz" \
        "$OUT_DIR/${SAMPLE_ID}_read2_unpaired_cleaned.fq.gz" \
        ILLUMINACLIP:$ADAPTERS:5:30:2 \
	MINLEN:80

        # === copy paired reads without reprocessing them ===
        cp "$IN_DIR/${SAMPLE_ID}_read1_paired_cleaned.fq.gz" "$OUT_DIR/"
        cp "$IN_DIR/${SAMPLE_ID}_read2_paired_cleaned.fq.gz" "$OUT_DIR/"

        echo "$SAMPLE_ID done."
done

echo "All unpaired reads were reprocessed with Trimmomatic and the paired reads were copied."
