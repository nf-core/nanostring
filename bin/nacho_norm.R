#!/usr/bin/env Rscript
library(tidyverse)
library(fs)
library(NACHO)

###Commandline Argument parsing###
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("Usage: nacho_norm.R <filepath_to_rccs> <path_to_samplesheet>", call.=FALSE)
}
input_rcc_path <- args[1]
input_samplesheet <- args[2]
norm_method <- args[3]

print(norm_method)

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
    # suggestion how to change it, not sure if this is what we intend to have (commented out the original version)
    nacho[["nacho"]] %>%
    #dplyr::filter(grepl(codeclass, .data[["CodeClass"]])) %>%
    #dplyr::select(c("RCC_FILE_NAME", "Name", "Count_Norm", "CodeClass")) %>%
    #tidyr::pivot_wider(names_from = colnames[1], values_from = "Count_Norm") %>%
    dplyr::select(c("RCC_FILE_NAME", "Name", "Count_Norm", "CodeClass")) %>%
    tidyr::pivot_wider(names_from = "RCC_FILE_NAME", values_from = "Count_Norm")
    #tibble::column_to_rownames(rownames) %>%
    #t()
}

now=format(Sys.time(), "%Y%m%d%H%M")

#Write out normalized counts
norm_counts <- as.data.frame(get_counts(nacho_data))
write_tsv(norm_counts, file = paste0(now, "_normalized_counts.tsv"))

#Write out non-hk normalized counts too
nacho_data_no_hk <- load_rcc(data_directory = input_rcc_path,
    ssheet_csv = input_samplesheet,
    id_colname = "RCC_FILE_NAME",
    normalisation_method = norm_method,
    housekeeping_norm = FALSE)

norm_counts_without_hks <- as.data.frame(get_counts(nacho_data_no_hk))
write_tsv(norm_counts_without_hks, file = paste0(now, "_normalized_counts_wo_HKnorm.tsv"))
