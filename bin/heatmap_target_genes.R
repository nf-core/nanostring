#!/usr/bin/env Rscript
library(tidyverse)
library(ggplot2)
library(fs)
library(ComplexHeatmap)
library(circlize)
library(yaml)
library(ragg)
library(tidylog)

###Commandline Argument parsing###
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("Usage: heatmap_target_genes.R <annotated_counts.tsv> <genes.yaml>", call.=FALSE)
}
####Uncomment if debugging

input_counts <- args[1]
input_genes <- args[2]

#Debugging
#input_counts <- "./test_data/norm_gex_endo.tsv"
#input_genes <- "./test_data/test_genes.yaml"

#Read annotated counts
# HEADER is always RCC_FILE + GENES + SAMPLE_ID GROUP TREATMENT OTHER_METADATA
counts <- read.table(input_counts, sep="\t", check.names = FALSE, header=TRUE, stringsAsFactors = FALSE)
genes <- read_yaml(input_genes)

#Target Genes of Interest
genes_of_interest <- colnames(counts %>% select(all_of(genes)))

#Select counts of interest
counts_selected <- counts %>% select(all_of(genes_of_interest))

#Add proper Rownames
rownames(counts_selected) <- counts$SAMPLE_ID

#log2+1

counts_selected <- log2(counts_selected + 1)
#Find max
colMax <- function(data) sapply(data, max, na.rm = TRUE)
#Find min
colMin <- function(data) sapply(data, min, na.rm = TRUE)

max_value <- max(colMax(counts_selected))
min_value <- min(colMin(counts_selected))

#Save as PDF
agg_png(file = "gene_heatmap_mqc.png", width = 1200, height = 2000, unit = "px")

Heatmap(counts_selected, name = "Selected Genes Heatmap", column_title = "Gene (log2 +1)",
        row_title_rot = 90, row_title = "SampleID",show_row_dend = FALSE, row_names_side = "left",
        show_column_dend = FALSE, col = colorRamp2(c(min_value, max_value), c("#f7f7f7", "#67a9cf")))

dev.off()
