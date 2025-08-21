#!/bin/bash

# === Inputs ===
INPUT=~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/barplots_3/multiqc_general_stats_pre_trim.txt
OUTPUT=~/Stage_Copenhague/statistics/mean_min_max_reads.txt
mkdir -p $(dirname $OUTPUT)

awk -F'\t' 'NR>1 {
    split($1, a, "_")
    sample=a[2]
    reads[sample] += $7
}
END {
    min=1e20; max=0; sum=0; n=0
    out="'$OUTPUT'"

    # valeurs par échantillon
    for (s in reads) {
        val=reads[s]
        printf "%02d\t%d\n", s, val >> out
        sum+=val; n++
        if (val<min) min=val
        if (val>max) max=val
    }

    mean=sum/n

    # écrire résumé dans fichier
    print "Total: " sum >> out
    print "Mean: " mean >> out
    print "Min: " min >> out
    print "Max: " max >> out

    # afficher aussi dans terminal
    print "Total: " sum
    print "Mean: " mean
    print "Min: " min
    print "Max: " max
}' "$INPUT"