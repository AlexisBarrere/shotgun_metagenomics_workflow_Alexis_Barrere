#!/bin/bash

# === Paths ===
ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome
MEAN_COV_SRC=$ROOT/anvio_summary/MAGs_summary/bins_across_samples/mean_coverage.txt
BINS_PERCENT_SRC=$ROOT/anvio_summary/MAGs_summary/bins_across_samples/bins_percent_recruitment.txt
SEQUENCING_EFFORT_FILE=$ROOT/barplots_3/sequencing_effort_per_sample.tsv

# === Output directory ===
OUT_DIR=$ROOT/barplots_3
mkdir -p "$OUT_DIR"

# === Copy source files into working directory ===
cp "$MEAN_COV_SRC" "$OUT_DIR"
cp "$BINS_PERCENT_SRC" "$OUT_DIR"

# === File paths after copy ===
MEAN_COV_FILE=$OUT_DIR/mean_coverage.txt
BINS_PERCENT_FILE=$OUT_DIR/bins_percent_recruitment.txt

# -------------------------------------------------------------------------
# Step 1: Clean column names in mean_coverage.txt
# In this file, sample names are in the header (columns 2+).
# We remove the "_reads_against_MAGs" suffix from these names.
# -------------------------------------------------------------------------
TMP_FILE=$(mktemp)
{
    head -n 1 "$MEAN_COV_FILE" | sed 's/_reads_against_MAGs//g'
    tail -n +2 "$MEAN_COV_FILE"
} > "$TMP_FILE" && mv "$TMP_FILE" "$MEAN_COV_FILE"
echo "[INFO] Cleaned sample names in: $MEAN_COV_FILE"

# -------------------------------------------------------------------------
# Step 2: Clean sample names in bins_percent_recruitment.txt
# In this file, sample names are in the first column.
# We remove the "_reads_against_MAGs" suffix only from this column.
# -------------------------------------------------------------------------
TMP_FILE=$(mktemp)
awk -v FS='\t' -v OFS='\t' '
NR==1 { gsub(/\r/, "", $0); print; next }
{
  gsub(/\r/, "", $0)
  sub(/_reads_against_MAGs$/, "", $1)
  print
}
' "$BINS_PERCENT_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$BINS_PERCENT_FILE"
echo "[INFO] Cleaned sample names in: $BINS_PERCENT_FILE"
# -------------------------------------------------------------------------
# Step 3: Calculate Mean Coverage per Sequenced Gigabase
# Formula: value = mean_coverage / sequencing_effort_Gbp
# - mean_coverage.txt: rows = MAGs, columns = samples
# - sequencing_effort_per_sample.tsv: columns = sample_id, total_reads, sequencing_effort_Gbp
# -------------------------------------------------------------------------
MCOV_PER_GBP_FILE=$OUT_DIR/mean_coverage_per_Gbp.txt

awk -v effort_file="$SEQUENCING_EFFORT_FILE" '
BEGIN {
    FS = OFS = "\t"
    # Load sequencing effort in Gbp into an array
    while ((getline < effort_file) > 0) {
        if (NR == 1) continue  # skip header
        effort_gbp[$1] = $3
    }
}
NR == 1 {
    # Store header line
    for (i=1; i<=NF; i++) header[i] = $i
    print $0
    next
}
{
    mag = $1
    printf "%s", mag
    for (i=2; i<=NF; i++) {
        sample = header[i]
        if (sample in effort_gbp && effort_gbp[sample] > 0) {
            val = $i / effort_gbp[sample]
        } else {
            val = 0
        }
        printf "\t%.10f", val
    }
    printf "\n"
}
' "$MEAN_COV_FILE" > "$MCOV_PER_GBP_FILE"

echo "[INFO] Mean coverage per sequenced Gbp table saved to: $MCOV_PER_GBP_FILE"
