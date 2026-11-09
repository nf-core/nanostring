process CREATE_ANNOTATED_TABLES {
    tag "$sample_sheet"
    label 'process_single'

    conda "${moduleDir}/environment.yml"

    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
?         'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fc/fc3f085fb9fa37ada3792ed13783d85378fc09558c1df742e02908d243f6644c/data'
:         'community.wave.seqera.io/library/r-base_r-dplyr_r-ggplot2_r-readr_pruned:699fc61330185bf2' }"

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
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot2')))")
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
    END_VERSIONS
    """

    stub:
    // Mirror the output file naming of write_out_prepared_gex.R
    def input_name = counts.baseName.tokenize('_').drop(1).join('_')
    def mqc_prefix = input_name.contains('wo_HKnorm') ? 'No_HK_' : ''
    """
    touch ${input_name}_Norm_GEX_ENDO.tsv
    touch ${input_name}_Norm_GEX_HK.tsv
    touch ${mqc_prefix}Norm_GEX_ENDO_mqc.tsv
    touch ${mqc_prefix}Norm_GEX_HK_mqc.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot2')))")
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
    END_VERSIONS
    """
}
