#!/usr/bin/env Rscript
library(tidyverse)
library(ggplot2)
library(rlang)


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
    ent = enquo(entity)
    # returns nice table with counts + annotated metadata following standards set by nanostring
    # entity = "Housekeeping" or "Endogenous" (can be used to get barplots for Housekeepers too :-))
    # metadata format from nf-core/nanostring pipeline
    remove_us = c("CodeClass", "Name")
    counts_tmp <- counts %>% filter(.data$`CodeClass` == {{ entity }}) %>% select(!all_of(remove_us))
    t_counts <- counts_tmp  %>%
        tibble::rownames_to_column() %>%
        pivot_longer(-rowname) %>%
        pivot_wider(names_from=rowname, values_from=value)
    colnames(t_counts) <- t_counts[1,]
    t_counts <- t_counts[-1,]
    colnames(t_counts)[1] <- "RCC_FILE_NAME"

    #Remove RCC_FILE from metadata
    remove_meta <- c("RCC_FILE", "INCLUDE")
    metadata <- metadata %>% select(!all_of(remove_meta))

    #Lets merge with metadata
    merged_counts <- left_join(t_counts, metadata, by=(c("RCC_FILE"="RCC_FILE")))

    return(merged_counts)
}

hk_annotated <- getTransposedAnnotatedCounts(counts = counts, entity = "Housekeeping", metadata = meta_detail)
endo_annotated <- getTransposedAnnotatedCounts(counts = counts, entity = "Endogenous", metadata = meta_detail)

#Write files as TSVs for multiqc input :-)
now=format(Sys.time(), "%Y%m%d%H%M")

write.table(hk_annotated, file = paste0("Norm_GEX_HK_mqc.tsv"), sep="\t", quote = FALSE, col.names = TRUE, row.names=FALSE)
write.table(endo_annotated, file = paste0(now, "_Norm_GEX_ENDO.tsv"), sep="\t", quote = FALSE, col.names = TRUE, row.names=FALSE)
