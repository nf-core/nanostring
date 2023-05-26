#!/usr/bin/env Rscript
library(tidyverse)
library(tidylog)
library(fs)
library(yaml)

#source stuff we need from scripts by Matthias/Stefan
source("../gene_signature_scores/signature_score_functions.R")

#Read in GeneSets as YAML format

