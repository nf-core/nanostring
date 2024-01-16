process CREATE_GENE_HEATMAP {
    label 'process_single'

    conda "r-dplyr=1.1.4 r-ggplot2=3.4.4 r-rlang=1.1.1 r-fs=1.6.2 bioconductor-complexheatmap=2.14.0 r-circlize=0.4.15 r-yaml=2.3.7 r-ragg=1.2.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-68b3ca19fcb1f8b052324cb635ab60f8b17a3058:27c800678a1e9e56c8b44f6a997464300938abdc-0' :
        'biocontainers/mulled-v2-68b3ca19fcb1f8b052324cb635ab60f8b17a3058:27c800678a1e9e56c8b44f6a997464300938abdc-0' }"

    input:
    path annotated_counts
    path heatmap_genes_to_filter

    output:
    path "*gene_heatmap_mqc.png", emit: gene_heatmap
    path "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    compute_gene_heatmap.R $annotated_counts $heatmap_genes_to_filter $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-nacho: \$(Rscript -e "library(NACHO); cat(as.character(packageVersion('NACHO')))")
        r-tidyverse: \$(Rscript -e "library(tidyverse); cat(as.character(packageVersion('tidyverse')))")
        r-fs: \$(Rscript -e "library(fs); cat(as.character(packageVersion('fs')))")
    END_VERSIONS
    """
}
