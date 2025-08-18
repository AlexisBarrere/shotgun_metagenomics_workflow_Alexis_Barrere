# Step 5 - Binning & Bin Refinement
This step aimed to group assembled contigs into **bins**, each representing a draft genome reconstructed from metagenomic data.  
Binning was carried out using the `binning` and `bin_refinement` modules from the `MetaWRAP` pipeline, which integrates the tools `MetaBAT2`, `MaxBin2`, and `CONCOCT`.

This procedure was applied :
- To the **24 individual assemblies** using their own paired-end reads.
- To **6 co-assemblies**, each combining 4 samples, using the paired reads from all corresponding samples.

The goal was **not** to isolate high-quality MAGs at this stage, but rather to **retain all possible bins**, regardless of quality and redundancy.  
Final selection and curation of MAGs was intended to be done later with `Anvi'o`, after visual inspection and additional filtering.  
To that end, the `bin_refinement` module was run with **permissive thresholds** :  
- `-c 1` (minimum completeness of 1%)  
- `-x 1000` (maximum contamination of 1000%)  
ensuring that all bins were preserved regardless of their quality or redundancy.

The refinement module is designed to automatically compare and consolidate bins detected by multiple tools. If the same bin is recovered by multiple algorithms (e.g., `MetaBAT2` and `MaxBin2`), MetaWRAP selects the **best version** according to CheckM-estimated completeness and contamination.  
This makes the refinement step essential to obtain a non-redundant bin set optimized according to the user-defined `-c` and `-x` thresholds.

> ⚠️ The installation procedure for `MetaWRAP`, as well as the required **CheckM database** (needed for the `bin_refinement` module), is described step-by-step in the [`installation.md`](../installation.md) file of this repository.

---

## Environment & Software Versions

All commands were executed on the Thoth server running : Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via a Conda environment defined in : [`envs/metawrap_env.yml`](../envs/metawrap_env.yml)

| Tool       | Version    | Installation method    |
|------------|------------|------------------------|
| MetaWRAP   | 1.3.2      | Conda (`bioconda`)     |
| CONCOCT    | 1.0.0      | Included in MetaWRAP   |
| MetaBAT2   | 2.12.1     | Included in MetaWRAP   |
| MaxBin2    | 2.2.6      | Included in MetaWRAP   |

### Environment creation
To recreate the environments from the root of the repository : 
```bash
conda env create -f envs/metawrap_env.yml
conda activate metawrap_env
```
> ⚠️ Some steps required limiting OpenBLAS to a single thread (OPENBLAS_NUM_THREADS=1) to avoid CONCOCT crashes during binning.

---
## Scripts
### (i) Individual assemblies
Binning was performed on each of the 24 samples individually using the following script :

-  [binning_all_samples.sh](binning_single_assemblies/binning_all_samples.sh)  
⭢ Runs `MetaWRAP`'s `binning` module on all 24 samples using `MetaBAT2` and `MaxBin2`.
  
Additionally :

- [binning_sample_01.sh](binning_single_assemblies/binning_sample_01.sh)  
⭢ Used for initial testing on sample 01.

- [binning_all_samples_CONCOCT.sh](binning_single_assemblies/binning_all_samples_CONCOCT.sh)  
⭢ Specific run restricted to `CONCOCT` only (due to instability when running all binners at once in some cases)

### (ii) Co-assemblies
Due to repeated crashes during parallel execution of multiple binning runs, each **co-assembly group** was processed using separate scripts for each binning tool combination :

- **MaxBin2 + MetaBAT2** :  
  - [T3_N1K1_maxbin2_metabat2.sh](binning_coassemblies/maxbin2_metabat2/T3_N1K1_maxbin2_metabat2.sh)  
  - [T3_N1P2K2_maxbin2_metabat2.sh](binning_coassemblies/maxbin2_metabat2/T3_N1P2K2_maxbin2_metabat2.sh)   
  - [T6_N1K1_maxbin2_metabat2.sh](binning_coassemblies/maxbin2_metabat2/T6_N1K1_maxbin2_metabat2.sh)   
  - [T6_N1P2K2_maxbin2_metabat2.sh](binning_coassemblies/maxbin2_metabat2/T6_N1P2K2_maxbin2_metabat2.sh)   
  - [T7_N1K1_maxbin2_metabat2.sh](binning_coassemblies/maxbin2_metabat2/T7_N1K1_maxbin2_metabat2.sh)   
  - [T7_N1P2K2_maxbin2_metabat2.sh](binning_coassemblies/maxbin2_metabat2/T7_N1P2K2_maxbin2_metabat2.sh) 

- **CONCOCT only** :
  - [T3_N1K1_concoct.sh](binning_coassemblies/concoct/T3_N1K1_concoct.sh)
  - [T3_N1P2K2_concoct.sh](binning_coassemblies/concoct/T3_N1P2K2_concoct.sh)
  - [T6_N1K1_concoct.sh](binning_coassemblies/concoct/T6_N1K1_concoct.sh)
  - [T6_N1P2K2_concoct.sh](binning_coassemblies/concoct/T6_N1P2K2_concoct.sh)
  - [T7_N1K1_concoct.sh](binning_coassemblies/concoct/T7_N1K1_concoct.sh)
  - [T7_N1P2K2_concoct.sh](binning_coassemblies/concoct/T7_N1P2K2_concoct.sh)

> ⚠️ These scripts were executed sequentially to avoid memory errors caused by concurrent `CONCOCT` jobs.

### (iii) Bin refinement 
`MetaWRAP`'s `bin_refinement` module was used to consolidate bins from the three algorithms (when available) using the scripts :
- [bin_refinement_sample_01.sh](bin_refinement/bin_refinement_sample_01.sh)  
⭢ Initial test on sample 01

- [bin_refinement_all_samples.sh](bin_refinement/bin_refinement_all_samples.sh)  
⭢ Applies refinement to all individual samples

- [bin_refinement_coassemblies.sh](bin_refinement/bin_refinement_coassemblies.sh)  
⭢ Used to refine bins for each co-assembly group

### (iv) Delete temporary files
- [delete_temporary_files.sh](delete_temporary_files.sh)  
⭢ Script used to delete the unzipped read pairs files required for binning with `MetaWRAP`

---
## Inputs
The binning step relies on :
- **Contig files** from individual or co-assemblies :  
  - Located in : `~/Stage_Copenhague/assembly/sample_xx/` or `~/Stage_Copenhague/assembly/$GROUP/`
  - File pattern (individual) : `sample_${i}_contigs_fixed.fa`
  - File pattern (coassemblies) : `${GROUP}_contigs_fixed.fa`

- **Cleaned and paired reads** (after trimming and decontamination) :  
  - Located in: `~/Stage_Copenhague/decontamination/sample_$i/contaminant_free` 
  - Required files for each sample:  
    - `sample_${i}_contaminant_free_read1_paired.fq.gz` ⭢ which is decompressed using the following format (required by `MetaWRAP`) : `sample_${i}_1.fastq` 
    - `sample_${i}_contaminant_free_read2_paired.fq.gz` ⭢ which is decompressed using the following format (required by `MetaWRAP`) : `sample_${i}_2.fastq`

> The input paired reads are used by `MetaWRAP` to compute coverage profiles for each contig, which are required by the binning tools.  
> `MaxBin2`, `MetaBAT2`, and `CONCOCT` all use a combination of nucleotide composition (e.g., tetranucleotide frequencies) and coverage information to cluster contigs into bins representing potential genomes.

---
## Outputs
### Binning
The structure of the binning output varies slightly depending on whether binning was performed on a **single sample** or on a **coassembly group**.  
but the folder architecture remains consistent for each case.  

All outputs for **single assemblies** are stored under :  
- `~/Stage_Copenhague/binning/sample_${i}/` 
  - `metabat2_bins/` ⭢ bins generated by MetaBAT2 (files: `bin.1.fa`, `bin.2.fa`, `bin.unbinned.fa`, etc.)
  - `maxbin2_bins/` ⭢ bins generated by MaxBin2 (files: `bin.1.fa`, `bin.2.fa`, etc)
  - `concoct_bins/` ⭢ bins generated by CONCOCT (files: `bin.1.fa`, `bin.2.fa`, `unbinned.fa`, etc)
  - `work_files` ⭢ intermediate files used by `MetaWRAP` for read mapping, coverage estimation, and tool-specific formats (e.g. `.bam`, `.bed`, `.fa`, `.txt`, `concoct_out/`, `maxbin2_out/`)  


All outputs for **co-assemblies** are stored under : 
- `~/Stage_Copenhague/binning/${GROUP}/` (for `Metabat2` and `Maxbin2`)
  - `${GROUP}/maxbin2_bins/` ⭢ MaxBin2 bins (`bin.1.fa`, `bin.2.fa`, etc.)
  - `${GROUP}/metabat2_bins/` ⭢ MetaBAT2 bins (`bin.1.fa`, `bin.2.fa`, `bin.unbinned.fa`, etc.)
  - `work_files` ⭢ intermediate files generated during `Metabat2` and `Maxbin2` executions

- `~/Stage_Copenhague/binning/${GROUP}_concoct/` (for `CONCOCT`)
  - `concoct_bins/` ⭢ CONCOCT bins (`bin.1.fa`, `bin.2.fa`, `unbinned.fa`, etc.)
  - `work_files/` ⭢ intermediate files generated during `CONCOCT` execution

### Bin_refinement module
The bin_refinement module creates a `bin_refinement/` folder in `~/Stage_Copenhague/binning/sample_${i}/` for single assemblies, and in `~/Stage_Copenhague/binning/${GROUP}/` for co-assemblies.

Each `bin_refinement/` directory contains :
- `metawrap_${c}_${x}_bins/` ⭢ final consolidated bins generated by `MetaWRAP` based on specified thresholds (`-c` for completion, `-x` for contamination)
- `metawrap_${c}_${x}_bins.stats` ⭢ summary statistics containing usefull information about each bin (completeness, contamination, GC content, lineage, N50,  bin size and)
- `metawrap_${c}_${x}_bins.contigs` ⭢ list of contigs for each bin

As well as the original input bin sets used for refinement :
- `concoct_bins/`, `concoct_bins.stats`, `concoct_bins.contigs`
- `maxbin2_bins/`, `maxbin2_bins.stats`, `maxbin2_bins.contigs`
- `metabat2_bins/`, `metabat2_bins.stats`, `metabat2_bins.contigs`

And :
- `figures/` ⭢ comparison plots showing the completeness and contamination ranking of bins produced by each tool and by `MetaWRAP` refinement.

> The directory `metawrap_${c}_${x}_bins/` contains the refined bins used for further manual curation and filtering with `Anvi'o`.

---
## Execution & encountered issues
The binning process was performed using the `metawrap binning` module, followed by `metawrap bin_refinement`.  
Due to several issues encountered during execution, binning was divided into distinct script categories.

### Execution by sample or coassembly
The binning workflow was executed in two main strategies: **individual sample binning** and **group-wise co-assembly binning**, both followed by refinement using the `bin_refinement` module.

For **individual assemblies**, the binning was first tested on `sample_01` ([binning_sample_01.sh](binning_single_assemblies/binning_sample_01.sh)) to validate input formatting, tool behavior, and resource usage. Once validated, binning for all 24 samples was performed sequentially using [binning_all_samples.sh](binning_single_assemblies/binning_all_samples.sh). Refinement of these bins was then executed using [bin_refinement_all_samples.sh](bin_refinement/bin_refinement_all_samples.sh).

For **coassemblies**, the execution was more fragmented due to tool-specific issues :
- `MetaBAT2` and `MaxBin2` were run together in dedicated scripts per group (e.g., [T3_N1K1_maxbin2_metabat2.sh](binning_coassemblies/maxbin2_metabat2/T3_N1K1_maxbin2_metabat2.sh) ).
- `CONCOCT`, however, showed recurring execution failures when run alongside other tools, especially on large or complex coassemblies.  
  ⭢ To circumvent this, it was run in **independent scripts** (e.g., [T3_N1K1_concoct.sh](binning_coassemblies/concoct/T3_N1K1_concoct.sh)), isolating the `CONCOCT` step per group.
- All coassembly groups were then processed via [bin_refinement_coassemblies.sh](bin_refinement/bin_refinement_coassemblies.sh) to consolidate bins.

Due to performance instability when running all binning tools in parallel, **scripts were designed to execute sequentially**, ensuring consistent output and reducing the risk of silent failures or partial outputs.

### Encountered issues
#### Input read format required by `MetaWRAP`
`MetaWRAP` requires input reads to be decompressed and named in a specific format :   
`sample_${i}_1.fastq` and `sample_${i}_2.fastq`.  
To meet this requirement, all paired-end cleaned reads were decompressed and renamed accordingly before binning.  

Once the binning process was complete, these temporary files were removed using the script [delete_temporary_files.sh](delete_temporary_files.sh),  
to reduce storage usage.

#### `CONCOCT` parallelism and thread conflicts
During testing, `CONCOCT` caused segmentation faults when multiple samples or groups were processed in parallel.  
This behavior was linked to conflicts in OpenBLAS thread handling when launching the Gaussian clustering (VBGMM) step.  

To fix this, the following environment variable was set before launching the `CONCOCT` step (according to the solutions found on forums) :
```bash
export OPENBLAS_NUM_THREADS=1
```
This setting ensures that the clustering step does not over-allocate CPU threads, improving stability and reproducibility.
It was systematically applied in both individual assemblies and coassemblies scripts prior to running MetaWRAP with `CONCOCT`.

#### `CONCOCT` failure on complex coassemblies (T3_N1P2K2 and T7_N1P2K2)
In these two groups, `CONCOCT` consistently failed at the clustering stage (VBGMM), freezing without writing output (e.g. "`clustering_gt1000_noCut.csv missing`") even with the parameter "export OPENBLAS_NUM_THREADS=1" applied.

This issue likely stemmed from :

- An excessive number of non-discriminant contigs
- A too high number of clusters (default : 400)

#### Solution applied :
The `-l 2500` parameter was added to the metawrap binning command, filtering out contigs shorter than 2.5 kb.
This reduction in data complexity allowed `CONCOCT` to run normally with the default clustering settings, while remaining consistent with other binning runs.

---
## Parameters
*Documentation : [MetaWRAP Documentation](https://github.com/bxlab/metaWRAP)*  

The following parameters were used in the binning pipeline :
- `MetaWRAP` **binning**
  - `-t 8` for all samples and coassemblies, except `sample_01` where `-t 24` was used for testing
  - `-a` for specifying the contig file
  - `--metabat2` and `--maxbin2` used for all samples  
  - `--concoct` used separately due to stability issues
  - `-l 2500` added only for coassemblies `T3_N1P2K2` and `T7_N1P2K2` to improve `CONCOCT` stability (filters contigs < 2.5 kb)

- `MetaWRAP` **bin_refinement**
  - `-c 1` ⭢ include bins with any completion percentage (≥ 1)
  - `-x 1000` ⭢ include bins with any contamination level (≤ 1000)
  > This choice was made deliberately to retain all bins, regardless of quality, and filter them later in `Anvi'o`.

  --- 
  ## Notes 
- Some scripts use `GNU Parallel` to process multiple samples or groups simultaneously.  
- Due to reproducibility issues with `CONCOCT` in parallel mode, all `CONCOCT` steps were isolated in dedicated scripts and launched sequentially.
- Binning was applied to both individual assemblies and coassemblies to allow comparisons and to maximize MAG recovery.
- The permissive parameters used during refinement (`-c 1`, `-x 1000`) were specifically chosen to keep all bins, with quality assessment deferred to manual curation steps.
- Scripts use relative paths from `~/Stage_Copenhague`.
