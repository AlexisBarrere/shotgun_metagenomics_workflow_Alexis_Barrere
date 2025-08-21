# === Set the working directory ===
setwd("C:/Users/alexi/Documents/Cours/Stage Copenhague 2025/Stage 2025/barplots_3")
      
dir.create("graphics")
graphics_dir <- file.path(getwd(), "graphics")

# === Inputs ===

# --- Import the files ---

mean_coverage_per_Gbp <- read.delim("mean_coverage_per_Gbp.txt", sep = "\t", header = TRUE)

metadata <- read.delim("metadata.tsv", sep = "\t", header = TRUE)


# === Load required package ===
library(ggplot2)  # for barplots
library(dplyr)    # for calculations
library(tidyr)    # to switch from wide format to long format (pivot_longer is part of tidyr)
library(gridExtra)  # for grid.arrange
library(grid)

# === Transform from wide to long format ===
long_mean_coverage_per_Gbp <- mean_coverage_per_Gbp %>%
  pivot_longer(
    cols = starts_with("sample_"),  # Select all columns whose names start with "sample_"
    names_to = "sample_id",          # Name of the new column that will contain the sample IDs
    values_to = "value"              # Name of the new column that will contain the numeric values
  ) 

# --- Check the first few rows ---
head(long_mean_coverage_per_Gbp)

# === Merge the long-format relative abundance table with metadata ===
long_meta_mean_coverage_per_Gbp <- merge(
  long_mean_coverage_per_Gbp,   # long-format table (bins, sample_id, value)
  metadata,        # metadata table (sample_id, time, fertilizer)
  by = "sample_id" # common column to join on
)

# === Get the list of all MAGs present in the dataset ===
mag_list <- mean_coverage_per_Gbp$bins

# === Create a PDF to store all plots ===
pdf("graphics/mean_coverage_per_Gbp_all_MAGs_bar_dotplots.pdf", width = 12, height = 8)  # set page size

# === Loop through each MAG ===
for (mag_to_plot in mag_list) {
  
  # --- Filter the data for the current MAG ---
  mag_data <- long_meta_mean_coverage_per_Gbp %>%
    filter(bins == mag_to_plot)
    
  # --- BARPLOT - N1K1 ---
  p_bar_N1K1 <- ggplot(mag_data %>% filter(fertilizer == "N1K1"),
                       aes(x = time, y = value, fill = time)) +
    geom_bar(stat = "summary", fun = "mean", width = 0.7) +
    geom_errorbar(stat = "summary",
                  fun.data = mean_sdl, fun.args = list(mult = 1),
                  width = 0.2) +
    theme_bw() +
    labs(title = paste("N1K1 - barplot (Mean ± SD)"),
         subtitle = "n = 4 samples per time point",
         y = "Mean coverage per sequenced Gbp", x = "Time") +
         theme(plot.title = element_text(hjust = 0.5, size = 12))
  
  # --- BARPLOT - N1P2K2 ---
  p_bar_N1P2K2 <- ggplot(mag_data %>% filter(fertilizer == "N1P2K2"),
                         aes(x = time, y = value, fill = time)) +
    geom_bar(stat = "summary", fun = "mean", width = 0.7) +
    geom_errorbar(stat = "summary",
                  fun.data = mean_sdl, fun.args = list(mult = 1),
                  width = 0.2) +
    theme_bw() +
    labs(title = paste("N1P2K2 - barplot (Mean ± SD)"),
         subtitle = "n = 4 samples per time point",
         y = "Mean coverage per sequenced Gbp", x = "Time") + 
         theme(plot.title = element_text(hjust = 0.5, size = 12))
  
  # --- DOTPLOT - N1K1 ---
  p_dot_N1K1 <- ggplot(mag_data %>% filter(fertilizer == "N1K1"),
                       aes(x = time, y = value)) +
    geom_jitter(width = 0.1, size = 2, alpha = 0.7, color="darkorange") +
    
    # Mean : 
    stat_summary(aes(shape = "Mean", fill = "Mean"),
                 fun = mean, geom = "point", size = 4) +
    
    # median : 
    stat_summary(aes(shape = "Median", fill = "Median"),
                 fun = median, geom = "point", size = 4) +
    
    scale_shape_manual(name = "Statistic", values = c("Mean" = 21, "Median" = 23)) +
    scale_fill_manual(name = "Statistic", values = c("Mean" = "black", "Median" = "red")) +
    
    theme_bw() +
    labs(title = paste("N1K1 - Dotplot"),
         y = "Mean coverage per sequenced Gbp", x = "Time") +
         theme(plot.title = element_text(hjust = 0.5, size = 12))
  
  # --- DOTPLOT - N1P2K2 ---
  p_dot_N1P2K2 <- ggplot(mag_data %>% filter(fertilizer == "N1P2K2"),
                         aes(x = time, y = value)) +
    geom_jitter(width = 0.1, size = 2, alpha = 0.7, color="darkorange") +
    
    # Mean : 
    stat_summary(aes(shape = "Mean", fill = "Mean"),
                 fun = mean, geom = "point", size = 4) +
    
    # median : 
    stat_summary(aes(shape = "Median", fill = "Median"),
                 fun = median, geom = "point", size = 4) +
    
    scale_shape_manual(name = "Statistic", values = c("Mean" = 21, "Median" = 23)) +
  scale_fill_manual(name = "Statistic", values = c("Mean" = "black", "Median" = "red")) +
    
    theme_bw() +
    labs(title = paste("N1P2K2 - Dotplot"),
         y = "Mean coverage per sequenced Gbp", x = "Time") +
         theme(plot.title = element_text(hjust = 0.5, size = 12))
  
  # Arrange the 4 plots on the same PDF page
  grid.arrange(p_bar_N1K1, p_bar_N1P2K2, p_dot_N1K1, p_dot_N1P2K2,
               ncol = 2,  # 2 plots per row
               top = textGrob(
                 paste("Mean coverage per sequenced Gbp for", mag_to_plot),
                 gp = gpar(fontsize = 16, fontface = "bold")
                 ))
}

# Close the PDF
dev.off()

message("[INFO] PDF saved at : graphics/mean_coverage_per_Gbp_all_MAGs_bar_dotplots.pdf")
