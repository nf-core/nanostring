process NACHO_NORMALIZE {
    label 'process_single'

    conda "r-nacho=2.0.6 r-dplyr=1.2.2 r-ggplot2=3.4.4 r-fs=1.6.2 r-readr=2.1.5 r-tidyr=1.3.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-9d27fb90b747ac2e521703d90daacce9cc1f33c5:98395a5d2e19da46499873cd2d76be73d6a0950d-0' :
        'biocontainers/mulled-v2-9d27fb90b747ac2e521703d90daacce9cc1f33c5:98395a5d2e19da46499873cd2d76be73d6a0950d-0' }"

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
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot2')))")
        r-tidyr: \$(Rscript -e "library(tidyr); cat(as.character(packageVersion('tidyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
        r-fs: \$(Rscript -e "library(fs); cat(as.character(packageVersion('fs')))")
    END_VERSIONS
    """
}
