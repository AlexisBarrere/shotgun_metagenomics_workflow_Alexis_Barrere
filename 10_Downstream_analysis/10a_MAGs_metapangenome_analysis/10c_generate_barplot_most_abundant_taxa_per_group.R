# === Set the working directory ===
setwd("C:/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/barplots_3")

out_dir <- file.path(getwd(), "graphics")

# === Libraries ===
# install.packages(c("readr","dplyr","tidyr","ggplot2"))

library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# === Inputs ===

# --- Import the files ---
percent_wide <- read.delim("bins_percent_recruitment.txt", sep = "\t", header = TRUE)
percent_wide$X__splits_not_binned__ <- NULL

metadata <- read.delim("metadata.tsv", sep = "\t", header = TRUE)

bins_summary <- read.delim("bins_summary.txt", sep = "\t", header = TRUE) 

# === 1) Read bins_percent_recruitment and reshape to long  ===
# Convert to long format: one row per (sample, MAG, percent)
percent_long <- percent_wide |>
  pivot_longer(
    cols = -samples,
    names_to = "MAG",
    values_to = "percent_recruitment"
  )

# ---- 2) Attach groups in metadata ----
# metadata must have: sample_id, time (T3/T6/T7), fertilizer (N1K1/N1P2K2)

# Build "group" (e.g., "T3_N1K1") and keep only what we need to join
meta_groups <- metadata |>
  mutate(group = paste(time, fertilizer, sep = "_")) |>
  select(samples = sample_id, group)

# Join groups onto the long % table
percent_long <- percent_long |>
  left_join(meta_groups, by = "samples")

# ---- 3) Read bins_summary to get genus per MAG ----
# We expect "bins" (MAG ID) and "t_genus" (13th column).
taxa_tbl <- bins_summary |>
  transmute(
    MAG   = .data$bins,         # MAG id matches the columns from bins_percent_recruitment
    genus = .data$t_genus       # genus annotation (may be empty)
  ) |>
  mutate(genus = ifelse(is.na(genus) | genus == "", "Unknown", genus))

# Add genus info
percent_long <- percent_long |>
  left_join(taxa_tbl, by = "MAG")

# ---- 4) Compute mean percent per (group, MAG, genus) ----
group_means <- percent_long |>
  group_by(group, MAG, genus) |>
  summarise(mean_percent = mean(percent_recruitment, na.rm = TRUE), .groups = "drop")

# ---- 5) Plot: one barplot per group ----
make_plot_for_group <- function(df_group) {
  df_group <- df_group |>
    arrange(mean_percent) |>
    mutate(MAG = factor(MAG, levels = MAG))  # lock the order
  
  p <- ggplot(df_group, aes(x = MAG, y = mean_percent, fill = genus)) +
    geom_col() +
    labs(
      title = unique(df_group$group),
      subtitle = "Mean % recruitment based on 4 samples per group",
      x = "MAG",
      y = "Mean MAG percent recruitment (%)",
      fill = "Genus"
    ) +
    theme_bw(base_size = 12) +
    theme(
      axis.text.x = element_text(angle = 60, hjust = 1),
      panel.grid.minor = element_blank()
    )
  
  p
}

# ---- Save all plots into one PDF (1 group per page) ----
pdf(file.path(out_dir, "barplots_bins_percent_by_group.pdf"), width = 10, height = 6)

groups <- sort(unique(group_means$group))
for (g in groups) {
  df_g <- group_means |> filter(group == g)
  p <- make_plot_for_group(df_g)
  print(p)  # Each print() sends the plot to the next page in the PDF
}

dev.off()

message("[INFO] PDF saved at: ", file.path(out_dir, "barplots_bins_percent_by_group.pdf"))
