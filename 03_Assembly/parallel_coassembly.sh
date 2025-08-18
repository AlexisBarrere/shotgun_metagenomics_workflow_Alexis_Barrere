#!/bin/bash

# === Time the script ===
SECONDS=0

# === Activate conda environment ===
source ~/miniconda3/etc/profile.d/conda.sh
conda activate megahit_env

# === Define TSV content (groups + samples) ===
{
echo -e "GROUP\tS1\tS2\tS3\tS4"
echo -e "T3_N1K1\t17\t19\t21\t23"
echo -e "T3_N1P2K2\t18\t20\t22\t24"
echo -e "T6_N1K1\t01\t03\t05\t07"
echo -e "T6_N1P2K2\t02\t04\t06\t08"
echo -e "T7_N1K1\t09\t11\t13\t15"
echo -e "T7_N1P2K2\t10\t12\t14\t16"
} > ~/Stage_Copenhague/assembly/coassembly_groups.tsv

# === Define the co-assembly function ===
run_coassembly() {
   GROUP=$1
   S1=$2
   S2=$3
   S3=$4
   S4=$5

   echo "Launching co-assembly for $GROUP..."

   BASE_DIR=~/Stage_Copenhague/decontamination
   OUT_DIR=~/Stage_Copenhague/assembly/$GROUP

   READ1_PAIRED=$(for s in $S1 $S2 $S3 $S4; do
      echo -n "$BASE_DIR/sample_$s/contaminant_free/sample_${s}_contaminant_free_read1_paired.fq.gz,"
   done | sed 's/,$//')

   READ2_PAIRED=$(for s in $S1 $S2 $S3 $S4; do
      echo -n "$BASE_DIR/sample_$s/contaminant_free/sample_${s}_contaminant_free_read2_paired.fq.gz,"
   done | sed 's/,$//') # s/ = substitute
                        # ,$ = comma at the end of a line
                        # // we replace it with nothing (we delete it)

   UNPAIRED=$(for s in $S1 $S2 $S3 $S4; do
      echo -n "$BASE_DIR/sample_$s/contaminant_free/sample_${s}_contaminant_free_read1_unpaired.fq.gz,"
      echo -n "$BASE_DIR/sample_$s/contaminant_free/sample_${s}_contaminant_free_read2_unpaired.fq.gz,"
   done | sed 's/,$//') # s/ = substitute
			# ,$ = comma at the end of a line
			# // we replace it with nothing (we delete it)

   # === Launch MEGAHIT ===
   megahit \
      -1 "$READ1_PAIRED" \
      -2 "$READ2_PAIRED" \
      -r "$UNPAIRED" \
      -o "$OUT_DIR" \
      --min-contig-len 1000 \
      --presets meta-large \
      -t 16

   echo "Finished co-assembly for $GROUP."
}

# === Export the function ===
export -f run_coassembly

# === Launch in parallel (2 groups at a time) ===
tail -n +2 ~/Stage_Copenhague/assembly/coassembly_groups.tsv | parallel -j 2 --colsep '\t' run_coassembly {1} {2} {3} {4} {5}

# === Total time ===
duration=$SECONDS
echo
echo "Analysis completed in $((duration / 60)) minutes and $(($duration % 60)) seconds."
