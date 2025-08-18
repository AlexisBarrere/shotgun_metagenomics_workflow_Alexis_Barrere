#!/bin/bash

# === config ===
ROOT=~/Stage_Copenhague/visualisation_anvio

OUT_FILE=~/Stage_Copenhague/archaea_MAGs_taxonomy.tsv

# === Header ===
echo -e "MAG_ID\tt_domain\tt_phylum\tt_class\tt_order\tt_family\tt_genus\tt_species" > "$OUT_FILE"

# === Loop over all taxonomy files ===
find "$ROOT" -type f -path "*_MAGs_summarize/bin_by_bin/*/*-scg_taxonomy_details.txt" | while read tax_file; do

    # Get MAG ID from file path
    MAG_ID=$(basename "$tax_file" | sed 's/-scg_taxonomy_details.txt//')

    # Extract tax info from first non-header line (skip header)
    tax_line=$(tail -n +2 "$tax_file" | sort -k3,3nr | head -n1)

    # Extract taxonomic fields (columns 5 to 11 = t_domain to t_species)
    tax_fields=$(echo "$tax_line" | cut -f5-11)

    # Output MAG_ID and taxonomy
    echo -e "${MAG_ID}\t${tax_fields}" >> "$OUT_FILE"
done

echo "[INFO] Taxonomy summary written to: $OUT_FILE"
