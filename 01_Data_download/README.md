# Step 1 - Raw Data Download 
This step describe how raw paired-end FASTQ files were downloaded using the CSV file provided by **Zymo Research**, the company that performed the Shotgun Metagenomic Sequencing. 

---

## Scripts
- [`download_reads.sh`](download_reads.sh) : final script used to download and extract data for all 24 samples. 

> *A test script [`test_wget.sh`](test_scripts/test_wget.sh) was used during the early phase to download only the first two samples and extract 1000 reads. It is kept in the `test_script`folder for reference.*

- [calculate_mean_min_max_raw_reads.sh](calculate_mean_min_max_raw_reads.sh) : script used to calculate the total number of reads, the average per sample, and the minimum and maximum number of reads found in a sample

---

## Inputs

- `zr11927_Rawdatalinks_250506.csv`: contains _**sample IDs**_, _**customer labels**_ and corresponding _**download URLs**_ (provided by the **Zymo Research** company)
  -  **Format** : sample_id , customer_label , Read1 Download , Read2 Download

---
## Outputs 
All outputs from the [`download_reads.sh`](download_reads.sh) script can be found on the **thoth server** in the following folder : `/home/alexis/Stage_Copenhague/raw_data_full/`.

We can find : 
- One folder per sample : `raw_data_full/sample_xx/`
- Each folder contains two files : 
  - `zr11927_xx_read1.fastq`
  - `zr11927_xx_read2.fastq`  

> *All outputs from the [`test_wget.sh`](test_scripts/test_wget.sh) script can be found on the **thoth server** in the following folder : `/home/alexis/Stage_Copenhague/raw_data_test/`.*

The output of the script
[calculate_mean_min_max_raw_reads.sh](calculate_mean_min_max_raw_reads.sh) is available on the Thoth server in : `~/Stage_Copenhague/statistics/mean_min_max_reads.txt`

You can also view this file in this repository : [mean_min_max_reads.txt](mean_min_max_reads.txt)


---  
## Execution 
The [`download_reads.sh`](download_reads.sh) script was run on the server by typing the following command :

```bash
download_reads.sh
```

Then I executed the [calculate_mean_min_max_raw_reads.sh](calculate_mean_min_max_raw_reads.sh) script to get some basic statistics on reads.

---
## Notes
- Files were downloaded using `wget`, unzipped with `gunzip`, and organized automatically by sample.
- All scripts use relative paths anchored to `~/Stage_Copenhague`.
