#!/usr/bin/env Rscript
#
# Write nf-core/differentialabundance inputs from NACHO normalized counts:
#   <prefix>_log2_endogenous.tsv        log2 normalized counts, Endogenous genes only,
#                                       `feature_id` column + one column per SAMPLE_ID
#   samplesheet_differentialabundance.csv  samplesheet with a `sample` column matching
#                                       the matrix columns, plus all metadata columns
#
# The matrix is on log2 scale because `-profile generic_matrix` passes it to limma
# without any transformation. Control probes (Positive, Negative) and housekeeping
# genes are dropped so they are not tested.

suppressPackageStartupMessages({
    library(dplyr)
    library(readr)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
    stop("Usage: export_differentialabundance.R <normalized_counts.tsv> <samplesheet.csv>", call. = FALSE)
}
input_counts      <- args[1]
input_samplesheet <- args[2]

counts      <- read_tsv(input_counts, col_types = cols(Name = "c", CodeClass = "c", .default = "d"), progress = FALSE)
samplesheet <- read_csv(input_samplesheet, col_types = cols(.default = "c"), trim_ws = TRUE, progress = FALSE)

# Matrix columns are RCC file names; map them to SAMPLE_IDs via the samplesheet
rcc_columns <- setdiff(colnames(counts), c("Name", "CodeClass"))
unmatched   <- setdiff(rcc_columns, samplesheet$RCC_FILE_NAME)
if (length(unmatched) > 0) {
    stop("Count columns not found in samplesheet RCC_FILE_NAME: ", paste(unmatched, collapse = ", "), call. = FALSE)
}
sample_ids <- samplesheet$SAMPLE_ID[match(rcc_columns, samplesheet$RCC_FILE_NAME)]
if (anyDuplicated(sample_ids) > 0) {
    stop("SAMPLE_ID must be unique to export for differentialabundance; duplicated: ",
        paste(unique(sample_ids[duplicated(sample_ids)]), collapse = ", "), call. = FALSE)
}

endogenous <- counts %>% filter(grepl("^Endogenous", CodeClass))
if (nrow(endogenous) == 0) {
    stop("No Endogenous genes found in ", input_counts, call. = FALSE)
}
if (anyDuplicated(endogenous$Name) > 0) {
    stop("Duplicated Endogenous gene names: ",
        paste(unique(endogenous$Name[duplicated(endogenous$Name)]), collapse = ", "), call. = FALSE)
}
values <- as.matrix(endogenous[, rcc_columns])
if (any(is.na(values))) {
    stop("Normalized counts contain missing values", call. = FALSE)
}
# NACHO >= 2.0.7 floors normalized counts at 0.1; apply the same floor to counts
# from older NACHO versions (which used 0) so that log2 is defined
floor_value <- 0.1
if (any(values < floor_value)) {
    warning(sum(values < floor_value), " normalized counts below ", floor_value, " set to ", floor_value, " before log2", call. = FALSE)
}

matrix_log2 <- endogenous %>%
    select(feature_id = Name, all_of(rcc_columns)) %>%
    mutate(across(all_of(rcc_columns), ~ round(log2(pmax(.x, floor_value)), 6)))
colnames(matrix_log2) <- c("feature_id", sample_ids)

samplesheet_out <- samplesheet %>%
    filter(RCC_FILE_NAME %in% rcc_columns) %>%
    slice(match(rcc_columns, RCC_FILE_NAME)) %>%
    select(-any_of("RCC_FILE")) %>%
    mutate(sample = SAMPLE_ID, .before = 1)

prefix <- tools::file_path_sans_ext(basename(input_counts))
write_tsv(matrix_log2, paste0(prefix, "_log2_endogenous.tsv"))
write_csv(samplesheet_out, "samplesheet_differentialabundance.csv")
