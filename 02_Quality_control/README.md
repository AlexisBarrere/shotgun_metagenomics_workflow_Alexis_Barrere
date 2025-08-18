# Step 2 - Quality Control 
This step involves cleaning all raw reads and consists of three key stages : **trimming** with `Trimmomatic` and `FastP` (removing adapters, polyG tails, poor-quality reads, reads that are too small, ...), **decontamination** with `Bowtie2` (removing wheat, human and PhiX genomes) and finally generating **reports on read quality** with `FastQC` and `MultiQC`.

Each of the three stages is organized into its own dedicated subfolder:
- `a_trimming/`
- `b_decontamination/`
- `c_fastqc_and_multiqc/`

Each subfolder contains a `README.md` that details the purpose of the step, the tools and scripts used, the input and output files, and how the step was executed.
