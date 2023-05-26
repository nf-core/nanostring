#!/usr/bin/env Rscript
library(tidyverse)
library(pheatmap)
library(ComplexHeatmap)
library(ggplot2)
library(RColorBrewer)

###Commandline Argument parsing###
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 1) {
  stop("Usage: nsolver_celltype_heatmap.R <path_to_celltype_file_from_nsolver>", call.=FALSE)
}

input_heatmap_stuff <- args[1]

df_celltypes <- read.table(input_heatmap_stuff, sep=",", header=T, skip=1)
names(df_celltypes)[1] <- "FILENAME"

rownames(df_celltypes) <- df_celltypes[,1]
df_celltypes <- df_celltypes %>% select (- FILENAME)
breaksList =c(-6, seq(-2, 2, by = 0.1) ,6)

plot_nsolver_heatmap <- pheatmap(df_celltypes, main = "Heatmap of CellType scores",
             color  = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(length(breaksList)),
             show_colnames = TRUE,
             show_rownames = TRUE,
             breaks = breaksList,
             #annotation_col = labels,
             #annotation_colors = ann_colors,
             cluster_cols=T, fontsize_row = 8,
             scale="row",
             cellheight = 10,
             legend_breaks = c(-6,seq(-4,4,2)),
             legend_labels = c("\nCellType scores\n",seq(-4,4,2)))

ggsave(filename="NSolver_CellType_Heatmap_mqc.png", plot = plot_nsolver_heatmap, scale = 2)
