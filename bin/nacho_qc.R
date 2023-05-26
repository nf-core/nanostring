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

#Write out HK genes detected and add to MultiQC report as custom content
line="#id: nf-core-nanostring-hk-genes
#section_name: 'Housekeeping Genes'
#description: 'detected in the input RCC Files.'
#plot_type: 'html'
#section_href: 'https://github.com/nf-core/nanostring'
#data:
    "

write(line,file=paste0(output_base, "hk_detected_mqc.txt"),append=TRUE)
write(nacho_data$housekeeping_genes ,paste0(output_base,"hk_detected_mqc.txt"),append=TRUE)


#Add in all plots as MQC output for MultiQC
plot_bd <- autoplot(
  object = nacho_data,
  x = "BD",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="BD_mqc.png", plot_bd)


## Field of View (FoV) Imaging

plot_fov <- autoplot(
  object = nacho_data,
  x = "FoV",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="FOV_mqc.png", plot_fov)


## Positive Control Linearity

plot_posctrl_lin <- autoplot(
  object = nacho_data,
  x = "PCL",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)

ggsave(filename="Posctrl_linearity_mqc.png", plot_posctrl_lin)

## Limit of Detection

plot_lod <- autoplot(
  object = nacho_data,
  x = "LoD",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)

ggsave(filename="LOD_mqc.png", plot_lod)

## Positive Controls

plot_pos <- autoplot(
  object = nacho_data,
  x = "Positive",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="Pos_mqc.png", plot_pos)


## Negative Controls

plot_neg <- autoplot(
  object = nacho_data,
  x = "Negative",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="Neg_mqc.png", plot_neg)

## Housekeeping Genes

plot_hk <- autoplot(
  object = nacho_data,
  x = "Housekeeping",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="HK_mqc.png", plot_hk)

## Positive Controls vs Negative Controls

plot_pos_vs_neg <- autoplot(
  object = nacho_data,
  x = "PN",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="Pos_vs_neg_mqc.png", plot_pos_vs_neg)

## Average Counts vs. Binding Density

plot_avg_vs_bd <- autoplot(
  object = nacho_data,
  x = "ACBD",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="AVG_vs_BD_mqc.png", plot_avg_vs_bd)

## Average Counts vs. Median Counts

plot_avg_vs_med <- autoplot(
  object = nacho_data,
  x = "ACMC",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="AVG_vs_MED_mqc.png", plot_avg_vs_med)

## Principal Component 1 vs. 2

plot_pc12 <- autoplot(
  object = nacho_data,
  x = "PCA12",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="PCA1_vs_PCA2_mqc.png", plot_pc12)

## Principal Component i

plot_pcai <- autoplot(
  object = nacho_data,
  x = "PCAi",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="PCAi_mqc.png", plot_pcai)

## Principal Component planes
plot_pcap <- autoplot(
  object = nacho_data,
  x = "PCA",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="PCA_mqc.png", plot_pcap)

## Positive Factor vs. Negative Factor
plot_posf_vs_negf <- autoplot(
  object = nacho_data,
  x = "PFNF",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="POSF_vs_NEGF_mqc.png", plot_posf_vs_negf)

## Housekeeping Factor

plot_hkf <- autoplot(
  object = nacho_data,
  x = "HF",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="HKF_mqc.png", plot_hkf)

## Normalization Factors

plot_normf <- autoplot(
  object = nacho_data,
  x = "NORM",
  colour = "CartridgeID",
  size = 0.5,
  show_legend = TRUE
)
ggsave(filename="plot_normf_mqc.png", plot_normf)


#Render Standard Report for investigation in main MultiQC Report
render(nacho_object = nacho_data, output_dir = output_base, output_file = "NanoQC.html", show_outliers = FALSE)

#Render the same Report for standard investigation, but not for MultiQC Report
render(nacho_object = nacho_data, output_dir = output_base, output_file = "NanoQC_with_outliers.html", show_outliers = TRUE)
