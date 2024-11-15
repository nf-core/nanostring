#!/usr/bin/env Rscript
library(tidyr)
library(dplyr)
library(ggplot2)
library(readr)
library(stringr)

###Commandline Argument parsing###
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("Usage: write_out_prepared_gex.R <counts.tsv> <samplesheet>", call.=FALSE)
}

input_counts <- args[1]
input_samplesheet <- args[2]

#RCC_FILE	SAMPLE_ID	GROUP	TREATMENT	INCLUDE	OTHER_METADATA
meta_detail <- read.table(input_samplesheet, sep=",", header=T, check.names = FALSE, stringsAsFactors = FALSE, strip.white = T) %>%
    mutate_all(as.character)

counts <- read.table(input_counts, sep="\t", check.names=FALSE, stringsAsFactors=FALSE, header=TRUE) %>%
    mutate_all(as.character)

##We should have a function for this, need to perform this with Housekeepers AND endogenous
# Function needs two TidyVerse specifics, https://dplyr.tidyverse.org/articles/programming.html#tidy-selection-1 (once the tidyselect, once the filter needs the .data$bla selector)
getTransposedAnnotatedCounts <- function(counts, entity , metadata) {
    # returns nice table with counts + annotated metadata following standards set by nanostring
    # entity = "Housekeeping" or "Endogenous" (can be used to get barplots for Housekeepers too :-))
    # metadata format from nf-core/nanostring pipeline
    t_counts <- counts %>%
        filter(grepl(entity, CodeClass)) %>%
        tidyr::pivot_longer( cols = -all_of(c("CodeClass", "Name")), names_to = "RCC_FILE") %>%
        pivot_wider(names_from="Name", values_from= value)

    #Remove RCC_FILE from metadata
    remove_meta <- c("RCC_FILE", "INCLUDE")
    metadata <- metadata %>% select(!any_of(remove_meta))

    #Lets merge with metadata
    merged_counts <- t_counts %>%
        left_join(metadata, by=(c("RCC_FILE" = "RCC_FILE_NAME"))) %>%
        select(- CodeClass) %>%
        arrange(RCC_FILE)

    return(merged_counts)
}

hk_annotated <- getTransposedAnnotatedCounts(counts = counts, entity = "Housekeeping", metadata = meta_detail)
endo_annotated <- getTransposedAnnotatedCounts(counts = counts, entity = "Endogenous", metadata = meta_detail)

#Write files as TSVs for multiqc input :-)

input_name <- str_c(str_split_1(tools::file_path_sans_ext(input_counts), "_")[-1], collapse = "_")

write.table(hk_annotated, file = paste0(input_name, "_Norm_GEX_HK.tsv"), sep="\t", quote = FALSE, col.names = TRUE, row.names=FALSE)
write.table(endo_annotated, file = paste0(input_name, "_Norm_GEX_ENDO.tsv"), sep="\t", quote = FALSE, col.names = TRUE, row.names=FALSE)

prefix <- ""
if (grepl("wo_HKnorm", input_counts)) {
    prefix <- "No_HK_"
}

write.table(hk_annotated, file = paste0(prefix,"Norm_GEX_HK_mqc.tsv"), sep="\t", quote = FALSE, col.names = TRUE, row.names=FALSE)
write.table(endo_annotated, file = paste0(prefix,"Norm_GEX_ENDO_mqc.tsv"), sep="\t", quote = FALSE, col.names = TRUE, row.names=FALSE)
