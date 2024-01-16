process CREATE_ANNOTATED_TABLES {
    label 'process_single'

    conda "r-tidyr=1.3.0 r-ggplot2=3.4.4 r-dplyr=1.1.4 r-stringr=1.5.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-68b3ca19fcb1f8b052324cb635ab60f8b17a3058:27c800678a1e9e56c8b44f6a997464300938abdc-0' :
        'biocontainers/mulled-v2-68b3ca19fcb1f8b052324cb635ab60f8b17a3058:27c800678a1e9e56c8b44f6a997464300938abdc-0' }"

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
        r-nacho: \$(Rscript -e "library(NACHO); cat(as.character(packageVersion('NACHO')))")
        r-tidyr: \$(Rscript -e "library(tidyr); cat(as.character(packageVersion('tidyr')))")
        r-fs: \$(Rscript -e "library(fs); cat(as.character(packageVersion('fs')))")
    END_VERSIONS
    """
}
