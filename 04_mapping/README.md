# Step 4 - Mapping Reads to Contigs
This step consisted in mapping all cleaned and decontaminated reads (from 24 individual samples) onto their respective **assembled contigs**, using `Bowtie2` followed by `Samtools` and `Anvi'o`. The mapping was performed both at the **sample level** (individual assemblies) and at the **group level** (co-assemblies of 4 samples). These BAM files were later used for contig profiling in `Anvi'o`.

---
## Environment & Software Versions

All commands were executed on the Thoth server running : Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via 2 Conda environments defined in : 
- [`envs/bowtie2_env.yml`](../envs/bowtie2_env.yml)
- [`envs/anvio8_env.yml`](../envs/anvio8_env.yml)

| Tool      | Version | Installation method    |
|-----------|---------|------------------------|
| Bowtie2   | 2.5.4   | Conda (`bioconda`)     |
| Samtools  | 1.21    | Conda (`bioconda`)     |
| Anvi'o    | 8.0     | Conda (`bioconda`)     |

### Environment creation 
To recreate the environments from the root of the repository : 
```bash
# Mapping & BAM preparation
conda env create -f envs/bowtie2_env.yml
conda activate bowtie2_env

# For BAM initialization in Anvi'o
conda env create -f envs/anvio8_env.yml
conda activate anvio8_env
```
--- 

## Scripts
- [`mapping_sample_01.sh`](mapping_sample_01.sh)  
⭢ Mapping of sample 01 cleaned reads onto its own contigs. Used to test and validate the workflow.  

- [`auto_mapping.sh`](auto_mapping.sh)  
⭢ Automates the mapping process for **all individual samples** (01 to 24) in parallel.  

- [`auto_mapping_coassemblies.sh`](auto_mapping_coassemblies.sh)  
⭢ Automates the mapping of reads from **co-assembled groups** (6 groups × 4 samples) onto group contigs.

All scripts use paired and unpaired reads, and produce `.bam` files ready to be used in `Anvi'o`.

--- 

## Inputs
### reads
Cleaned and decontaminated reads for each sample are found in : `~/Stage_Copenhague/decontamination/sample_xx/contaminant_free/`

| File name pattern                                                                                    | Description      | 
|------------------------------------------------------------------------------------------------------|------------------|
| `sample_xx_contaminant_free_read1_paired.fq.gz`, `sample_xx_contaminant_free_read2_paired.fq.gz`     | Paired-end reads |
| `sample_xx_contaminant_free_read1_unpaired.fq.gz`, `sample_xx_contaminant_free_read2_unpaired.fq.gz` | Singleton reads  |

### Contigs 
Assembled and renamed contigs (≥ 1000 bp), either per sample or per group :
- Individual assemblies :  
`~/Stage_Copenhague/assembly/sample_xx/sample_xx_contigs_fixed.fa`
- Co-assemblies :  
`~/Stage_Copenhague/assembly/{GROUP}/{GROUP}_contigs_fixed.fa`

---
## Outputs
All output files are located in `~/Stage_Copenhague/mapping/`.

Each folder follows the structure :
- `mapping/sample_xx/sam_and_bam/`
- `mapping/{GROUP}/sam_and_bam/`

| File name                    | Description                               |
|------------------------------|-------------------------------------------|
| `sample_xx.bam`              | Final merged BAM file (paired + unpaired) |
| `contigs.*`                  | Bowtie2 index files                       |

Intermediate files (`*.sam`, `*-RAW.bam`) were automatically removed after **BAM** generation and `Anvi'o` formatting.

--- 

## Execution
### (i) Individual mapping
To test the mapping process on one sample :
```bash
mapping_sample_01.sh
```
This mapped all reads from sample_01 to its own contigs and produced :
- `sample_01_paired.bam`
- `sample_01_unpaired.bam`  

_**NB** : These two BAMs were not merged at this step._

The process was repeated in the next script, but this time for all 24 samples, merging the paired and unpaired **BAM** files.

To run the automated mapping on samples 01 to 24 :
```bash
auto_mapping.sh
```

The script:

- Builds `Bowtie2` index on each sample's contigs

- Maps paired and unpaired reads

- Converts `.sam` to `.bam` with `samtools`

- Merges paired + unpaired **BAMs** into a single `.bam` file

- Formats the raw **BAM** file for `Anvi'o` using `anvi-init-bam`. 

### (ii) Co-assembly Mapping
To map each group of 4 samples onto the corresponding co-assembly contigs :
```bash
auto_mapping_coassemblies.sh
```

The script :

- Loops over 6 groups defined in [`coassembly_groups.tsv`](../03_assembly/coassembly_groups.tsv)

- Builds `Bowtie2` index for each group

- Maps reads from each of the 4 samples in the group

- Produces one `.bam` file per sample per group

---
## Parameters
### Bowtie2 
*Documentation : [Bowtie2 Documentation](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml)*

- `--threads 8`: enables multithreading by using 8 CPU threads in parallel to speed up the alignment process. This significantly reduces computation time when aligning large metagenomic datasets.  

- `-x` : contig index path

- `-1/` and `-2/`: paired reads

- `-U` : unpaired reads - _The two files are separated by a comma (`,`) without a space._

- `-S` : output `.sam` file

### Samtools 
*Documentation : [Samtools Documentation](https://www.htslib.org/doc/samtools.html)*

- `view -F 4 -bS` :
    - `-F 4` : excludes unmapped reads ([flag 4 = read is unmapped](https://broadinstitute.github.io/picard/explain-flags.html)). Only reads that aligned to the reference are kept 

    - `-b` : outputs the result in BAM binary format instead of the default SAM format (text).

    - `-S` : tells `samtools` that the input is in SAM format (only required in older versions, but kept here for compatibility). 

- `merge` : merge paired and unpaired `.bam` files

### Anvi'o
*Documentation : [anvi-init-bam Documentation](https://anvio.org/help/main/programs/anvi-init-bam/)*

- `anvi-init-bam` : prepares **BAM** for `Anvi'o` compatibility. Indeed, this command index and sort the final **BAM** file. Indexing is the creation of a kind of "[**table of content**](https://anvio.org/help/main/artifacts/raw-bam-file/)" for the **BAM** file. This step creates a second file (`.bai`) that serves as an external table of contents, so that `Anvi'o` does not have to scan the entire **BAM** file during analysis.

---

## Notes 
- Some scripts use `GNU Parallel` to process multiple samples or groups simultaneously.  

- All mappings were performed using default `Bowtie2` end-to-end alignment mode.

- **BAM** files are formatted with `anvi-init-bam` to be compatible with `Anvi'o` downstream steps (profiling).

- Only mapped reads were retained (`samtools view -F 4`).

- Scripts use relative paths from `~/Stage_Copenhague`.
