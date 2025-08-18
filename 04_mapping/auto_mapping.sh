#!/bin/bash

process_mapping() {
  i=$1

  echo "========================================="
  echo "          Processing sample_$i"
  echo "========================================="

  ROOT=~/Stage_Copenhague/assembly/sample_$i
  IN_DIR="$ROOT/sample_${i}_contigs_fixed.fa"

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate bowtie2_env

  # Building the index for contigs
  OUT_DIR=~/Stage_Copenhague/mapping/sample_$i
  mkdir -p $OUT_DIR
  bowtie2-build $IN_DIR $OUT_DIR/contigs

  # Mapping reads to contigs
  IN_DIR2=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free

  OUT_DIR2=$OUT_DIR/sam_and_bam
  mkdir -p $OUT_DIR2

  echo "Starting mapping reads from sample $i onto contigs."

  bowtie2 --threads 8 -x $OUT_DIR/contigs \
   -1 $IN_DIR2/sample_${i}_contaminant_free_read1_paired.fq.gz \
   -2 $IN_DIR2/sample_${i}_contaminant_free_read2_paired.fq.gz \
   -S $OUT_DIR2/sample_${i}_paired.sam

  bowtie2 --threads 8 -x $OUT_DIR/contigs \
   -U $IN_DIR2/sample_${i}_contaminant_free_read1_unpaired.fq.gz,$IN_DIR2/sample_${i}_contaminant_free_read2_unpaired.fq.gz \
   -S $OUT_DIR2/sample_${i}_unpaired.sam

  samtools view -F 4 -bS $OUT_DIR2/sample_${i}_paired.sam > $OUT_DIR2/sample_${i}_paired-RAW.bam
  rm $OUT_DIR2/sample_${i}_paired.sam

  samtools view -F 4 -bS $OUT_DIR2/sample_${i}_unpaired.sam > $OUT_DIR2/sample_${i}_unpaired-RAW.bam
  rm $OUT_DIR2/sample_${i}_unpaired.sam

  samtools merge $OUT_DIR2/sample_${i}.bam $OUT_DIR2/sample_${i}_paired-RAW.bam $OUT_DIR2/sample_${i}_unpaired-RAW.bam


  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  anvi-init-bam $OUT_DIR2/sample_${i}.bam -o $OUT_DIR2/sample_${i}.bam
  rm $OUT_DIR2/sample_${i}_paired-RAW.bam $OUT_DIR2/sample_${i}_unpaired-RAW.bam

  echo "mapping completed for sample $i. You can find the BAM files here : $OUT_DIR2/sample_${i}.bam"
}

export -f process_mapping

seq -w 1 24 | parallel --jobs 4 process_mapping {}

echo "Sample mapping completed."
