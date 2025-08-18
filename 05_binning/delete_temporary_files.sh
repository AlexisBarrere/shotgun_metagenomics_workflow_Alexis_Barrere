#!/bin/bash

echo "Deleting temporary files (unzipped) from binning"

for i in $(seq -w 1 24); do

  WORKDIR=~/Stage_Copenhague/decontamination/sample_$i/contaminant_free/

  cd $WORKDIR

  rm sample_${i}_1.fastq sample_${i}_2.fastq

done

echo "All files have been deleted."
