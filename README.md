# Shotgun Metagenomics Analysis - Internship Project 
This repository contains the full pipeline and documentation of the shotgun metagenomic analyses carried out during my internship at the University of Copenhagen (From 5 May to 22 August 2025), in the Microbial Interactions group (Section for Microbial Ecology and Biotechnology), Department of Plant and Environmental Sciences. The aim was to study the genomic potential and functional traits of the bacterial phylum **Verrucomicrobiota** by analysing data from 24 samples of rhizospheres from *Sheriff* wheat, taken at three different times (sowing took place on 26 September 2023, samples were collected at T3 : 12 October 2023, T6 : 26 October 2023 and T7 : 12 March 2024), and under two fertilisation conditions (N1K1 and N1P2K2).

---

## Project Overview
- **Location** : Long-Term Nutrient Depletion Trial - Mark33 ([55°40'40.8"N 12°17'36.4"E](https://maps.app.goo.gl/p2MLWcHezaJrYUzZ6)), Denmark
- **Target** : 24 rhizosphere samples, three different times (T3, T6, T7), two fertilization treatments (N1K1 and N1P2K2), four replicates each
- **Sequencing** : Shotgun metagenomics, paired-end, Illumina NovaSeq X Plus
- **Focus organism group** : Verrucomicrobiota

## Objectives 
- Explore the genomic potential of **Verrucomicrobiota** (e.g. NRPS, N<sub>2</sub>O reduction, secondary metabolites)
- Recover and annotate **metagenome-assembled genomes** (MAGs)
- Evaluate community and functional shifts  across time points and fertilization regimes
- Investigate intra-species microdiversity and pangenomic variation

---

## Pipeline Summary

The analysis was divided into the following steps : 
1. **Data download**
2. **Quality control** : \
&nbsp;&nbsp;&nbsp;&nbsp;a. Trimming  
&nbsp;&nbsp;&nbsp;&nbsp;b. Decontamination  
&nbsp;&nbsp;&nbsp;&nbsp;c. FastQC and MultiQC
3. **Assembly**
4. **Mapping**
5. **Binning**

A detailed diagram of the workflow is available in the `diagram/` folder.

---

## Folder Structures
Below you can find the directory structure of this GitHub repository. Each step in the pipeline is numbered and represents a folder.
```
/home/alexis/Stage_Copenhague/shotgun_metagenomics_analysis_internship/
├── 1_data_download
│   ├── download_reads.sh
│   ├── README.md
│   ├── test_scripts
│   │   └── test_wget.sh
│   └── zr11927_Rawdatalinks_250506.csv
├── 2_quality_control
│   ├── a_trimming
│   │   ├── adapters_removal_unpaired_reads.sh
│   │   ├── NexteraPE.fa
│   │   ├── README.md
│   │   ├── rename_samples_01_to_09.sh
│   │   ├── rename_samples_in_clean_reads.sh
│   │   ├── run_trim_fastp_sample01.sh
│   │   └── run_trim_fastp_sample02_to_24.sh
│   ├── b_decontamination
│   │   ├── counting_reads_after_decontamination.sh
│   │   ├── final_read_counts_decontamination.xlsx
│   │   ├── read_counts_decontamination.tsv
│   │   ├── README.md
│   │   ├── reads_decontamination_sample_01.sh
│   │   ├── reads_decontamination_samples_02_to_24.sh
│   │   ├── rename_paired_files.sh
│   │   └── unpaired_reads_decontamination_samples_01_to_24.sh
│   ├── c_fastqc_and_multiqc
│   │   └── README.md
│   └── README.md
├── 3_assembly
│   └── README.md
├── 4_mapping
│   └── README.md
├── 5_binning
│   └── README.md
├── diagram
│   ├── full_arborescence_github_repository.txt
│   └── full_server_arborescence.txt
├── envs
│   ├── bowtie2_env.yml
│   └── trim_env.yml
├── installation.md
└── README.md

11 directories, 30 files
```

The full directory structure used during the internship on the server `Thoth` (Ubuntu 22.04.5 LTS) is available here :

[`diagram/full_server_arborescence.txt`](diagram/full_server_arborescence.txt)

This reflects the actual execution environment, including input and output files, scripts, and results as stored under :
```bash
~/Stage_Copenhague/
```

**Note** : The GitHub repository mirrors the pipeline in a clean and reusable format, but the scripts refer to this original execution structure for clarity and reproducibility.

## Getting Started 
1. **Clone the repository** :
```bash
git clone https://github.com/AlexisBarrere/shotgun_metagenomics_bioinfo_workflow.git
cd shotgun_metagenomics_analysis_internship
```

2. **Install Conda & set up Conda environment** (choose the appropriate one depending on the step) : see the [installation.md](installation.md) file. 

3. **To install the other tools** (without conda)  
For tool installation instructions : see the [installation.md](installation.md) file.

4. **Navigate to each step folder** and follow the instructions in the corresponding `README.md`.

--- 

## Dependencies

The pipeline was developed and tested under the following software versions :

| Tool               | Version                                 | 
|--------------------|-----------------------------------------|
| awk (GNU)          | 5.1.0                                   | 
| Bash (GNU)         | 5.1.16(1)-release (x86_64-pc-linux-gnu) | 
| conda              | 25.5.1                                  | 
| parallel (GNU)     | 20210822                                | 
| wget (GNU)         | 1.21.2 (built on linux-gnu)             | 
| sed (GNU)          | 4.8                                     | 
| grep (GNU)         | 3.7                                     |
| gunzip             | 1.10                                    |
| screen (GNU)       | 4.09.00                                 |


_**NB** : All environments were managed with `conda` (see the `envs/` folder)_

---

## Reproducibility

All scripts used in this project are included and documented step-by-step. Each main folder (representing a stage in the workflow) contains :
- One or more scripts (`.sh`)
- A dedicated `README.md` containing :
  - The purpose of the step
  - The exact environments (`.yml`) and software used
  - The description of the scripts  
  - The input and output files
  - The settings and options applied
- Other files...



The pipeline was executed on the lab Linux server `Thoth` (Ubuntu 22.04.5 LTS - GNU/Linux 5.15.0-126-generic x86_64) using bash scripts.

---
## Notes

This workflow was built largely by following the tutorial [Anvi'o User Tutorial for Metagenomic Workflow](https://merenlab.org/2016/06/22/anvio-tutorial-v2) by merenlab, the creators of the `Anvi'o` tool.

---
## Acknowledgements

This project was carried out during my internship (May–August 2025) at the University of Copenhagen, Department of Plant and Environmental Sciences, Microbial Interactions Group.

I would like to thank my supervisor Mr **Frederik Bak** (Associate professor) for his guidance, and Ms **Mette Nicolaisen** (Research group leader) for agreeing to take me on as an intern in her group.
