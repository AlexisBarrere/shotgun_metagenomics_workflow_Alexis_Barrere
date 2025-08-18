#!/bin/bash

# === Activate the conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate bowtie2_env

decontaminate_unpaired_reads() {
        i=$1
        echo "----> Starting unpaired reads decontamination for sample $i..."

	IN_DIR=~/Stage_Copenhague/trimming/clean_reads_final/sample_$i

        OUT_DIR=~/Stage_Copenhague/decontamination/sample_$i
        mkdir -p "$OUT_DIR"

        mkdir -p "$OUT_DIR/no_wheat"
        mkdir -p "$OUT_DIR/no_human"
        mkdir -p "$OUT_DIR/contaminant_free"

	# Unpaired read files to be decontaminated (new)
        R1_UNPAIRED="$IN_DIR/sample_${i}_read1_unpaired_cleaned.fq.gz"

        R2_UNPAIRED="$IN_DIR/sample_${i}_read2_unpaired_cleaned.fq.gz"

        # === paths to indexes ===
        WHEAT_INDEX=~/Stage_Copenhague/contaminants/wheat/wheat_index
        HUMAN_INDEX=~/Stage_Copenhague/contaminants/human/human_index
        PHIX_INDEX=~/Stage_Copenhague/contaminants/PhiX/phix_index


        # === Wheat decontamination ===

        # For UNPAIRED reads1 :
        bowtie2 -x $WHEAT_INDEX \
         -U $R1_UNPAIRED \
         --very-sensitive -p 4 \
         --un-gz "$OUT_DIR/no_wheat/sample_${i}_no_wheat_read1_unpaired.fq.gz" \
         -S /dev/null

        # For UNPAIRED reads 2 :
        bowtie2 -x $WHEAT_INDEX \
         -U $R2_UNPAIRED \
         --very-sensitive -p 4 \
         --un-gz "$OUT_DIR/no_wheat/sample_${i}_no_wheat_read2_unpaired.fq.gz" \
         -S /dev/null


        # === Human decontamination ===

        # for UNPAIRED reads 1 :
        bowtie2 -x $HUMAN_INDEX \
         -U "$OUT_DIR/no_wheat/sample_${i}_no_wheat_read1_unpaired.fq.gz" \
         --very-sensitive -p 4 \
         --un-gz "$OUT_DIR/no_human/sample_${i}_no_wheat_no_human_read1_unpaired.fq.gz" \
         -S /dev/null

        # for UNPAIRED reads 2 :
        bowtie2 -x $HUMAN_INDEX \
         -U "$OUT_DIR/no_wheat/sample_${i}_no_wheat_read2_unpaired.fq.gz" \
         --very-sensitive -p 4 \
         --un-gz "$OUT_DIR/no_human/sample_${i}_no_wheat_no_human_read2_unpaired.fq.gz" \
         -S /dev/null


        # === PhiX decontamination ===

        # for UNPAIRED reads 1 :
        bowtie2 -x $PHIX_INDEX \
         -U "$OUT_DIR/no_human/sample_${i}_no_wheat_no_human_read1_unpaired.fq.gz" \
         --very-sensitive -p 4 \
         --un-gz "$OUT_DIR/contaminant_free/sample_${i}_contaminant_free_read1_unpaired.fq.gz" \
         -S /dev/null

        # for UNPAIRED reads 2 :
        bowtie2 -x $PHIX_INDEX \
         -U "$OUT_DIR/no_human/sample_${i}_no_wheat_no_human_read2_unpaired.fq.gz" \
         --very-sensitive -p 4 \
         --un-gz "$OUT_DIR/contaminant_free/sample_${i}_contaminant_free_read2_unpaired.fq.gz" \
         -S /dev/null

        echo "-----> Sample $i decontamination complete. Clean files are in: $OUT_DIR/contaminant_free"
}


# === Parallel call ===
export -f decontaminate_unpaired_reads

seq -w 1 24 | parallel -j 4 decontaminate_unpaired_reads

echo "All unpaired reads have been decontaminated and overwrite the old ones in ~/Stage_Copenhague/decontamination"
