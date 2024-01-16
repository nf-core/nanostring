process CREATE_GENE_HEATMAP {
    label 'process_single'

    conda "r-dplyr=1.1.4 r-ggplot2=3.4.4 r-rlang=1.1.1 r-fs=1.6.2 bioconductor-complexheatmap=2.14.0 r-circlize=0.4.15 r-yaml=2.3.7 r-ragg=1.2.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-2e8e9d8610faa60024ab107974b3decf00600ddc:e99bc7b45df42fd6b3bd3e4019336741e068897b-0' :
        'biocontainers/mulled-v2-2e8e9d8610faa60024ab107974b3decf00600ddc:e99bc7b45df42fd6b3bd3e4019336741e068897b-0' }"

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
        r-dplyr: \$(Rscript -e "library(tidyverse); cat(as.character(packageVersion('dplyr')))")
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot')))")
        r-rlang: \$(Rscript -e "library(rlang); cat(as.character(packageVersion('rlang')))")
        bioconductor-ComplexHeatmap: \$(Rscript -e "library(ComplexHeatmap); cat(as.character(packageVersion('ComplexHeatmap')))")
        r-circlize: \$(Rscript -e "library(circlize); cat(as.character(packageVersion('circlize')))")
        r-yaml: \$(Rscript -e "library(yaml); cat(as.character(packageVersion('yaml')))")
        r-fs: \$(Rscript -e "library(fs); cat(as.character(packageVersion('fs')))")
    END_VERSIONS
    """
}

