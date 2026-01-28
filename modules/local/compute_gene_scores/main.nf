process COMPUTE_GENE_SCORES {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/bioconductor-gsva_bioconductor-singscore_r-dplyr_r-factominer_pruned:8eae484473163370' :
        'community.wave.seqera.io/library/bioconductor-gsva_bioconductor-singscore_r-dplyr_r-factominer_pruned:e6f1a5cd9110d36b' }"

    input:
    tuple val(meta), path(normalized_counts)
    path gene_score_yaml

    output:
    tuple val(meta), path("*.txt"), emit: scores_for_mqc
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    compute_gene_scores.R \\
    $gene_score_yaml \\
    $normalized_counts \\
    $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-tibble: \$(Rscript -e "library(tibble); cat(as.character(packageVersion('tibble')))")
        r-singscore: \$(Rscript -e "library(singscore); cat(as.character(packageVersion('singscore')))")
        r-GSVA: \$(Rscript -e "library(GSVA); cat(as.character(packageVersion('GSVA')))")
        r-yaml: \$(Rscript -e "library(yaml); cat(as.character(packageVersion('yaml')))")
        r-FactoMineR: \$(Rscript -e "library(FactoMineR); cat(as.character(packageVersion('FactoMineR')))")
        r-stringr: \$(Rscript -e "library(stringr); cat(as.character(packageVersion('stringr')))")
    END_VERSIONS
    """

    stub:
    """
    touch scores_for_mqc.txt
    touch signature_scores_qc_mqc.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-dplyr: \$(Rscript -e "library(dplyr); cat(as.character(packageVersion('dplyr')))")
        r-tibble: \$(Rscript -e "library(tibble); cat(as.character(packageVersion('tibble')))")
        r-singscore: \$(Rscript -e "library(singscore); cat(as.character(packageVersion('singscore')))")
        r-GSVA: \$(Rscript -e "library(GSVA); cat(as.character(packageVersion('GSVA')))")
        r-yaml: \$(Rscript -e "library(yaml); cat(as.character(packageVersion('yaml')))")
        r-FactoMineR: \$(Rscript -e "library(FactoMineR); cat(as.character(packageVersion('FactoMineR')))")
        r-stringr: \$(Rscript -e "library(stringr); cat(as.character(packageVersion('stringr')))")
    END_VERSIONS
    """

}
