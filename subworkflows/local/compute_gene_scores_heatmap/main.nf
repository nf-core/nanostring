//
// Compute gene scores and plot heatmap
//

//
// MODULES
//
include { COMPUTE_GENE_SCORES     } from '../../../modules/local/compute_gene_scores'
include { CREATE_GENE_HEATMAP     } from '../../../modules/local/create_gene_heatmap'

workflow COMPUTE_GENE_SCORES_HEATMAP {
    take:
    normalized_counts      // channel: path(rcc files)
    ch_gene_score_config   // file: /path/to/samplesheet.csv
    annotated_endo_data
    ch_heatmap_genes_to_filter


    main:
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    //
    // MODULE: Compute gene scores for supplied YAML gene score file
    //
    COMPUTE_GENE_SCORES(
        normalized_counts,
        ch_gene_score_config
    )
    ch_versions      = ch_versions.mix(COMPUTE_GENE_SCORES.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(COMPUTE_GENE_SCORES.out.scores_for_mqc.collect())

    //
    // MODULE: Compute gene-count heatmap for MultiQC report based on annotated (ENDO) counts
    //
    if(!params.skip_heatmap){
        CREATE_GENE_HEATMAP (
            annotated_endo_data,
            normalized_counts,
            ch_heatmap_genes_to_filter.toList()
        )
        ch_versions       = ch_versions.mix(CREATE_GENE_HEATMAP.out.versions)
        ch_multiqc_files  = ch_multiqc_files.mix(CREATE_GENE_HEATMAP.out.gene_heatmap.collect())
    }

    emit:
    versions                = ch_versions                 // channel: [ versions.yml ]
    multiqc_files           = ch_multiqc_files
}
