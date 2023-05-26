#!/usr/bin/env Rscript
library(tidyverse)
library(ggplot2)
library(rlang)
library(tidylog)
library(fs)

###Commandline Argument parsing###
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 1) {
  stop("Usage: barplots_expression.R <annotated_counts.tsv>", call.=FALSE)
}
####Uncomment if debugging

input_counts <- args[1]

#Debugging
#input_counts <- "./test_data/norm_gex_endo.tsv"

#Read annotated counts
# HEADER is always RCC_FILE + GENES + SAMPLE_ID GROUP TREATMENT OTHER_METADATA
counts <- read.table(input_counts, sep="\t", check.names = FALSE, header=TRUE, stringsAsFactors = FALSE)

#Target Genes of Interest
heads_to_remove <- c("RCC_FILE", "SAMPLE_ID", "TIME", "TREATMENT", "OTHER_METADATA")
genes_of_interest <- colnames(counts %>% select(-all_of(heads_to_remove)))


#Create output folders
dir_create("./exported_plots/TIME")
dir_create("./exported_plots/TREATMENT")
dir_create("./exported_plots/SAMPLE_ID")


# Function writes plots in outdir, takes a matrix with only genes and groupcat as base info
# Function needs two TidyVerse specifics, https://dplyr.tidyverse.org/articles/programming.html#tidy-selection-1 (once the tidyselect, once the filter needs the .data$bla selector)
makeBoxPlot <- function(counts, genelist, outdir, groupcat, facetcat) {
  counts_grouped <- counts %>% group_by(.data[[{{ groupcat }}]])

  for(gene in genelist){

    p <- ggplot(counts_grouped, aes(x=.data[[{{groupcat}}]], y=.data[[gene]], fill=as.factor(.data[[{{groupcat}}]]))) +
      geom_boxplot() +
      theme(legend.position = "none", axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
      labs(x=groupcat, title=paste0("Gene expression grouped by: ", groupcat)) +
      scale_fill_viridis_d() +
      geom_jitter(color="black", size=0.4, alpha=0.9) +
      scale_fill_brewer(palette="Dark2")

    #Make name FS compatible!
    gene <- str_replace_all(gene, "/","-")
    ggsave(paste0("exported_plots/", {{groupcat}}, "/",gene, ".png"),plot=p)
  }
}


#Same as above, but facet with treatment column

makeBoxPlotFacet <- function(counts, genelist, outdir, groupcat, facetcat) {
  counts_grouped <- counts %>% group_by(.data[[{{ groupcat }}]]) %>% select(SAMPLE_ID, TIME, TREATMENT, all_of(genelist))

  for(gene in genelist){
    p <- ggplot(counts_grouped, aes(x=.data[[{{groupcat}}]], y=.data[[gene]], fill=as.factor(.data[[{{groupcat}}]]))) +
      geom_boxplot() +
      theme(legend.position = "none", axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
      labs(x=groupcat, title=paste0("Gene expression grouped by: ", groupcat, ", faceted by: ", facetcat)) +
      scale_fill_viridis_d() +
      facet_wrap(~ .data[[{{ facetcat }}]]) +
      geom_jitter(color="black", size=0.4, alpha=0.9) +
      scale_fill_brewer(palette="Dark2")

    #Make name FS compatible!
    gene <- str_replace_all(gene, "/","-")
    ggsave(paste0("exported_plots/", {{groupcat}}, "/facet/", {{facetcat}},"/", gene, ".png"),plot=p)
  }
}

#Once output per TIME
makeBoxPlot(counts = counts, genelist = genes_of_interest, outdir = "./", groupcat = "TIME")
#Once output per TREATMENT
makeBoxPlot(counts = counts, genelist = genes_of_interest, outdir = "./", groupcat = "TREATMENT")
#One per sample
makeBoxPlot(counts = counts, genelist = genes_of_interest, outdir = "./", groupcat = "SAMPLE_ID")

#Split Other metadata and annotate counts accordingly (only if not all "-")
if(length(unique(counts$OTHER_METADATA)) > 1){
  counts_sep <- counts %>% separate(OTHER_METADATA, sep = ",", into=c("EXTRA_GROUP", "ADD_GROUP"))
  #Check if these are not NA
  if(!anyNA(counts_sep$`EXTRA_GROUP`)){
    #For extra group
    dir_create("./exported_plots/EXTRA_GROUP/facet/TREATMENT")
    dir_create("./exported_plots/EXTRA_GROUP/facet/TIME")
    makeBoxPlotFacet(counts = counts_sep, genelist = genes_of_interest, outdir = "./", groupcat = "EXTRA_GROUP", facetcat = "TREATMENT")
    makeBoxPlotFacet(counts = counts_sep, genelist = genes_of_interest, outdir = "./", groupcat = "EXTRA_GROUP", facetcat = "TIME")
  }
  if(!anyNA(counts_sep$`ADD_GROUP`)){
    #For Add Group
    dir_create("./exported_plots/ADD_GROUP/facet/TREATMENT")
    dir_create("./exported_plots/ADD_GROUP/facet/TIME")
    makeBoxPlotFacet(counts = counts_sep, genelist = genes_of_interest, outdir = "./", groupcat = "ADD_GROUP", facetcat = "TREATMENT")
    makeBoxPlotFacet(counts = counts_sep, genelist = genes_of_interest, outdir = "./", groupcat = "ADD_GROUP", facetcat = "TIME")
  }
}
