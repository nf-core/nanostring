process NACHO_QC {
    tag '$bam'
    label 'process_single'

    //waiting for mulled container here https://github.com/BioContainers/multi-package-containers/pull/2624
    conda "r-nacho=2.0.4 r-tidyverse=2.0.0 r-ggplot2=3.4.2 r-rlang=1.1.1 r-tidylog=1.0.2 r-fs=1.6.2 bioconductor-complexheatmap=2.14.0 r-circlize=0.4.15 r-yaml=2.3.7 r-ragg=1.2.5 r-rcolorbrewer=1.1_3 r-pheatmap=1.0.12"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-4dc1353ff8c6442f4e67c175872af3e5f897256c:df530e996eaf9f7a555aabb0a6a7198eae7e73b8-0':
        'mulled-v2-4dc1353ff8c6442f4e67c175872af3e5f897256c:df530e996eaf9f7a555aabb0a6a7198eae7e73b8-0' }"

    input:
    path rcc_directory
    path sample_sheet

    output:
    path "*.html", emit: nacho_qc_reports
    path "*.mqc*", emit: nacho_qc_multiqc_metrics
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
