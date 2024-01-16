process COMPUTE_GENE_SCORES {
    label 'process_single'

    conda "r-yaml=2.3.7 r-ggplot2=3.4.4 r-dplyr=1.1.4 r-stringr=1.5.0 bioconductor-gsva=1.46.0 bioconductor-singscore=1.18.0 r-factominer=2.8.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-dfd42984f8ba1b1d0d13648f30430581dff51e82:2a27d1707e91426237b882a7ba5adec8724f9069-0' :
        'biocontainers/mulled-v2-dfd42984f8ba1b1d0d13648f30430581dff51e82:2a27d1707e91426237b882a7ba5adec8724f9069-0' }"

    input:
    path counts
    path geneset_yaml

    output:
    path "*.txt", emit: scores_for_mqc
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    compute_gene_scores.R $geneset_yaml $counts $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-tidyverse: \$(Rscript -e "library(tidyverse); cat(as.character(packageVersion('tidyverse')))")
        r-singscore: \$(Rscript -e "library(singscore); cat(as.character(packageVersion('singscore')))")
        r-GSVA: \$(Rscript -e "library(GSVA); cat(as.character(packageVersion('GSVA')))")
        r-yaml: \$(Rscript -e "library(yaml); cat(as.character(packageVersion('yaml')))")
        r-FactoMineR: \$(Rscript -e "library(FactoMineR); cat(as.character(packageVersion('FactoMineR')))")
        r-stringr: \$(Rscript -e "library(stringr); cat(as.character(packageVersion('stringr')))")
    END_VERSIONS
    """
}
