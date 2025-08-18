#!/bin/bash

for i in $(seq -w 1 24); do
	DIR=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free

	mv "$DIR/sample_${i}_contaminant_free_paired.fq.1.gz" "$DIR/sample_${i}_contaminant_free_read1_paired.fq.gz"
        mv "$DIR/sample_${i}_contaminant_free_paired.fq.2.gz" "$DIR/sample_${i}_contaminant_free_read2_paired.fq.gz"
done

echo "All paired files have been renamed for compatibility with MultiQC."
