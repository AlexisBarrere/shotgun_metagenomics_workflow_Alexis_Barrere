# === Set the working directory ===
setwd("C:/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/barplots_3")

# === Inputs ===

# --- Import the 3 files ---
bins_percent_recruitment <- read.delim("bins_percent_recruitment.txt", sep = "\t", header = TRUE)

mean_coverage_per_Gbp <- read.delim("mean_coverage_per_Gbp.txt", sep = "\t", header = TRUE)

bins_percent_recruitment$X__splits_not_binned__ <- NULL

coassembly_groups <- read.delim("coassembly_groups.tsv", sep = "\t", header = TRUE)

# === Array dimensions ===
dim(bins_percent_recruitment)
dim(mean_coverage_per_Gbp)
dim(coassembly_groups)

# === Create a metadata table linking each sample_xx to : ===
# - Time (T3, T6, T7)
# - Fertilizer (N1K1, N1P2K2)
# - Group (coassembly)

# 1) Create an empty table 
metadata <- data.frame(sample_id = character(),
                       time = character(),
                       fertilizer = character(),
                       stringsAsFactors = FALSE) # keep text columns as character (and not factors)

# 2) Loop through each row of the coassembly_groups array :
for (i in 1:nrow(coassembly_groups)) {
  group <- coassembly_groups$GROUP[i] # ex : if i=1, group = T3_N1K1
  time <- strsplit(group, "_") [[1]] [1] # ex : if i=1, time = T3 
  fert <- strsplit(group, "_") [[1]] [2] # ex : if i=1, fert = N1K1
  
  # 2-a) Retrieve sample numbers
  samples <- unlist(coassembly_groups[i, 2:5]) # unlist() --> transforms the sub-array into a simple vector (example: 17 19 21 23)
  # ex : samples = c(17, 19, 21, 23) for i=1.
  
  # 2-b) Add to the metadata table
  metadata <- rbind(metadata, data.frame(sample_id = sprintf("sample_%02d", samples),
                                         # ex : sprintf("sample_%02d", c(17, 19, 21, 23))
                                         # [1] "sample_17" "sample_19" "sample_21" "sample_23"
                                         time = time,
                                         fertilizer = fert,
                                         stringsAsFactors = FALSE))
  # rbind = row bind, adds the rows of the mini data frame after the rows already present in metadata
}

# === Result ===
print(metadata)

write.table(metadata,
            file = "metadata.tsv",   # file name
            sep = "\t",              # tabulation as separator
            row.names = FALSE,       # Don't write row numbers 
            quote = FALSE)           # Don't put quotation marks around the text

