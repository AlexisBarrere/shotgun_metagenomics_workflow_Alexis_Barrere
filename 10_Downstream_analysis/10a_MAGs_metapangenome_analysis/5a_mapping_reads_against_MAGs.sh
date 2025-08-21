#!/bin/bash

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate bowtie2_env

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
MAGS_FASTA_FILE=$ROOT/combined_genomes/all_MAGs.fa

# === Outputs ===
OUT_DIR_MAGS=$ROOT/mapping/MAGs
mkdir -p $OUT_DIR_MAGS

# === building the indexes for contigs ===
bowtie2-build $MAGS_FASTA_FILE $OUT_DIR_MAGS/MAGs_contigs

# === mapping reads to contigs ===
process_mapping() {

  i=$1
  
  ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

  OUT_DIR_MAGS=$ROOT/mapping/MAGs

  READS=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free

  # === Mapping of MAGs contigs === -----------------------------------------------------------------------------------

  OUT_DIR_1=$OUT_DIR_MAGS/sam_and_bam/
  mkdir -p $OUT_DIR_1

  echo "Starting mapping reads from sample $i onto MAGs contigs."

  bowtie2 --threads 8 -x $OUT_DIR_MAGS/MAGs_contigs \
   -1 $READS/sample_${i}_contaminant_free_read1_paired.fq.gz \
   -2 $READS/sample_${i}_contaminant_free_read2_paired.fq.gz \
   -S $OUT_DIR_1/sample_${i}_paired.sam

  bowtie2 --threads 8 -x $OUT_DIR_MAGS/MAGs_contigs \
   -U $READS/sample_${i}_contaminant_free_read1_unpaired.fq.gz,$READS/sample_${i}_contaminant_free_read2_unpaired.fq.gz \
   -S $OUT_DIR_1/sample_${i}_unpaired.sam

  samtools view -F 4 -bS $OUT_DIR_1/sample_${i}_paired.sam > $OUT_DIR_1/sample_${i}_paired-RAW.bam
  rm $OUT_DIR_1/sample_${i}_paired.sam

  samtools view -F 4 -bS $OUT_DIR_1/sample_${i}_unpaired.sam > $OUT_DIR_1/sample_${i}_unpaired-RAW.bam
  rm $OUT_DIR_1/sample_${i}_unpaired.sam

  samtools merge $OUT_DIR_1/MAGs_sample_${i}.bam $OUT_DIR_1/sample_${i}_paired-RAW.bam $OUT_DIR_1/sample_${i}_unpaired-RAW.bam

  # === Activate the conda environment ===
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate anvio8_env

  anvi-init-bam $OUT_DIR_1/MAGs_sample_${i}.bam -o $OUT_DIR_1/MAGs_sample_${i}.bam
  rm $OUT_DIR_1/sample_${i}_paired-RAW.bam $OUT_DIR_1/sample_${i}_unpaired-RAW.bam

  echo "mapping of reads onto MAGs is completed for sample $i. You can find the BAM files here : $OUT_DIR_1/MAGs_sample_${i}.bam"

}

export -f process_mapping

seq -w 1 24 | parallel --jobs 4 process_mapping {}

echo "Sample mapping completed."
