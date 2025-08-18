#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate trim_env

ADAPTERS=~/Stage_Copenhague/trimming/adapters/NexteraPE.fa

JOBS=0
MAX_JOBS=4 # to run 4 samples at a time (so : 4*4 = 16 threads)

for i in $(seq -w 2 24); do
	IN_DIR=~/Stage_Copenhague/raw_data_full/sample_"$i"

	NUM=$(echo $i | sed 's/^0*//')
	SAMPLE_ID="zr11927_${NUM}"

	TRIM_OUT=~/Stage_Copenhague/trimming/clean_reads/sample_"$i"/after_trimmomatic
	FASTP_OUT=~/Stage_Copenhague/trimming/clean_reads/sample_"$i"/after_fastp
	FASTP_REPORT=~/Stage_Copenhague/trimming/fastp_reports/sample_"$i"

	mkdir -p "$TRIM_OUT" "$FASTP_OUT" "$FASTP_REPORT"

	(
	echo "=========================="
	echo ">> Processing sample_$i..."
	echo "=========================="

	# === Step 1 - Trimmomatic ===

	trimmomatic PE $IN_DIR/${SAMPLE_ID}_read1.fastq $IN_DIR/${SAMPLE_ID}_read2.fastq \
	-threads 4 -phred33 \
	$TRIM_OUT/read1_paired.fq.gz $TRIM_OUT/read1_unpaired.fq.gz \
	$TRIM_OUT/read2_paired.fq.gz $TRIM_OUT/read2_unpaired.fq.gz \
	ILLUMINACLIP:$ADAPTERS:3:15:5:1:true \
	LEADING:20 \
	TRAILING:20 \
	SLIDINGWINDOW:4:25 \
	MINLEN:80

	# === Step 2a - fastp on paired ===
	fastp \
		--in1 "$TRIM_OUT"/read1_paired.fq.gz \
		--in2 "$TRIM_OUT"/read2_paired.fq.gz \
		--out1 "$FASTP_OUT"/read1_paired_cleaned.fq.gz \
		--out2 "$FASTP_OUT"/read2_paired_cleaned.fq.gz \
		--trim_poly_g \
		--length_required 80 \
		--thread 4 \
		--html "$FASTP_REPORT"/fastp_paired.html \
		--json "$FASTP_REPORT"/fastp_paired.json

	# === Step 2b - fastp on unpaired read1 ===
	fastp \
		--in1 "$TRIM_OUT"/read1_unpaired.fq.gz \
		--out1 "$FASTP_OUT"/read1_unpaired_cleaned.fq.gz \
		--trim_poly_g \
		--length_required 80 \
		--thread 2 \
		--html "$FASTP_REPORT"/fastp_unpaired_read1.html \
		--json "$FASTP_REPORT"/fastp_unpaired_read1.json

	# === Step 2c - fastp on unpaired read2 ===
	fastp \
		--in1 "$TRIM_OUT"/read2_unpaired.fq.gz \
		--out1 "$FASTP_OUT"/read2_unpaired_cleaned.fq.gz \
		--trim_poly_g \
		--length_required 80 \
		--thread 2 \
		--html "$FASTP_REPORT"/fastp_unpaired_read2.html \
		--json "$FASTP_REPORT"/fastp_unpaired_read2.json
	echo "----------------------------------"
	echo "Cleaning of sample_$i is finished."
	echo "----------------------------------"
	) &

	((JOBS++))

	if (( JOBS >= MAX_JOBS )); then
		wait # wait for the 4 samples to be processed
		JOBS=0 # Then reset the counter
	fi
done

wait # wait for the last if < 4 in the last series





