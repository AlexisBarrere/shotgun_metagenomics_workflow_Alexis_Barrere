#!/bin/bash

# Function to count the number of reads in a gzipped FASTQ file
count_reads() {
  fq_file="$1" # Input file path

  if [[ -f "$fq_file" ]]; then
	line_count=$(zcat "$fq_file" | wc -l)
	echo $((line_count / 4))
  else
	echo 0 # Return 0 if file doesn't exist
  fi
}


count_reads_before_decontamination() {
  i=$1

  IN_DIR=~/Stage_Copenhague/trimming/clean_reads_final/sample_$i

  R1_PAIRED="$IN_DIR/sample_${i}_read1_paired_cleaned.fq.gz"
  R2_PAIRED="$IN_DIR/sample_${i}_read2_paired_cleaned.fq.gz"
  R1_UNPAIRED="$IN_DIR/sample_${i}_read1_unpaired_cleaned.fq.gz"
  R2_UNPAIRED="$IN_DIR/sample_${i}_read2_unpaired_cleaned.fq.gz"

  N1=$(count_reads "$R1_PAIRED")
  N2=$(count_reads "$R2_PAIRED")
  N3=$(count_reads "$R1_UNPAIRED")
  N4=$(count_reads "$R2_UNPAIRED")

  TOTAL=$((N1 + N2 + N3 + N4))

  echo -e "$N1\t$N2\t$N3\t$N4\t$TOTAL"
}


count_reads_no_wheat() {
  i=$1

  IN_DIR=~/Stage_Copenhague/decontamination/sample_$i/no_wheat

  R1_PAIRED="$IN_DIR/sample_${i}_no_wheat_paired.fq.1.gz"
  R2_PAIRED="$IN_DIR/sample_${i}_no_wheat_paired.fq.2.gz"
  R1_UNPAIRED="$IN_DIR/sample_${i}_no_wheat_read1_unpaired.fq.gz"
  R2_UNPAIRED="$IN_DIR/sample_${i}_no_wheat_read2_unpaired.fq.gz"

  N1=$(count_reads "$R1_PAIRED")
  N2=$(count_reads "$R2_PAIRED")
  N3=$(count_reads "$R1_UNPAIRED")
  N4=$(count_reads "$R2_UNPAIRED")

  TOTAL=$((N1 + N2 + N3 + N4))

echo -e "$N1\t$N2\t$N3\t$N4\t$TOTAL"
}


count_reads_no_human() {
  i=$1

  IN_DIR=~/Stage_Copenhague/decontamination/sample_$i/no_human

  R1_PAIRED="$IN_DIR/sample_${i}_no_wheat_no_human_paired.fq.1.gz"
  R2_PAIRED="$IN_DIR/sample_${i}_no_wheat_no_human_paired.fq.2.gz"
  R1_UNPAIRED="$IN_DIR/sample_${i}_no_wheat_no_human_read1_unpaired.fq.gz"
  R2_UNPAIRED="$IN_DIR/sample_${i}_no_wheat_no_human_read2_unpaired.fq.gz"

  N1=$(count_reads "$R1_PAIRED")
  N2=$(count_reads "$R2_PAIRED")
  N3=$(count_reads "$R1_UNPAIRED")
  N4=$(count_reads "$R2_UNPAIRED")

  TOTAL=$((N1 + N2 + N3 + N4))

echo -e "$N1\t$N2\t$N3\t$N4\t$TOTAL"
}


count_reads_no_PhiX() {
  i=$1

  IN_DIR=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free

  R1_PAIRED="$IN_DIR/sample_${i}_contaminant_free_read1_paired.fq.gz"
  R2_PAIRED="$IN_DIR/sample_${i}_contaminant_free_read2_paired.fq.gz"
  R1_UNPAIRED="$IN_DIR/sample_${i}_contaminant_free_read1_unpaired.fq.gz"
  R2_UNPAIRED="$IN_DIR/sample_${i}_contaminant_free_read2_unpaired.fq.gz"

  N1=$(count_reads "$R1_PAIRED")
  N2=$(count_reads "$R2_PAIRED")
  N3=$(count_reads "$R1_UNPAIRED")
  N4=$(count_reads "$R2_UNPAIRED")

  TOTAL=$((N1 + N2 + N3 + N4))

echo -e "$N1\t$N2\t$N3\t$N4\t$TOTAL"
}

OUTPUT_FILE=~/Stage_Copenhague/decontamination/read_counts/read_counts_decontamination.tsv
mkdir -p $(dirname "$OUTPUT_FILE")

# output file header :
echo -e "Sample\tStep\tRead1_paired\tRead2_paired\tRead1_unpaired\tRead2_unpaired\tTOTAL" > $OUTPUT_FILE

for i in $(seq -w 1 24); do
  before=$(count_reads_before_decontamination $i)
  wheat=$(count_reads_no_wheat $i)
  human=$(count_reads_no_human $i)
  phix=$(count_reads_no_PhiX $i)

  echo -e "$i\tBefore decontamination\t$before" >> $OUTPUT_FILE
  echo -e "$i\tNo wheat\t$wheat" >> $OUTPUT_FILE
  echo -e "$i\tNo human\t$human" >> $OUTPUT_FILE
  echo -e "$i\tNo PhiX (fully decontaminated)\t$phix" >> $OUTPUT_FILE
  echo "" >> $OUTPUT_FILE
  echo -e "------------------------------------------------------------------------------" >> $OUTPUT_FILE
  echo "" >> $OUTPUT_FILE
done







