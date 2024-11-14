#!/usr/bin/env Rscript
library(dplyr)
library(ggplot2)
library(fs)
library(NACHO)
library(readr)
library(tidyr)

###Commandline Argument parsing###
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("Usage: nacho_norm.R <filepath_to_rccs> <path_to_samplesheet>", call.=FALSE)
}
input_rcc_path <- args[1]
input_samplesheet <- args[2]
norm_method <- args[3]

#Create filelist for NachoQC

list_of_rccs <- dir_ls(path = input_rcc_path, glob = "*.RCC")

####RealCode####
nacho_data <- load_rcc(data_directory = input_rcc_path,
                    ssheet_csv = input_samplesheet,
                    id_colname = "RCC_FILE_NAME",
                    normalisation_method = norm_method)

output_base <- "./"

get_counts <- function(
    nacho,
    codeclass = "Endogenous",
    rownames = "RCC_FILE_NAME",
    colnames = c("Name", "Accession")
) {
    nacho[["nacho"]] %>%
    dplyr::select(c("RCC_FILE_NAME", "Name", "Count_Norm", "CodeClass")) %>%
    tidyr::pivot_wider(names_from = "RCC_FILE_NAME", values_from = "Count_Norm")
}

#Write out normalized counts
norm_counts <- as.data.frame(get_counts(nacho_data))
write_tsv(norm_counts, file = "normalized_counts.tsv")

#Write out non-hk normalized counts too
nacho_data_no_hk <- load_rcc(data_directory = input_rcc_path,
    ssheet_csv = input_samplesheet,
    id_colname = "RCC_FILE_NAME",
    normalisation_method = norm_method,
    housekeeping_norm = FALSE)

norm_counts_without_hks <- as.data.frame(get_counts(nacho_data_no_hk))
write_tsv(norm_counts_without_hks, file = "normalized_counts_wo_HKnorm.tsv")
