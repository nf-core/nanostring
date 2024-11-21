process CREATE_ANNOTATED_TABLES {
    tag "$sample_sheet"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/r-dplyr_r-ggplot2_r-readr_r-stringr_r-tidyr:44c4e4fe69e11c2f"

    input:
    path counts
    path sample_sheet

    output:
    path "*ENDO.tsv"   , emit: annotated_endo_data
    path "*HK.tsv*"    , emit: annotated_hk_data
    path "*_mqc.tsv"   , emit: annotated_data_mqc
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    write_out_prepared_gex.R $counts $sample_sheet

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot')))")
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch ENDO.tsv
    touch HK.tsv
    touch mqc.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot')))")
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
    END_VERSIONS
    """
}
