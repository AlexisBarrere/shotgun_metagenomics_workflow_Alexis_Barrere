#!/bin/bash

ROOT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# === Inputs ===
INPUT=$ROOT/misc_data/layers/layers_data_after_metapangenome_command.txt
OUTPUT=$ROOT/misc_data/layers/layers_distribution_average.txt

# === Header of the new file ===
# -e option enables interpretation of backslash escapes such as \t for tabulation
echo -e "layers\tdistribution_average" > $OUTPUT

# === Process the input file ===
awk 'NR>1 {                         # Skip the header line
    sum=0                           # Initialize sum for each MAG
    for(i=12; i<=35; i++) sum += $i # Add up values from columns 10 to 33 (24 samples)
    print $1, sum/24                # Print MAG name and average (sum divided by 24)
}' OFS="\t" "$INPUT" >> "$OUTPUT"   # OFS = Output Field Separator.
                                    #  This is the separator that awk uses when it displays multiple fields with print (in this case, a tab).

echo "[INFO] File saved as $OUTPUT"
