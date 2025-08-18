#!/bin/bash

process_mapping() {
  GROUP=$1
  S1=$2
  S2=$3
  S3=$4
  S4=$5

  echo "========================================="
  echo "          Processing group $GROUP"
  echo "========================================="

  ROOT=~/Stage_Copenhague/assembly/$GROUP
  IN_CONTIGS=$ROOT/${GROUP}_contigs_fixed.fa

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate bowtie2_env

  # Building the index for contigs
  OUT_DIR=~/Stage_Copenhague/mapping/$GROUP
  mkdir -p $OUT_DIR
  bowtie2-build $IN_CONTIGS $OUT_DIR/contigs

  # Mapping reads to contigs
  for i in $S1 $S2 $S3 $S4; do

    IN_READS=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free

    OUT_BAM_DIR=$OUT_DIR/sam_and_bam
    mkdir -p $OUT_BAM_DIR

    bowtie2 --threads 8 -x $OUT_DIR/contigs \
     -1 $IN_READS/sample_${i}_contaminant_free_read1_paired.fq.gz \
     -2 $IN_READS/sample_${i}_contaminant_free_read2_paired.fq.gz \
     -S $OUT_BAM_DIR/sample_${i}_paired.sam

    bowtie2 --threads 8 -x $OUT_DIR/contigs \
     -U $IN_READS/sample_${i}_contaminant_free_read1_unpaired.fq.gz,$IN_READS/sample_${i}_contaminant_free_read2_unpaired.fq.gz \
     -S $OUT_BAM_DIR/sample_${i}_unpaired.sam

    samtools view -F 4 -bS $OUT_BAM_DIR/sample_${i}_paired.sam > $OUT_BAM_DIR/sample_${i}_paired-RAW.bam
    rm $OUT_BAM_DIR/sample_${i}_paired.sam

    samtools view -F 4 -bS $OUT_BAM_DIR/sample_${i}_unpaired.sam > $OUT_BAM_DIR/sample_${i}_unpaired-RAW.bam
    rm $OUT_BAM_DIR/sample_${i}_unpaired.sam

    samtools merge $OUT_BAM_DIR/sample_${i}.bam $OUT_BAM_DIR/sample_${i}_paired-RAW.bam $OUT_BAM_DIR/sample_${i}_unpaired-RAW.bam


    # === Activate the conda environment ===
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate anvio8_env

    anvi-init-bam $OUT_BAM_DIR/sample_${i}.bam -o $OUT_BAM_DIR/sample_${i}.bam
    rm $OUT_BAM_DIR/sample_${i}_paired-RAW.bam $OUT_BAM_DIR/sample_${i}_unpaired-RAW.bam

    echo "mapping completed for sample $i. You can find the BAM files here : $OUT_BAM_DIR/sample_${i}.bam"
  done
}

export -f process_mapping

tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | \
parallel -j 2 --colsep '\t' process_mapping {1} {2} {3} {4} {5}

echo "Sample mapping completed."
