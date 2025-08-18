#!/bin/bash

# === Paths ===
ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome
MULTIQC_FILE=$ROOT/barplots_3/multiqc_general_stats.txt

# === Output directory ===
OUT_DIR=$ROOT/barplots_3
mkdir -p "$OUT_DIR"

# === Output file ===
OUTFILE=$OUT_DIR/sequencing_effort_per_sample.tsv

# === Create header ===
echo -e "sample_id\ttotal_reads\tsequencing_effort_Gbp" > "$OUTFILE"

# === Calculate total reads and sequencing effort per sample ===
tail -n +2 "$MULTIQC_FILE" | \
awk -F"\t" '{
    # Extract base sample name (remove _read1/_read2 suffix and rest)
    sample=$1
    sub(/_read[12]_.*/, "", sample)
    
    # Column 4 = avg_read_length
    avg_len = $4
    
    # Column 7 = total_reads for this file
    reads = $7
    
    # Accumulate total reads per sample
    total_reads[sample] += reads
    
    # Accumulate total bases per sample
    total_bases[sample] += (avg_len * reads)
}
END {
    # Output ordered from sample_01 to sample_24
    for (i=1; i<=24; i++) {
        s = sprintf("sample_%02d", i)
        reads_val = (s in total_reads) ? total_reads[s] : 0
        effort_gbp = (s in total_bases) ? total_bases[s] / 1e9 : 0
        print s, reads_val, effort_gbp
    }
}' OFS="\t" >> "$OUTFILE"

echo "[INFO] Total reads and sequencing effort (Gbp) per sample saved to: $OUTFILE"
