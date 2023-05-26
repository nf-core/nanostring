#!/usr/bin/env Rscript
library(tidyverse)
library(fs)
library(NACHO)

###Commandline Argument parsing###
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
  stop("Usage: nanoQC.R <filepath_to_rccs> <path_to_samplesheet>", call.=FALSE)
}
input_rcc_path <- args[1]
input_samplesheet <- args[2]

#Create filelist for NachoQC

list_of_rccs <- dir_ls(path = input_rcc_path, pattern= "*RCC$")

tmp_list <- as.data.frame(list_of_rccs)
row.names(tmp_list) <- NULL
colnames(tmp_list)[1] <- "RCC_FILE"
tmp_list$RCC_FILE <- as.character(tmp_list$RCC_FILE)

#write to table
write.table(tmp_list, "samplesheet.tsv", sep="\t", row.names=F, col.names=T, quote=F)

####RealCode####
nacho_data <- load_rcc(data_directory = input_rcc_path,
                       ssheet_csv = input_samplesheet,
                       id_colname = "RCC_FILE")

output_base <- "./"

get_counts <- function(
  nacho,
  codeclass = "Endogenous",
  rownames = "RCC_FILE",
  colnames = c("Name", "Accession")
) {
  nacho[["nacho"]] %>%
    dplyr::filter(grepl(codeclass, .data[["CodeClass"]])) %>%
    dplyr::select(c("RCC_FILE", "Name", "Count_Norm")) %>%
    tidyr::pivot_wider(names_from = colnames[1], values_from = "Count_Norm") %>%
    tibble::column_to_rownames(rownames) %>%
    t()
}

#Write out normalized counts
norm_counts <- as.data.frame(get_counts(nacho_data))
write_tsv(norm_counts, file = "./normalized_counts.tsv")


#Write out non-hk normalized counts too
nacho_data_no_hk <- load_rcc(data_directory = input_rcc_path,
                       ssheet_csv = input_samplesheet,
                       id_colname = "RCC_FILE")

#Perform normalization again but without HK (so only pos + negative controls are used)
non_hk_normed_data <- normalise(nacho_data_no_hk,
                       nacho_data_no_hk[["housekeeping_genes"]],
                       housekeeping_norm = FALSE
)

norm_counts_without_hks <- as.data.frame(get_counts(non_hk_normed_data))

write_tsv(norm_counts_without_hks, file = "./normalized_counts_wo_HKnorm.tsv")


