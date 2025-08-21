# Shotgun Metagenomics Analysis - Internship Project 
This repository contains the full pipeline and documentation of the shotgun metagenomic analyses carried out during my internship at the University of Copenhagen (From 5 May to 22 August 2025), in the Microbial Interactions group (Section for Microbial Ecology and Biotechnology), Department of Plant and Environmental Sciences. The aim was to study the genomic potential and functional traits of the **Archaea** domain by analysing data from 24 samples of rhizospheres from *Sheriff* wheat, taken at three different times (sowing took place on 26 September 2023, samples were collected at T3 : 12 October 2023, T6 : 26 October 2023 and T7 : 12 March 2024), and under two fertilisation conditions (N1K1 and N1P2K2).

---

## Project Overview
- **Location** : Long-Term Nutrient Depletion Trial - Mark33 ([55°40'40.8"N 12°17'36.4"E](https://maps.app.goo.gl/p2MLWcHezaJrYUzZ6)), Denmark
- **Target** : 24 rhizosphere samples, three different times (T3, T6, T7), two fertilization treatments (N1K1 and N1P2K2), four replicates each
- **Sequencing** : Shotgun metagenomics, paired-end, Illumina NovaSeq X Plus
- **Focus organism group** : Archaea

## Objectives 
- Recover and annotate Archaeal **metagenome-assembled genomes** (MAGs)
- Perform a pangenomic analysis with the constructed **MAGs** and **NCBI Archaeal genomes**
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
6. **Anvi'o contigs database creation and annotations**
7. **Anvi'o profiling, bin import, taxonomy and summaries**
8. **Anvi'o preparation and manual curation of Archaeal bins**
9. **Dereplication**
10. **Downstream analysis**  
&nbsp;&nbsp;&nbsp;&nbsp;a. MAGs pangenome analysis  
&nbsp;&nbsp;&nbsp;&nbsp;b. Generate pangenome database with MAGs and NCBI genomes


A detailed diagram of the workflow is available in the `diagram/` folder.

---

## Folder Structures
Below you can find the directory structure of this GitHub repository. Each step in the pipeline is numbered and represents a folder.  
_**N.B :** The tree structure is not complete, only the first 2 layers are displayed._
```
/home/alexis/Stage_Copenhague/shotgun_metagenomics_analysis_internship/
├── 01_Data_download
│   ├── download_reads.sh
│   ├── README.md
│   ├── test_scripts
│   └── zr11927_Rawdatalinks_250506.csv
├── 02_Quality_control
│   ├── 2a_trimming
│   ├── 2b_decontamination
│   ├── 2c_fastqc_and_multiqc
│   └── README.md
├── 03_Assembly
│   ├── assembly_sample_01.sh
│   ├── coassembly_groups.tsv
│   ├── metaquast_coassembly.sh
│   ├── metaquast_results
│   ├── parallel_assembly.sh
│   ├── parallel_coassembly.sh
│   ├── quast_all_samples.sh
│   ├── README.md
│   ├── renaming_contigs_coassembly.sh
│   └── renaming_contigs.sh
├── 04_mapping
│   ├── auto_mapping_coassemblies.sh
│   ├── auto_mapping.sh
│   ├── mapping_sample_01.sh
│   └── README.md
├── 05_binning
│   ├── binning_coassemblies
│   ├── binning_single_assemblies
│   ├── bin_refinement
│   ├── delete_temporary_files.sh
│   └── README.md
├── 06_Anvi'o_contigs_database_creation_and_annotations
│   ├── create_contig_db_coassembly.sh
│   ├── create_contig_db.sh
│   ├── README.md
│   ├── run_annotations_all_samples.sh
│   └── run_annotations_coassemblies.sh
├── 07_Anvi’o_profiling_bin_import_taxonomy_and_summaries
│   ├── latest_analyses_all_samples.sh
│   ├── README.md
│   ├── step_05_bis_coassemblies.sh
│   ├── step_05_coassemblies.sh
│   └── steps_06_to_08_coassemblies.sh
├── 08_Anvi'o_preparation_and_manual_curation_of_Archaeal_bins
│   ├── anvi_summarize_V2_and_MAGs_all_coassemblies.sh
│   ├── anvi_summarize_V2_and_MAGs_all_samples.sh
│   ├── Archaea_and_directories_all_coassemblies.sh
│   ├── Archaea_and_directories_all_samples.sh
│   ├── create_MAGs_collections_all_co-assemblies.sh
│   ├── create_MAGs_collections_all_samples.sh
│   ├── README.md
│   ├── transfer_summaries_all_coassemblies.sh
│   ├── transfer_summaries_all_samples.sh
│   ├── Verrucomicrobiota_collections_all_coassemblies.sh
│   └── Verrucomicrobiota_collections_all_samples.sh
├── 09_Dereplication
│   ├── archaea_MAGs_taxonomy.xlsx
│   ├── create_fasta_files_directory.sh
│   ├── drep_without_reference.sh
│   ├── generate_MAGs_taxonomy_table.sh
│   ├── README.md
│   └── Summary_of_bins_before_drep.xlsx
├── 10_Downstream_analysis
│   ├── 10a_MAGs_pangenome_analysis
│   └── 10b_Generate_pangenome_database_with_MAGs_and_NCBI_genomes
├── diagram
│   ├── full_server_arborescence.txt
│   └── GitHub_repository_arborescence.txt
├── envs
│   ├── anvio8_env.yml
│   ├── anvio-8.yml
│   ├── bowtie2_env.yml
│   ├── centrifuge_env.yml
│   ├── drep_env.yml
│   ├── megahit_env.yml
│   ├── metawrap_env.yml
│   ├── quast_env.yml
│   └── trim_env.yml
├── installation.md
└── README.md
```

The full directory structure used during the internship on the server `Thoth` (Ubuntu 22.04.5 LTS) is available here :

[`diagram/full_server_arborescence.txt`](diagram/full_server_arborescence.txt)

This reflects the actual execution environment, including input and output files, scripts, and results as stored under : `~/Stage_Copenhague/`


>**Note 1** : The GitHub repository mirrors the pipeline in a clean and reusable format, but the scripts refer to this original execution structure for clarity and reproducibility.

>**Note 2** : You can find all HTML reports and figures in PDF format by clicking on the following index : [Index for HTML reports & PDF files (figures)](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/)
 


## Getting Started 
1. **Clone the repository** :
```bash
git clone https://github.com/AlexisBarrere/shotgun_metagenomics_workflow_Alexis_Barrere.git
cd shotgun_metagenomics_analysis_internship
```

2. **Install Conda & set up Conda environment** (choose the appropriate one depending on the step) : see the [installation.md](installation.md) file. 

3. **Install the other tools, databases, etc...**  
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
