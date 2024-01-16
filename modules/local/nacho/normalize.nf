process NACHO_NORMALIZE {
    label 'process_single'

    conda "r-nacho=2.0.6 r-dplyr=1.2.2 r-ggplot2=3.4.4 r-fs=1.6.2 r-readr=2.1.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-68b3ca19fcb1f8b052324cb635ab60f8b17a3058:27c800678a1e9e56c8b44f6a997464300938abdc-0' :
        'biocontainers/mulled-v2-68b3ca19fcb1f8b052324cb635ab60f8b17a3058:27c800678a1e9e56c8b44f6a997464300938abdc-0' }"

    input:
    path rcc_files
    path sample_sheet

    output:
    path "*normalized_counts.tsv", emit: normalized_counts
    path "*normalized_counts_wo_HKnorm.tsv", emit: normalized_counts_wo_HK
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    nacho_norm.R . $sample_sheet $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-nacho: \$(Rscript -e "library(NACHO); cat(as.character(packageVersion('NACHO')))")
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-fs: \$(Rscript -e "library(fs); cat(as.character(packageVersion('fs')))")
    END_VERSIONS
    """
}
