process CREATE_ANNOTATED_TABLES {
    label 'process_single'

    conda "r-tidyr=1.3.0 r-ggplot2=3.4.4 r-dplyr=1.1.4 r-stringr=1.5.0 r-readr=2.1.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-12624087a73150ff0fdb8009e5ee560c862e4b99:ad0e6da297bbe6c1aac2b06486d7bda1f8579759-0' :
        'biocontainers/mulled-v2-12624087a73150ff0fdb8009e5ee560c862e4b99:ad0e6da297bbe6c1aac2b06486d7bda1f8579759-0' }"

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
        r-ggplot2: \$(Rscript -e "library(ggplot2); cat(as.character(packageVersion('ggplot')))")
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-readr: \$(Rscript -e "library(readr); cat(as.character(packageVersion('readr')))")
        r-fs: \$(Rscript -e "library(fs); cat(as.character(packageVersion('fs')))")
    END_VERSIONS
    """
}

