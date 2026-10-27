process CREATE_ANNOTATED_TABLES {
    tag "$sample_sheet"
    label 'process_single'

    conda "${moduleDir}/environment.yml"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/56/56c5ac7d61c88a64dc7d6f047e92fbcafbfa271a2df451181f3bac6addcc58b3/data' :
        'community.wave.seqera.io/library/r-dplyr_r-ggplot2_r-readr_r-stringr_r-tidyr:48d97bd8e8272dbe' }"

    input:
    tuple val(meta) , path(counts)
    tuple val(meta2), path(sample_sheet)

    output:
    tuple val(meta), path("*ENDO.tsv"), emit: annotated_endo_data
    tuple val(meta), path("*HK.tsv*") , emit: annotated_hk_data
    tuple val(meta), path("*_mqc.tsv"), emit: annotated_data_mqc
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    write_out_prepared_gex.R $counts $sample_sheet $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot')))")
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
    END_VERSIONS
    """

    stub:
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
