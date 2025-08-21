# Step 10a - MAGs pangenome analysis

This step consisted in building an **Anvi'o pangenome** for the **12 dereplicated Archaeal MAGs** and linking it to the environment (metapangenome) : reformatting MAG FASTA files, creating/annotating a dedicated **contigs database**, assigning **taxonomy** (Centrifuge + SCG), **mapping** reads from the 24 samples to MAGs, generating **per-sample profiles** and a **merged profile**, importing MAGs as a **collection**, producing **summary reports**, generating the **internal genomes file**, and finally **computing the pangenome**. A table of **mean coverage per sequenced giga base pairs** was produced, and used to produce plots.

> ⚠️ This step assumes that **dereplication** (Step 9) has been completed and that **contaminant-free reads** are available for the 24 samples (from previous steps).  
> Paths and file names below follow the project structure defined earlier and used in the scripts of this step.

---

## Environment & Software Versions
All commands were executed on the Thoth server running : Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via Conda environments defined in :  
- [`envs/anvio8_env.yml`](../../envs/anvio8_env.yml)  
- [`envs/bowtie2_env.yml`](../../envs/bowtie2_env.yml)  
- [`envs/centrifuge_env.yml`](../../envs/centrifuge_env.yml)  

| Tool        | Version | Installation method |
|-------------|---------|---------------------|
| Anvi'o      | 8.0     | Conda (`bioconda`)  |
| Bowtie2     | 2.5.4   | Conda (`bioconda`)  |
| Samtools    | 1.22    | Conda (`bioconda`)  |
| Centrifuge  | 1.0.4.2 | Conda (`bioconda`)  |
| R           | 4.4.1   | System installation |

### Environment creation
To recreate the environment from the root of the repository :
```bash
# Anvi'o environment
conda env create -f envs/anvio8_env.yml
conda activate anvio8_env

# Bowtie2 environment
conda env create -f envs/bowtie2_env.yml
conda activate bowtie2_env

# Centrifuge environment 
conda env create -f envs/centrifuge_env.yml
conda activate centrifuge_env
```
---

## Scripts

- [`1_reformat_fasta_MAGs.sh`](1_reformat_fasta_MAGs.sh)  
⭢ Reformats dereplicated MAGs FASTA files with simplified headers, ensuring compatibility with `Anvi'o`.  

- [`2_concatenate_fasta_files.sh`](2_concatenate_fasta_files.sh)  
⭢ Concatenates all reformatted MAGs into a single combined FASTA file.  
_This unique fasta file grouping the contigs of the **12 Archaean MAGs** is available in this GitHub repository : [all_MAGs.fa](MAGs_data/all_MAGs.fa)_ 

- [`3_create_and_annotate_contigs_db_MAGs.sh`](3_create_and_annotate_contigs_db_MAGs.sh)  
⭢ Creates an `Anvi'o` contigs database for the combined MAGs, runs HMMs for SCG detection, and annotates genes against NCBI COGs.  

- [`4_centrifuge_and_SCG_taxonomy.sh`](4_centrifuge_and_SCG_taxonomy.sh)  
⭢ Assigns gene-level taxonomy with **Centrifuge**, imports results into `Anvi'o`, and estimates SCG-based taxonomy for MAGs.  

- [`5a_mapping_reads_against_MAGs.sh`](5a_mapping_reads_against_MAGs.sh)  
⭢ Maps all cleaned and decontaminated reads (samples 01-24) against the combined MAGs FASTA using **Bowtie2**, generates SAM/BAM files, and sorts and index them with **Samtools**.  

- [`5b_profiling_mapping_results.sh`](5b_profiling_mapping_results.sh)  
⭢ Creates `Anvi'o` profile databases for each BAM file, linking coverage information to the MAGs.  

- [`5c_generate_merged_anvio_profile_db.sh`](5c_generate_merged_anvio_profile_db.sh)  
⭢ Merges all per-sample profile databases into a single **multi-profile DB** for downstream analyses.  

- [`5d_create_and_import_collections.sh`](5d_create_and_import_collections.sh)  
⭢ Generates collections (MAG ↔ contigs association + sources & RGB color metadata) and imports them into `Anvi'o`.  

- [`5e_estimate_scg_taxonomy_and_summarize_collections.sh`](5e_estimate_scg_taxonomy_and_summarize_collections.sh)  
⭢ Assigns SCG-based taxonomy for each MAG and generates summary reports including amino acid sequences.  

- [`6a_generate_internal_genome_file.sh`](6a_generate_internal_genome_file.sh)  
⭢ Generates the `internal-genomes_MAGs.txt` file describing all MAGs databases for pangenome analysis.  

- [`6b_generate_and_computing_pangenome.sh`](6b_generate_and_computing_pangenome.sh)  
⭢ Builds the `genomes-storage.db` and computes the pangenome with `anvi-pan-genome` (using NCBI BLAST for homology).  

- [`7_add_genus_to_layers_misc_data_MAGs.sh`](7_add_genus_to_layers_misc_data_MAGs.sh)  
⭢ Extracts the genus information from [bins_summary.txt](MAGs_summary/bins_summary.txt) (MAGs `Anvi'o summary`) and adds it as a new column (`genus`) in the layers misc-data file. Empty genera are replaced by `None`.  

- [`8_add_distribution_average_to_layers_misc_data_metapangenome_MAGs.sh`](8_add_distribution_average_to_layers_misc_data_metapangenome_MAGs.sh)  
⭢ Calculate the average distribution of each MAG across the 24 samples, writes the results into a new metadata file.

- [`9a_extract_total_number_of_reads_per_sample.sh`](9a_extract_total_number_of_reads_per_sample.sh)  
⭢ Extracts per-sample sequencing effort (total number of bases sequenced per sample, in giga base pairs - Gbp) from MultiQC general stats ([multiqc_general_stats.txt](barplots_data/multiqc_general_stats.txt)), producing [sequencing_effort_per_sample.tsv](barplots_data/sequencing_effort_per_sample.tsv).  

- [`9b_create_mean_coverage_per_sequenced_Gbp_file.sh`](9b_create_mean_coverage_per_sequenced_Gbp_file.sh)    
⭢ Normalizes MAGs mean coverage per sample by sequencing effort, producing [mean_coverage_per_Gbp.txt](barplots_data/mean_coverage_per_Gbp.txt) for comparative analyses.  

- [`10a_generate_metadata_table.R`](10a_generate_metadata_table.R)  
⭢ Generates a metadata table linking each sample to its experimental conditions (time, fertilizer, coassembly group).

- [`10b_generate_barplots_and_dotplots.R`](10b_generate_barplots_and_dotplots.R)  
⭢ Generates barplots (mean ± SD) and dotplots (raw data + mean + median) of MAGs mean coverage per sequenced Gbp across conditions.

- [`10c_generate_barplot_most_abundant_taxa_per_group.R`](10c_generate_barplot_most_abundant_taxa_per_group.R)  
⭢ Creates grouped barplots of the most abundant Archaeal taxa per experimental group.

- [`10d_new_plot_stack_bar.R`](10d_new_plot_stack_bar.R)
⭢ Produces stacked barplots of **Mean coverage per sequenced Gbp**  per MAG and per genus across all samples.

- [`10e_new_plot_stack_bar_grouped.R`](10e_new_plot_stack_bar_grouped.R)  
⭢ Produces stacked barplots of **Mean coverage per sequenced Gbp**  per MAG and per genus across all samples (grouped by condition time x fertilizer)


---

## Inputs (from Thoth server)

### Dereplicated MAGs (from Step 9)
- Dereplicated Archaeal MAGs (12 genomes) (**Thoth**) :  
  `~/Stage_Copenhague/drep_analysis/drep_output_without_reference/dereplicated_genomes/*.fa`

### Reads (from previous steps)
- Cleaned & decontaminated reads (24 samples) (**Thoth**) :  
  `~/Stage_Copenhague/decontamination/sample_xx/contaminant_free/sample_xx_contaminant_free_[read1|read2]_[paired|unpaired].fq.gz`

### Reference databases
- Centrifuge database (**Thoth**) :  
  `~/Stage_Copenhague/databases/centrifuge_db/p_compressed+h+v`  
- NCBI COGs database (for `anvi-run-ncbi-cogs`) :  
  `~/anvio_cogs/`

### MultiQC report (to calculate the sequencing effort)
- MultiQC general stats file (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/barplots_3/multiqc_general_stats.txt`

### Coassembly groups file 
- **Local WSL Ubuntu** :  `~/Stage_Copenhague/visualisation_anvio/coassembly_groups.tsv`  
- **Thoth** : `~/Stage_Copenhague/assembly/coassembly_groups.tsv`  
_Also available in this GitHub repository : [coassembly_groups.tsv](barplots_data/coassembly_groups.tsv)_ 

### Misc data
- File containing the genus associated with each MAG (**Thoth**) :  
`~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/anvio_summary/MAGs_summary/bins_summary.txt`  
_Available in this GitHub repository : [bins_summary.txt](MAGs_summary/bins_summary.txt)_

- file containing the layers misc data after running the `anvi-meta-pan-genome` command (**Thoth**) :  
`~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/misc_data/layers/layers_data_after_metapangenome_command.txt`  
_Available in this GitHub repository : [layers_data_after_metapangenome_command.txt](misc_data/layers_data_after_metapangenome_command.txt)_ 

---

## Outputs (from Thoth server)

### FASTA files
- Reformatted MAGs genomes (simplified headers) (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/reformatted_MAGs_genomes/*.fa`  
- Combined FASTA (all 12 MAGs) (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/combined_genomes/all_MAGs.fa`  
_Available in this GitHub repository : [all_MAGs.fa](MAGs_data/all_MAGs.fa)_ 

### Anvi'o databases
- MAGs contigs database (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/contigs_db/MAGs_contigs.db`  
- Per-sample Anvi'o profiles (24 samples) (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/profile_db/MAGs/sample_xx/PROFILE.db`  
- Merged profile database (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/profile_db/MAGs_MERGED/PROFILE.db`

### BAM files (**Thoth**)
- `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/mapping/MAGs/sam_and_bam/MAGs_sample_xx.bam`

### Collections
- MAGs collection file (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/collections/MAGs_collection.txt`  
_Available in this GitHub repository : [MAGs_collection.txt](MAGs_data/MAGs_collection.txt)_  
- MAGs bins info (origin & RGB colors) (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/collections/MAGs_bins_info.txt`  
_Available in this GitHub repository : [MAGs_bins_info.txt](MAGs_data/MAGs_bins_info.txt)_ 

### Taxonomy
- Centrifuge gene calls (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/taxonomy_results/MAGs_gene_calls.fa`  
_Available in this GitHub repository : [MAGs_gene_calls.fa](MAGs_data/MAGs_gene_calls.fa)_
  
- Centrifuge classification results (**Thoth**) :  
  - `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/taxonomy_results/MAGs_centrifuge_hits.tsv`  
  _Available in this GitHub repository : [MAGs_centrifuge_hits.tsv](MAGs_data/MAGs_centrifuge_hits.tsv)_  
  - `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/taxonomy_results/MAGs_centrifuge_report.tsv`  
  _Available in this GitHub repository : [MAGs_centrifuge_report.tsv](MAGs_data/MAGs_centrifuge_report.tsv)_   
- SCG-based taxonomy (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/taxonomy_results/MAGs_scg_taxonomy.txt`  
_Available in this GitHub repository : [MAGs_scg_taxonomy.txt](MAGs_data/MAGs_scg_taxonomy.txt)_

### Summaries
- `Anvi'o` summary for MAGs (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/anvio_summary/MAGs_summary/`  
  (includes `bins_summary.txt`, `bins_across_samples/mean_coverage.txt`, `bins_across_samples/bins_percent_recruitment.txt`, ...)  
_Available in this GitHub repository : `MAGs_summary` folder_

### Pangenome analysis
- Internal genomes file (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/pangenome/internal-genomes_MAGs.txt`  
_Available in this GitHub repository : [internal-genomes_MAGs.txt](MAGs_data/internal-genomes_MAGs.txt)_  
- Genomes storage (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/pangenome/MAGs-PAN-GENOMES.db`  
- Pangenome computation results (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/pangenome/MAGs-PAN-COMPUTED/`
- Pangenome database (**Thoth**) :  
`~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db`

### Misc data
- Misc data layers with additional genus information (**Thoth**) :  
`~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/misc_data/layers/layers_modified_with_genus.txt`  
_Available in this GitHub repository : [layers_modified_with_genus.txt](misc_data/layers_modified_with_genus.txt)_ 

- file containing the misc data layers after adding the average distribution (mean coverage average) of the MAGs across the 24 samples (**Thoth**) :  
`~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/misc_data/layers/layers_distribution_average.txt`  
_Available in this GitHub repository : [layers_distribution_average.txt](misc_data/layers_distribution_average.txt)_

### Normalization & visualization
- Sequencing effort per sample (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/barplots_3/sequencing_effort_per_sample.tsv`  
_Available in this GitHub repository : [sequencing_effort_per_sample.tsv](barplots_data/sequencing_effort_per_sample.tsv)_  
- Normalized mean coverage per Gbp (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/barplots_3/mean_coverage_per_Gbp.txt`  
_Available in this GitHub repository : [mean_coverage_per_Gbp.txt](barplots_data/mean_coverage_per_Gbp.txt)_  
- Cleaned percent recruitment table (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/barplots_3/bins_percent_recruitment.txt`  
_Available in this GitHub repository : [bins_percent_recruitment.txt](barplots_data/bins_percent_recruitment.txt)_  
- Metadata table (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/barplots_3/metadata.tsv`  
_Available in this GitHub repository : [metadata.tsv](barplots_data/metadata.tsv)_  
- Graphical outputs (barplots, dotplots, stacked barplots) (**Thoth**) :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/barplots_3/graphics/`  

_Available in this GitHub repository (`graphics/`folder) :_  
⭢ [Mean coverage per sequenced Gbp for the 12 MAGs across fertilizers and time points (barplots & dotplots)](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/graphics/all_samples_mean_coverage_per_Gbp.pdf)

⭢ [Mean percent recruitment of the 12 MAGs (colored by archaeal genus) in each of the 6 co-assembly groups](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/graphics/barplots_bins_percent_by_group.pdf)

⭢ [Mean coverage per sequenced Gbp of the 12 MAGs (stacked by genus) across the 24 samples](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/graphics/all_samples_mean_coverage_per_Gbp.pdf)

⭢ [Mean coverage per sequenced Gbp of the 12 MAGs (stacked by genus) across the 24 samples and grouped by condition (time x fertilizer)](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/graphics/all_samples_mean_coverage_per_Gbp_grouped_paletteer.pdf)

Or you can find the figures by clicking on the following link : [Index HTML reports](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/)

---

## Execution
I followed the [prochlorococcus metapangenome tutorial](https://merenlab.org/data/prochlorococcus-metapangenome/) from the creators of `Anvi'o` for this step.

### 1. Reformat fasta files
I created a working folder by running the following command from the terminal :  
```bash
mkdir -p ~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome
```

Then I ran the following script to format the names of the contigs of my 12 Archean MAGs obtained after dereplication, in order to simplify the headers and ensure compatibility with `Anvi'o` :
```bash
1_reformat_fasta_MAGs.sh
```

### 2. Concatenate fasta files
Subsequently, I concatenated the 12 fasta files of my Archean MAGs into a single one :
```bash
2_concatenate_fasta_files.sh
```

### 3. Generate & annotate `Anvi'o` contigs database for MAGs
I created a contigs database for my 12 MAGs, then annotated it by running `anvi-run-hmms` to detect SCGs and `anvi-run-ncbi-cogs` to associate genes in this contigs database with functions (via the COGs database) :
```bash
3_create_and_annotate_contigs_db_MAGs.sh
```

### 4. Centrifuge and SCG taxonomy
I used the `Centrifuge` metagenomic sequence classifier to assign a gene-level taxonomy to my MAGs, and imported the results into `Anvi'o` with the `anvi-import-taxonomy-for-genes` command. This provided taxonomic labels for individual genes.
Then, I estimated the genome-level taxonomy of my MAGs using the `anvi-run-scg-taxonomy` command, which relies on the identification and classification of single-copy core genes (SCGs) to produce a more robust consensus taxonomy :
```bash
4_centrifuge_and_SCG_taxonomy.sh
```

### 5. Recruiting and profiling reads from metagenomes
#### 5. a) Recruitment of reads from the 24 samples on the 12 MAGs
I used a script similar to the one in **step 4 (mapping)** to map the reads of all 24 samples to my 12 Archean MAGs :
```bash
5a_mapping_reads_against_MAGs.sh
```

#### 5. b) Profiling the mapping results with `Anvi'o`
The following script was used to generate an `Anvi'o` profile database for each BAM file (one per sample), containing the coverage information of the reads mapped to the 12 MAGs : 
```bash
5b_profiling_mapping_results.sh
```

#### 5. c) Generating a merged `Anvi'o` profile database
This script merged the individual profile databases (one per sample) into a single `Anvi'o` merged profile database, which is required for subsequent analyses :
```bash
5c_generate_merged_anvio_profile_db.sh
```
#### 5. d) Generating and importing collections
I created a collection for the 12 archaeal MAGs by retrieving their genome names and associated splits from the `splits_basic_info` table of the contigs database. An info file specifying the source/origin of each genome (MAGs reconstructed bioinformatically) and their colors was then generated. Finally, the collection and its info file were imported into `Anvi'o` using the `anvi-import-collection` command.

```bash
5d_create_and_import_collections.sh
```

To check the presence of the collection in the merged profile database I executed the following command in my terminal :
```bash
anvi-show-collections-and-bins -p ~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/profile_db/MAGs_MERGED/PROFILE.db
```

#### 5. e) Estimate scg taxonomy and summarize collections
In the following script, I used the `anvi-estimate-scg-taxonomy` command to assign taxonomy to the 12 genomes based on the results of `anvi-run-scg-taxonomy`. I then summarized my collection of MAGs with the `anvi-summarize` command, generating detailed coverage and detection data for each gene (`--init-gene-coverages`) and reporting the amino acid sequences of gene calls (`--report-aa-seqs-for-gene-calls`).
```bash
5e_estimate_scg_taxonomy_and_summarize_collections.sh
```

### 6. Computing the pangenome
#### 6. a) Generate the internal genome file
This script was used to generate the [internal-genomes_MAGs.txt](MAGs_data/internal-genomes_MAGs.txt) file. In this file, each MAG is linked to its collection identifier (`Archaeal_MAGs`), together with the paths to the `PROFILE.db` and the `contigs database` on the **Thoth** server.
```bash
6a_generate_internal_genome_file.sh
```

#### 6. b) Generate and compute pangenome
This script created a genome storage file from [internal-genomes_MAGs.txt](MAGs_data/internal-genomes_MAGs.txt) using the `anvi-gen-genomes-storage` command. The genome storage file stores all available information about the genomes (here, the 12 MAGs) for use in the pangenomic workflow.
I then ran the `anvi-pan-genome` command, which generated a pan database (`PAN.db`) and performed various pangenomic analyses, such as computing sequence similarity, identifying and organizing gene clusters, organizing genomes in the pangenome, etc...

In `Anvi'o`, [gene clusters](https://anvio.org/vocabulary/#gene-cluster) are the fundamental units of a pangenome. They represent groups of homologous genes (also referred to in the literature as **protein clusters**, **orthogroups**, **groups of orthologous genes** or **operational protein families**) identified across input genomes. Unlike biosynthetic gene clusters (which describe functionally related genes that belong to the same operon in a single chromosome), pangenomic gene clusters are de **novo constructs** built by (1) identifying all genes among a set of genomes, (2) computing similarities between each gene using translated DNA sequences, and (3) grouping genes that are homologous enough to belong to the same cluster. A gene cluster may therefore contain one or more genes from one or more genomes.

```bash
6b_generate_and_computing_pangenome.sh
```

### 7. Visualize the pangenome
To view the pangenome, I needed to use the `Anvi'o` interactive interface. I needed to copy the `downstream_analysis/` folder into my local computer (WSL Ubuntu session).  
 _Before, I needed to add **Thoth** to the list of IPs (name resolution), see the [installation.md](../../installation.md) file section V._
 ```bash
 scp -r alexis@thoth:/home/alexis/Stage_Copenhague/downstream_analysis /home/alexis/Stage_Copenhague
 ```

To visualize the pangenome :
```bash
# Place yourself in the correct working directory
cd ~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# Use anvi-display-pan
anvi-display-pan -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -g pangenome/MAGs-PAN-GENOMES.db
```
To organize the genomes (MAGs) based on gene clustering results, I selected the `gene_cluster frequencies` tree from the `Layers Tab` > `Order by` > `gene_cluster_frequencies (tree)`

_I saw a tree appear on the right, which organises the MAGs according to the clustering results._

#### 7. a) Misc data
For this step I worked on my **local WSL Ubuntu** session.

```bash
# Working directory on my computer 
cd ~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# Create folders for misc data
mkdir -p misc_data
mkdir -p misc_data/layers
mkdir -p misc_data/layer_orders
mkdir -p misc_data/items

# export the misc data layers table
anvi-export-misc-data -o misc_data/layers/layers_additional_data.txt -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -t layers
```

Then I wrote a script that appended the genus information of each of the 12 MAGs into the layers misc data file, enabling this metadata to be displayed in `Anvi'o` visualizations :
```bash
7a_add_genus_to_layers_misc_data_MAGs.sh
```

And I imported the genus information into the `PAN.db` :
```bash
anvi-import-misc-data misc_data/layers/layers_modified_with_genus.txt -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -t layers
``` 

#### 7. b) Anvi-interactive : coverage of the Archaeal_MAGs collection accross the 24 samples
To visualize the mean coverage of 12 MAGs across the 24 samples, I need to use `anvi-interactive`. But before, I wanted to add the coasembly groups to the layers misc data of the `PROFILE.db` :

I used this file : `layers_additional_data.txt`

I then modified the file using Excel, adding two columns (coassembly_group and colour), then saved a new file (`layers_metadata_coassemblage.txt`) in `.txt` format separated by tabs (`\t`) :
```
layers	coassembly_group	color	num_INDELs_reported	total_reads_mapped	num_SNVs_reported	total_reads_kept
sample_01_reads_against_MAGs	T6_N1K1	#FFB6C1	5664	1152824	151715	1152824
sample_02_reads_against_MAGs	T6_N1P2K2	#87CEFA	1809	743144	43076	743144
sample_03_reads_against_MAGs	T6_N1K1	#FFB6C1	486	418726	12332	418726
... 
```

And then I imported the new file into the merged `PROFILE.db` :
```bash
anvi-import-misc-data misc_data/MAGs/layers_metadata_coassemblage.txt -p profile_db/MAGs_MERGED/PROFILE.db -t layers
 ```

**Useful commands :**
 ```bash
# To view available keys : 
anvi-delete-misc-data -p profile_db/MAGs_MERGED/PROFILE.db \
                      -t layers \
                      --list-available-keys

# To delete the color column : 
anvi-delete-misc-data -p profile_db/MAGs_MERGED/PROFILE.db \
                      --target-data-table layers \
                      --keys-to-remove color
```

And to visualize the mean coverage of each MAG across the 24 samples :
```bash
# Set working directory
cd ~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome

# Open anvi-interactive
anvi-interactive -p profile_db/MAGs_MERGED/PROFILE.db -c contigs_db/MAGs_contigs.db -C Archaeal_MAGs
```

Enter `http://localhost:8080` in a browser (preferably Chrome)


#### 7. c) Identify Singleton genes, Core genome and accessory genes. 
After running `anvi-display-pan`, by going to the `search` table and selecting `Search gene clusters using filters`, I selected different types of **gene clusters** by applying different parameters.

**Here are the parameters I applied :**  
- For **Core Genome** (Genes present in all genomes being analyzed) :
  - `Min number of genomes gene cluster occurs = 12`

- For **Accessory Genome** (Genes present in two or more, but not all, genomes) :
  - `Min number of genomes gene cluster occurs = 2`
  - `Max number of genomes gene cluster occurs = 11`

- For **Singleton Genes** (Genes found in only one genome within the set) :
  - `Min number of genomes gene cluster occurs = 1`
  - `Max number of genomes gene cluster occurs = 1`

  Then I saved the pangenome using the program anvi-summarize : 
  ```bash
  anvi-summarize -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -g pangenome/MAGs-PAN-GENOMES.db -C Core_Accessory_Singleton -o anvio_summary/pangenome_summary
  ```
  _Available in this GitHub repository : `pangenome_summary` folder._

⭢ This allowed me to provide information such as the number of gene clusters for each category of gene clusters (Core Genome, Accessory Genome, Singleton Genes), or the [MAGs-PAN_gene_clusters_summary.txt](pangenome_summary/MAGs-PAN_gene_clusters_summary.txt/MAGs-PAN_gene_clusters_summary.txt) file that links each gene to gene clusters, genomes, functions, and bins selected from the interface.

### 8. Environmental connectivity of each gene cluster
I used the program `anvi-meta-pan-genome` to integrates the information from an [internal-genomes artifact](https://anvio.org/help/7/artifacts/internal-genomes/) ([internal-genomes_MAGs.txt](MAGs_data/internal-genomes_MAGs.txt)) into a [pan-db](https://anvio.org/help/7/artifacts/pan-db/), creating a **metapangenome**.
A metapangenome contains both the information in a metagenome (i.e. their abundances in different samples as described in the `PROFILE.db`) and the information in a pangenome (i.e. the gene clusters in my dataset). This is useful because we are able to observe which gene cluster patterns are present in certain environments.  
_For an example of a metapangenomic workflow, take a look [here](https://merenlab.org/data/prochlorococcus-metapangenome/) (this tutorial was written before this program, but the insights persist)._

```bash
# Perform the anvi-meta-pan-genome command
anvi-meta-pan-genome -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -g pangenome/MAGs-PAN-GENOMES.db -i pangenome/internal-genomes_MAGs.txt

# Observe the result
anvi-display-pan -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -g pangenome/MAGs-PAN-GENOMES.db

# Export layers misc data
anvi-export-misc-data -o misc_data/layers/layers_data_after_metapangenome_command.txt -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -t layers

# Export layer orders misc data
anvi-export-misc-data -o misc_data/layer_orders/layer_orders_data_after_metapangenome_command.txt -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -t layer_orders

# Export items misc data
anvi-export-misc-data -o misc_data/items/items_data_after_metapangenome_command.txt -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -t items
```

after all these steps, I saved the metapangenome using the program anvi-summarize :
```bash
anvi-summarize -p pangenome/MAGs-PAN-COMPUTED/MAGs-PAN-PAN.db -g pangenome/MAGs-PAN-GENOMES.db -C Core_Accessory_Singleton -o anvio_summary/metapangenome_summary
```
_Available in this GitHub repository : `metapangenome_summary` folder._

Finally, I wrote a script to calculate the average distribution of each MAG over the 24 samples and add it as additional metadata in my pangenome (`PAN.db`) : 

```bash
8_add_distribution_average_to_layers_misc_data_metapangenome_MAGs.sh
```

### 9. Plots
To visualize the normalized coverage of the 12 Archaeal MAGs across experimental conditions, I executed four R scripts (R 4.4.1). These scripts produced the final figures used in the report.

_Outputs were saved in the `graphics/` folder of this repository as `PDF` figures._

#### 9. a) Generate metadata table
I first created a metadata file linking each of the 24 samples to its experimental conditions (`time`, `fertilizer`, and `coassembly_group`). This was done with the following script :
```
10a_generate_metadata_table.R
```
This script produced the [metadata.tsv](barplots_data/metadata.tsv) file, which was then used in all subsequent plotting steps.

#### 9. b) Barplots and dotplots
I then generated barplots (mean ± SD) and dotplots (showing raw data, mean, and median) to compare the mean coverage per sequenced Gbp across experimental conditions :
```
10b_generate_barplots_and_dotplots.R
```

#### 9. c) Most abundant taxa per group
To highlight which Archaeal taxa dominated in each experimental condition (time × fertilizer groups), I created grouped barplots of the most abundant MAGs :
```
10c_generate_barplot_most_abundant_taxa_per_group.R
```
This produced figures comparing the relative abundance of different taxa (genus) across the six coassembly groups.

#### 9. d) Stacked barplots
Finally, I produced stacked barplots showing the contribution of each MAG and its genus to the total mean coverage per sequenced Gbp across all samples :
```
10d_new_plot_stack_bar.R

10e_new_plot_stack_bar_grouped.R
```
These stacked plots provide a global overview of the distribution of MAGs by genus and facilitate the identification of dominant lineages.


--- 

## Parameters

Below is a description of the key commands and their parameters used in this step.

---

### anvi-script-reformat-fasta _([documentation](https://anvio.org/help/main/programs/anvi-script-reformat-fasta/))_
- Input : fasta file to simplify
- `--simplify-names` : replace long contig headers by simplified names.
- `--report-file` : report file mapping old ↔ new contig names.
- `--prefix` : allows you to add a prefix to each contig
- `-o` : output FASTA file.


### cat (concatenate fasta files)
- `cat *.fa > all_MAGs.fa` : concatenates all MAG FASTA files into a single file.

### anvi-gen-contigs-database *([documentation](https://anvio.org/help/main/programs/anvi-gen-contigs-database/))*
- `-f` : input FASTA file (all MAGs).  
- `-o` : output contigs database.  
- `-n` : name for the database.  

### anvi-run-hmms *([documentation](https://anvio.org/help/main/programs/anvi-run-hmms/))*
- `-c` : contigs database to annotate with HMMs.  
- `-T` : number of threads

### anvi-run-ncbi-cogs *([documentation](https://anvio.org/help/main/programs/anvi-run-ncbi-cogs/))*
- `-c` : contigs database.  
- `--cog-data-dir` : path to COG 2020 database (**Thoth server**)
- `-T` : number of CPU threads to use.  

### anvi-get-sequences-for-gene-calls *([documentation](https://anvio.org/help/main/programs/anvi-get-sequences-for-gene-calls/))*
- `-c` : contigs database.  
- `-o` : output file (`MAGs_gene_calls.fa`)

### centrifuge *([documentation](https://ccb.jhu.edu/software/centrifuge/manual.shtml))* 
- `-x` : centrifuge index (reference database).  
- `-U` : input gene calls file (FASTA).  
- `-S` : classification results output file.  
- `--report-file` : summary report file.  
- `-p` : number of threads 

### anvi-import-taxonomy-for-genes *([documentation](https://anvio.org/help/7/programs/anvi-import-taxonomy-for-genes/))*
- `-c` : contigs database.  
- `-i` : taxonomy classification results files (`MAGs_centrifuge_report.tsv` & `MAGs_centrifuge_hits.tsv`).  
- `-p` : taxonomy source (here : **centrifuge**).  

### anvi-run-scg-taxonomy *([documentation](https://anvio.org/help/7/programs/anvi-run-scg-taxonomy/))* 
- `-c` : contigs database.  
- `-T` : number of CPU threads.  

### bowtie2 *([Documentation](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml))*
- `--threads 8`: enables multithreading by using 8 CPU threads in parallel to speed up the alignment process. This significantly reduces computation time when aligning large metagenomic datasets.  
- `-x` : contig index path
- `-1/` and `-2/`: paired reads
- `-U` : unpaired reads - _The two files are separated by a comma (`,`) without a space._
- `-S` : output `.sam` file  
### Samtools *([Documentation](https://www.htslib.org/doc/samtools.html))*
- `view -F 4 -bS` :
    - `-F 4` : excludes unmapped reads ([flag 4 = read is unmapped](https://broadinstitute.github.io/picard/explain-flags.html)). Only reads that aligned to the reference are kept 

    - `-b` : outputs the result in BAM binary format instead of the default SAM format (text).

    - `-S` : tells `samtools` that the input is in SAM format (only required in older versions, but kept here for compatibility). 
- `merge` : merge paired and unpaired `.bam` files
- `-o` : sorted BAM file.  
- samtools index : Indexes BAM file (no explicit option). 

### anvi-init-bam *([Documentation](https://anvio.org/help/main/programs/anvi-init-bam/))*
⭢ Prepares **BAM** for `Anvi'o` compatibility. Indeed, this command index and sort the final **BAM** file. Indexing is the creation of a kind of "[**table of content**](https://anvio.org/help/main/artifacts/raw-bam-file/)" for the **BAM** file. This step creates a second file (`.bai`) that serves as an external table of contents, so that `Anvi'o` does not have to scan the entire **BAM** file during analysis.

### anvi-profile *([documentation](https://anvio.org/help/main/programs/anvi-profile/))* 
- `-i` : input BAM file.  
- `-c` : contigs database.  
- `-o` : output directory for the profile DB.  
- `--force-overwrite` : allows the command to replace (overwrite) previous results if any   
- `--sample-name` : sample identifier.  
- `-T` : number of CPU threads.  
- `-M` : min contig length

### anvi-merge *([documentation](https://anvio.org/help/main/programs/anvi-merge/))*
- Input : list of individual `PROFILE.db` files.  
- `-o` : output : a merged profile DB.  
- `-c` : contigs database.  

### anvi-import-collection *([documentation](https://anvio.org/help/main/programs/anvi-import-collection/))*
- `<collection.txt>` : collection file.  
- `-p` : profile DB.  
- `-c` : contigs database.  
- `-C` : collection name.  
- `--bins-info` : specifies a file attributing the origin/source of each MAG and a color (information file).

### anvi-estimate-scg-taxonomy *([documentation](https://anvio.org/help/main/programs/anvi-estimate-scg-taxonomy/))*
- `-c` : contigs database.  
- `-p` : profile DB.  
- `-C` : collection name.  
- `-o` : output file  

### anvi-summarize *([documentation](https://anvio.org/help/main/programs/anvi-summarize/))*
- `-p` : profile DB (or PAN.db for pangenome).  
- `-c` : contigs database.  
- `-o` : output summary directory.  
- `--init-gene-coverages` : generate detailed coverage and detection data for each gene.  
- `--report-aa-seqs-for-gene-calls` : export amino acid sequences.  
- `-C` : collection name.  
- `--force-overwrite` : allows the command to replace (overwrite) previous results if any

### anvi-gen-genomes-storage *([documentation](https://anvio.org/help/7/programs/anvi-gen-genomes-storage/))*
- `-i` : internal genomes file.  
- `-o` : output file (genomes-storage database).  

### anvi-pan-genome *([documentation](https://anvio.org/help/main/programs/anvi-pan-genome/))*
- `-g` : genomes-storage DB.  
- `--project-name` : project name.  
- `-o` : output directory.  
- `--num-threads` : number of CPU threads.  
- `--mcl-inflation` : Parameter for the Markov Cluster Algorithm (MCL) used to group genes into gene clusters (to control the granularity of the resulting clusters).  
- `--use-ncbi-blast` : use BLAST for similarity.  
- `--minbit` : Sets the minimum bit score ratio required to keep a BLAST hit between two genes.

### anvi-display-pan *([documentation](https://anvio.org/help/7/programs/anvi-display-pan/))*
- `-p` : PAN.db (pangenome).  
- `-g` : genomes-storage DB.  

### anvi-export-misc-data  *([documentation](https://anvio.org/help/main/programs/anvi-export-misc-data/))* 
- `-o` : output file.  
- `-p` : PAN.db or PROFILE.db.  
- `-t` : data type (layers, layer_orders or items).  

### anvi-import-misc-data *([documentation](https://anvio.org/help/main/programs/anvi-import-misc-data/))*  
- `<file>` : metadata file to import.  
- `-p` : database (PROFILE.db or PAN.db).  
- `-t` : target table (layers, layer_orders or items).  

### anvi-delete-misc-data *([documentation](https://anvio.org/help/7.1/programs/anvi-delete-misc-data/))* 
- `-p` : database (e.g : `PROFILE.db`).  
- `-t` : table to modify (layers, layer_orders or items).  
- `--list-available-keys` : list keys.  
- `--keys-to-remove` : remove specific metadata key.  

### anvi-interactive *([documentation](https://anvio.org/help/7/programs/anvi-interactive/))* 
- `-p` : profile DB.  
- `-c` : contigs DB.  
- `-C` : collection name.  

### anvi-meta-pan-genome *([documentation](https://anvio.org/help/7/programs/anvi-meta-pan-genome/))*
- `-p` : PAN.db (pangenome).  
- `-g` : genomes-storage DB.  
- `-i` : internal-genomes file.  

---

## Notes
- MAG headers had to be reformatted before `Anvi'o` could process them.
- A high MCL inflation (10) was used, producing very strict gene clusters.
- Adding misc-data layers (genus, coassembly groups, mean distribution) was necessary to make sense of the interactive pangenome.
- All visualizations required transferring data from **Thoth** to the **local WSL Ubuntu** session.
- Scripts use relative paths from `~/Stage_Copenhague`.  