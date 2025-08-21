# === Set the working directory ===
setwd("C:/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/barplots_3")

out_dir <- file.path(getwd(), "graphics")


# === Packages ===
library(dplyr)
library(tidyr)
library(ggplot2)
library(paletteer)   # pour palettes custom

# === Inputs ===
mean_cov     <- read.delim("mean_coverage_per_Gbp.txt", sep = "\t", header = TRUE)
bins_summary <- read.delim("bins_summary.txt",          sep = "\t", header = TRUE)
metadata     <- read.delim("metadata.tsv",               sep = "\t", header = TRUE)

# === Map each MAG to its genus ===
taxa_tbl <- bins_summary %>%
  transmute(
    MAG = bins,
    genus = ifelse(is.na(t_genus) | t_genus == "", "Unknown", t_genus)
  )

# === Build 'group' (time + fertilizer) and ordering of samples ===
meta_ord <- metadata %>%
  mutate(
    group = paste(time, fertilizer),
    sample_num = as.integer(sub("^sample_", "", sample_id))
  ) %>%
  arrange(time, fertilizer, sample_num)

sample_levels <- meta_ord$sample_id
sample_labels <- setNames(meta_ord$sample_num, meta_ord$sample_id)

# === Long format and join ===
long_df <- mean_cov %>%
  pivot_longer(
    cols = starts_with("sample_"),
    names_to  = "sample_id",
    values_to = "mean_coverage_per_Gbp"
  ) %>%
  left_join(taxa_tbl,   by = c("bins" = "MAG")) %>%
  left_join(meta_ord %>% select(sample_id, group, sample_num), by = "sample_id") %>%
  mutate(
    sample_id = factor(sample_id, levels = sample_levels)
  )

# === Create a PDF ===
pdf("graphics/all_samples_mean_coverage_per_Gbp_grouped_paletteer.pdf", width = 14, height = 8)

# --- Page 1 : stacked by genus ---
p_genus <- ggplot(long_df, aes(x = sample_id, y = mean_coverage_per_Gbp, fill = genus)) +
  geom_bar(stat = "identity") +
  facet_grid(~ group, scales = "free_x", space = "free_x") +
  scale_x_discrete(labels = sample_labels) +
  scale_fill_paletteer_d("ggthemr::flat") +
  theme_bw() +
  labs(
    title = "Mean coverage per sequenced Gbp (stacked by genus)",
    x = "Sample (ID)",
    y = "Mean coverage per sequenced Gbp"
  ) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    plot.title  = element_text(hjust = 0.5)
  )
print(p_genus)

# --- Page 2 : stacked by MAG ---
p_MAG <- ggplot(long_df, aes(x = sample_id, y = mean_coverage_per_Gbp, fill = bins)) +
  geom_bar(stat = "identity") +
  facet_grid(~ group, scales = "free_x", space = "free_x") +
  scale_x_discrete(labels = sample_labels) +
  scale_fill_paletteer_d("dichromat::Categorical_12") +
  theme_bw() +
  labs(
    title = "Mean coverage per sequenced Gbp (stacked by MAGs)",
    x = "Sample (ID)",
    y = "Mean coverage per sequenced Gbp"
  ) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    plot.title  = element_text(hjust = 0.5)
  )
print(p_MAG)

dev.off()

message("[INFO] PDF saved at: ", file.path("graphics/all_samples_mean_coverage_per_Gbp_grouped_paletteer.pdf"))
