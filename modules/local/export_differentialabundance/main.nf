process EXPORT_DIFFERENTIALABUNDANCE {
    tag "$counts"
    label 'process_single'

    conda "${moduleDir}/environment.yml"

    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
?         'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fc/fc3f085fb9fa37ada3792ed13783d85378fc09558c1df742e02908d243f6644c/data'
:         'community.wave.seqera.io/library/r-base_r-dplyr_r-ggplot2_r-readr_pruned:699fc61330185bf2' }"

    input:
    tuple val(meta) , path(counts)
    tuple val(meta2), path(sample_sheet)

    output:
    tuple val(meta), path("*_log2_endogenous.tsv")                 , emit: matrix
    tuple val(meta), path("samplesheet_differentialabundance.csv"), emit: samplesheet
    path "versions.yml"                                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    export_differentialabundance.R $counts $sample_sheet

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
    END_VERSIONS
    """

    stub:
    """
    touch ${counts.baseName}_log2_endogenous.tsv
    touch samplesheet_differentialabundance.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
    END_VERSIONS
    """
}
