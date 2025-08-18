#!/bin/bash
OUT_DIR=~/Stage_Copenhague/mapping/sample_01/sam_and_bam
mkdir -p $OUT_DIR

echo "Starting mapping reads from sample 1 onto contigs."

bowtie2 --threads 8 -x ~/Stage_Copenhague/mapping/sample_01/contigs \
 -1 ~/Stage_Copenhague/decontamination/sample_01/contaminant_free/sample_01_contaminant_free_read1_paired.fq.gz \
 -2 ~/Stage_Copenhague/decontamination/sample_01/contaminant_free/sample_01_contaminant_free_read2_paired.fq.gz \
 -S $OUT_DIR/sample_01_paired.sam

bowtie2 --threads 8 -x ~/Stage_Copenhague/mapping/sample_01/contigs \
 -U ~/Stage_Copenhague/decontamination/sample_01/contaminant_free/sample_01_contaminant_free_read1_unpaired.fq.gz, \
 ~/Stage_Copenhague/decontamination/sample_01/contaminant_free/sample_01_contaminant_free_read2_unpaired.fq.gz \
 -S $OUT_DIR/sample_01_unpaired.sam

samtools view -F 4 -bS $OUT_DIR/sample_01_paired.sam > $OUT_DIR/sample_01_paired-RAW.bam
anvi-init-bam $OUT_DIR/sample_01_paired-RAW.bam -o $OUT_DIR/sample_01_paired.bam
rm $OUT_DIR/sample_01_paired.sam  $OUT_DIR/sample_01_paired-RAW.bam

samtools view -F 4 -bS $OUT_DIR/sample_01_unpaired.sam > $OUT_DIR/sample_01_unpaired-RAW.bam
anvi-init-bam $OUT_DIR/sample_01_unpaired-RAW.bam -o $OUT_DIR/sample_01_unpaired.bam
rm $OUT_DIR/sample_01_unpaired.sam  $OUT_DIR/sample_01_unpaired-RAW.bam

echo "mapping completed. You can find the BAM files here :"
echo "$OUT_DIR/sample_01_paired.bam"
echo "$OUT_DIR/sample_01_unpaired.bam"




