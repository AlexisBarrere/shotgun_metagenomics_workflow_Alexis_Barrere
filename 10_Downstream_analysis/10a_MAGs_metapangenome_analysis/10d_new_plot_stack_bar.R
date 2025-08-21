# === Set the working directory ===
setwd("C:/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/barplots_3")

out_dir <- file.path(getwd(), "graphics")

# === Packages ===
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggnewscale)  # for the combined plot


# === Inputs ===
mean_cov <- read.delim("mean_coverage_per_Gbp.txt", sep = "\t", header = TRUE)
bins_summary <- read.delim("bins_summary.txt", sep = "\t", header = TRUE)

# === Map each MAG to its genus ===
taxa_tbl <- bins_summary %>%
  transmute(
    MAG = bins,
    genus = ifelse(is.na(t_genus) | t_genus == "", "Unknown", t_genus)
  )

# === Long format and join ===
long_df <- mean_cov %>%
  pivot_longer(
    cols = starts_with("sample_"),
    names_to = "sample_id",
    values_to = "mean_coverage_per_Gbp"
  ) %>%
  left_join(taxa_tbl, by = c("bins" = "MAG"))

# === Pre-compute totals per (sample, genus) for combined plot ===
sum_by_genus <- long_df %>%
  group_by(sample_id, genus) %>%
  summarise(total_genus = sum(mean_coverage_per_Gbp), .groups = "drop")

# === Create a PDF to store all plots ===
pdf("graphics/all_samples_mean_coverage_per_Gbp.pdf", width = 12, height = 8)  # set page size

# --- Page 1 : stacked by genus ---
p_genus <- ggplot(long_df, aes(x = sample_id, y = mean_coverage_per_Gbp, fill = genus)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  labs(
    title = "Mean coverage per sequenced Gbp (stacked by genus)",
    x = "Sample",
    y = "Mean coverage per sequenced Gbp"
  ) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    plot.title = element_text(hjust = 0.5)
  )
print(p_genus)

# --- Page 2 : stacked by MAG ---
p_MAG <- ggplot(long_df, aes(x = sample_id, y = mean_coverage_per_Gbp, fill = bins)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  labs(
    title = "Mean coverage per sequenced Gbp (stacked by MAGs)",
    x = "Sample",
    y = "Mean coverage per sequenced Gbp"
  ) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    plot.title = element_text(hjust = 0.5)
  )
print(p_MAG)

# Close the PDF
dev.off()

message("[INFO] PDF saved at: ", file.path(out_dir, "all_samples_mean_coverage_per_Gbp.pdf"))