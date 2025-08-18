# Step 2a - Trimming
This step involved cleaning raw reads by removing adapters, polyG tails, low-quality bases, and short sequences. The trimming was performed using a two-step approach: first with `Trimmomatic` for adapter and quality trimming, then with `Fastp` for polyG trimming and additional filtering.

---

## Environment & Software Versions

All commands were executed on the **thoth server** running :  
`Ubuntu 22.04.5 LTS` (GNU/Linux 5.15.0-126-generic x86_64)

The tools used during this step are managed via a Conda environment defined in [`envs/trim_env.yml`](../../envs/trim_env.yml)

### Software versions (as per `trim_env.yml`) :

| Tool         | Version         | Installation method    |
|--------------|------------------|-------------------------|
| Trimmomatic  | 0.39             | Conda (`bioconda`)     |
| Fastp        | 0.23.4           | Conda (`bioconda`)     |

### Environment creation
To recreate the environment from the root of the repository : 
```bash
conda env create -f envs/trim_env.yml
conda activate trim_env
```
---

## Scripts 
- [`rename_samples_01_to_09.sh`](rename_samples_01_to_09.sh)  
⭢ Script used to rename sample folders 1 to 9 in the `raw_data_full/` folder, adding a 0 in front of the numbers so that they are sorted in order.

- [`run_trim_fastp_sample01.sh`](run_trim_fastp_sample01.sh)  
⭢ Script used to test different `Trimmomatic` and `Fastp` parameters on sample 01, in order to find the best trimming parameters.

- [`run_trim_fastp_sample02_to_24.sh`](run_trim_fastp_sample02_to_24.sh)
⭢ Script used to perform trimming (`Trimmomatic` and `FastP`) on samples 02 to 24, after finding the correct parameters on sample 01.

- [`rename_samples_in_clean_reads.sh`](rename_samples_in_clean_reads.sh)
⭢ Script used to add the sample name to the final output files (obtained after FastP).  

- [`adapters_removal_unpaired_reads.sh`](adapters_removal_unpaired_reads.sh)  
⭢ Script used to improve the trimming of adapters (with `Trimmomatic`) on unpaired read files 1 & 2 generated after the first trimming scripts.

All scripts are available in this folder for reproducibility.

--- 

## Inputs

### Read files
- Paired-end reads located in : `Stage_Copenhague/raw_data_full/sample_xx/`

Each folder contains : 
- `zr11927_xx_read1.fastq`
- `zr11927_xx_read2.fastq`

### Adapter sequences
Adapter sequences for Nextera libraries (Nextera Transposase Adapters) were downloaded from the [official Illumina website](https://support-docs.illumina.com/SHARE/AdapterSequences/Content/SHARE/AdapterSeq/Nextera/SequencesNextera_Illumina.htm)

The sequences were saved into :  
`~/Stage_Copenhague/trimming/adapters/NexteraPE.fa`  

The file [`NexteraPE.fa`](NexteraPE.fa) contains the following entries :
- `PrefixPE/1` and `PrefixPE/2` correspond to Nextera adapter sequences for read 1 and read 2, respectively, in a standard paired-end setup.
- `Nextera_generic` contains both adapter sequences, one per line. It is used by Trimmomatic to detect and remove adapters that may appear in **either orientation**, which is particularly useful for **unpaired reads** or reads with **uncertain orientation**.

This file was passed to Trimmomatic using the `ILLUMINACLIP` module.

--- 

## Outputs 
The first trimmed reads were saved in :
`~/Stage_Copenhague/trimming/clean_reads/sample_xx/after_fastp/`

And the **final** trimmed reads were saved in : 
`~/Stage_Copenhague/trimming/clean_reads_final/sample_xx/after_fastp/`

Each folder contains :
| File name pattern | Description |
|--------------------|-------------|
| `sample_xx_read1_paired_cleaned.fq.gz` | Forward read, paired |
| `sample_xx_read2_paired_cleaned.fq.gz` | Reverse read, paired |
| `sample_xx_read1_unpaired_cleaned.fq.gz` | Forward read, unpaired |
| `sample_xx_read2_unpaired_cleaned.fq.gz` | Reverse read, unpaired |


--- 

## Execution
- Firstly, sample folders 1 to 9 (in `Stage_Copenhague/raw_data_full/`) were renamed by adding a 0 in front (01 to 09) :
```bash
rename_samples_01_to_09.sh
```

- Secondly, several parameters were tested on sample 01 (the results were verified using FastQC, see the `c_fastqc_and_multiqc` folder) :
```bash
run_trim_fastp_sample01.sh
```
At the end of the tests on sample 01, the "_sixth_test" part that was present in the folder names of sample 01 has been manually removed.

- Thirdly, trimming of samples 02 to 24 was performed using the same parameters found on sample 01 :
```bash
run_trim_fastp_sample02_to_24.sh
```
The trimming was parallelized using background jobs (`&`) and `wait`, processing 4 samples at a time.

- Fourthly, the read files generated (both after using `Trimmomatic` and after using `Fastp`) in the format `*_.fq.gz` were renamed by adding the sample name in front (so that they can be distinguished in the MultiQC report) : 
```bash
rename_samples_in_clean_reads.sh
```
**Example** : we went from _**read1_paired_cleaned.fq.gz**_ to _**sample_01_read1_paired_cleaned.fq.gz**_

- Finally, a new output folder containing the reads after trimming was created (`~/Stage_Copenhague/trimming/clean_reads_final`) in which all trimmed paired reads were copied (without modification), then the adapters of the **unpaired read files** were trimmed again using `Trimmomatic`, this time in simple/standard mode (not palindrome mode) and with a few parameters changed (see section _**Trimming parameters**_). This allowed a few more adapters to be removed from the unpaired read files : 
```bash
adapters_removal_unpaired_reads.sh
```
---

## Parameters
This trimming step was performed using a combination of `Trimmomatic` (for adapter and quality trimming) and `Fastp` (for polyG removal).

### Trimmomatic
*Documentation : [Trimmomatic Manual : V0.32](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf)*

#### 1. Initial trimming on paired-end reads
All raw paired reads were trimmed using the following `Trimmomatic PE` command:
```bash
trimmomatic PE -threads 4 -phred33 \
  $IN_DIR/zr11927_1_read1.fastq $IN_DIR/zr11927_1_read2.fastq \
  $OUT_DIR/read1_paired.fq.gz $OUT_DIR/read1_unpaired.fq.gz \
  $OUT_DIR/read2_paired.fq.gz $OUT_DIR/read2_unpaired.fq.gz \
  ILLUMINACLIP:$ADAPTERS:3:15:5:1:true \
  LEADING:20 \
  TRAILING:20 \
  SLIDINGWINDOW:4:25 \
  MINLEN:80
```
**Explanation** :
- `ILLUMINACLIP:$ADAPTERS:3:15:5:1:true`  
  This option removes adapter sequences with the following thresholds:

  - `3` ⭢ **seedMismatches parameter** : Specifies the maximum mismatch count which will still allow a full match to be performed. Here Allow up to 3 mismatches in the 16-base seed region used to align the adapter.

  - `15`⭢ **palindrome clip threshold** : Minimum alignment score to clip adapters in **palindrome mode**, which is useful for overlapping paired-end reads (e.g., short inserts where read1 and read2 contain adapter fragments from opposite ends).

  - `5`⭢ **simple clip threshold** : Minimum alignment score to clip adapters in **simple mode**, i.e., a standard forward alignment within the read.

  - `1`⭢ **minAdapterLength parameter**  : Minimum adapter length required to trigger a clip.
  
  - `true`⭢ **`keepBothReads` parameter** : After read-though has been detected by palindrome mode, and the
adapter sequence removed, the reverse read contains the same sequence information as the forward read, albeit in reverse complement. For this reason, the default behaviour is to entirely drop the reverse read. By specifying "true" for this parameter, the reverse read will also be retained, which may be useful e.g. if the downstream tools cannot handle a combination of paired and unpaired reads. 

These thresholds were chosen to allow robust adapter detection while avoiding over-trimming.

- `LEADING:20`, `TRAILING:20`  
  ⭢ Remove low-quality bases from the start and end of each read if their Phred score is below 20.
- `SLIDINGWINDOW:4:25`  
  ⭢ Scan the read with a sliding window of 4 bases; trim the read when the average quality in the window drops below 25.
- `MINLEN:80`  
  ⭢ Discard reads that fall below 80 bp after all trimming operations.

#### 2. Adapter re-trimming on unpaired reads
After the initial trimming, unpaired reads were processed again to remove more remaining adapter sequences using "Trimmomatic SE" with stricter matching parameters:
```bash
trimmomatic SE -threads 4 -phred33 \
  $IN_DIR/${SAMPLE_ID}_read1_unpaired_cleaned.fq.gz \
  $OUT_DIR/${SAMPLE_ID}_read1_unpaired_cleaned.fq.gz \
  ILLUMINACLIP:$ADAPTERS:5:30:2 \
  MINLEN:80
```
**Differences from initial trimming** :
- `5` ⭢ More permissive (2 additional mismatches allowed)
- `30` ⭢ More stringent adapter alignment (higher score required).
- `2` ⭢ More permissive clipping threshold in simple mode (triggered by shorter matches).
- No `LEADING`, `TRAILING`, or `SLIDINGWINDOW` filters applied in this step.
- Same minimum read length: `80`.

---

### Fastp
Fastp was used after Trimmomatic to clean polyG tails, enforce minimum read lengths, and generate QC reports.

*Documentation : [OpenGene - Fastp](https://github.com/OpenGene/fastp/blob/master/README.md)*

#### Paired-end reads :
```bash
fastp \
  --in1 "$TRIMMOMATIC_OUT_DIR"/read1_paired.fq.gz \
  --in2 "$TRIMMOMATIC_OUT_DIR"/read2_paired.fq.gz \
  --out1 "$FASTP_OUT_DIR"/read1_paired_cleaned.fq.gz \
  --out2 "$FASTP_OUT_DIR"/read2_paired_cleaned.fq.gz \
  --trim_poly_g \
  --length_required 80 \
  --thread 4 \
  --html "$FASTP_REPORT_DIR"/fastp_paired.html \
  --json "$FASTP_REPORT_DIR"/fastp_paired.json
```

#### Unpaired reads:
For read 1 : 
```bash
fastp \
  --in1 "$TRIMMOMATIC_OUT_DIR"/read1_unpaired.fq.gz \
  --out1 "$FASTP_OUT_DIR"/read1_unpaired_cleaned.fq.gz \
  --trim_poly_g \
  --length_required 80 \
  --thread 2 \
  --html "$FASTP_REPORT_DIR"/fastp_unpaired_read1.html \
  --json "$FASTP_REPORT_DIR"/fastp_unpaired_read1.json
```

For read 2 : 
```bash
fastp \
	--in1 "$TRIMMOMATIC_OUT_DIR"/read2_unpaired.fq.gz \
	--out1 "$FASTP_OUT_DIR"/read2_unpaired_cleaned.fq.gz \
 	--trim_poly_g \
	--length_required 80 \
  	--thread 2 \
  	--html "$FASTP_REPORT_DIR"/fastp_unpaired_read2.html \
  	--json "$FASTP_REPORT_DIR"/fastp_unpaired_read2.json
```
**Key options**:
- `--trim_poly_g` ⭢ Removes polyG/polyX tails, commonly seen with NovaSeq instruments.
- `--length_required 80` ⭢ Discards any reads shorter than 80 bp.
- `--thread` ⭢ Number of threads used for faster processing.
- `--html` and `--json` ⭢ Output quality reports.

---

All parameters were optimized by trial runs on sample 01 and validated via FastQC and MultiQC quality metrics.

---
## Notes
- All scripts use relative paths anchored to `~/Stage_Copenhague`.


