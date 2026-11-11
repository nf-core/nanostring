#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/nanostring
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/nanostring
    Website: https://nf-co.re/nanostring
    Slack  : https://nfcore.slack.com/channels/nanostring
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { NANOSTRING              } from './workflows/nanostring'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_nanostring_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_nanostring_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_NANOSTRING {

    take:
    samplesheet                 // channel: samplesheet read in from --input
    samplesheet_path            // channel: [ meta, path/to/samplesheet ]
    gene_score_yaml             // channel: [ path(gene_score_yaml) ] (or empty)
    heatmap_genes_to_filter     // channel: [ path(heatmap_genes_to_filter) ] (or empty)
    skip_heatmap                // boolean: skip the gene heatmap
    multiqc_config              // list:    MultiQC config files
    multiqc_logo                // path:    MultiQC logo (or empty list)
    multiqc_methods_description // path:    MultiQC methods description template

    main:

    //
    // WORKFLOW: Run pipeline
    //
    NANOSTRING (
        samplesheet,
        samplesheet_path,
        gene_score_yaml,
        heatmap_genes_to_filter,
        skip_heatmap,
        multiqc_config,
        multiqc_logo,
        multiqc_methods_description
    )

    emit:
    nacho_qc_html       = NANOSTRING.out.nacho_qc_html
    nacho_qc_png        = NANOSTRING.out.nacho_qc_png
    nacho_qc_txt        = NANOSTRING.out.nacho_qc_txt
    normalized_counts   = NANOSTRING.out.normalized_counts
    normalized_counts_wo_hk = NANOSTRING.out.normalized_counts_wo_hk
    annotated_endo_data = NANOSTRING.out.annotated_endo_data
    annotated_hk_data   = NANOSTRING.out.annotated_hk_data
    gene_scores         = NANOSTRING.out.gene_scores
    gene_heatmaps       = NANOSTRING.out.gene_heatmaps
    multiqc_report      = NANOSTRING.out.multiqc_report
    multiqc_data        = NANOSTRING.out.multiqc_data
    multiqc_plots       = NANOSTRING.out.multiqc_plots
    software_versions   = NANOSTRING.out.software_versions
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input,
        params.help,
        params.help_full,
        params.show_hidden
    )

    //
    // Resolve pipeline parameters into files and channels
    //
    input_samplesheet           = file(params.input)
    ch_samplesheet_path         = channel.value(tuple([id: input_samplesheet.getName()], input_samplesheet))
    ch_gene_score_yaml          = params.gene_score_yaml ? channel.fromPath(params.gene_score_yaml, checkIfExists: true) : channel.empty()
    ch_heatmap_genes_to_filter  = params.heatmap_genes_to_filter ? channel.fromPath(params.heatmap_genes_to_filter, checkIfExists: true) : channel.empty()
    multiqc_config              = [file("$projectDir/assets/multiqc_config.yml", checkIfExists: true)] +
        (params.multiqc_config ? [file(params.multiqc_config, checkIfExists: true)] : [])
    multiqc_logo                = params.multiqc_logo ? file(params.multiqc_logo, checkIfExists: true) : []
    multiqc_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_NANOSTRING (
        PIPELINE_INITIALISATION.out.samplesheet,
        ch_samplesheet_path,
        ch_gene_score_yaml,
        ch_heatmap_genes_to_filter,
        params.skip_heatmap,
        multiqc_config,
        multiqc_logo,
        multiqc_methods_description
    )
    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        NFCORE_NANOSTRING.out.multiqc_report
    )

    publish:
    nacho_qc_html       = NFCORE_NANOSTRING.out.nacho_qc_html
    nacho_qc_png        = NFCORE_NANOSTRING.out.nacho_qc_png
    nacho_qc_txt        = NFCORE_NANOSTRING.out.nacho_qc_txt
    normalized_counts   = NFCORE_NANOSTRING.out.normalized_counts
    normalized_counts_wo_hk = NFCORE_NANOSTRING.out.normalized_counts_wo_hk
    annotated_endo_data = NFCORE_NANOSTRING.out.annotated_endo_data
    annotated_hk_data   = NFCORE_NANOSTRING.out.annotated_hk_data
    gene_scores         = NFCORE_NANOSTRING.out.gene_scores
    gene_heatmaps       = NFCORE_NANOSTRING.out.gene_heatmaps
    multiqc_report      = NFCORE_NANOSTRING.out.multiqc_report
    multiqc_data        = NFCORE_NANOSTRING.out.multiqc_data
    multiqc_plots       = NFCORE_NANOSTRING.out.multiqc_plots
    software_versions   = NFCORE_NANOSTRING.out.software_versions
}

output {
    nacho_qc_html {
        path 'QC/NACHO'
    }
    nacho_qc_png {
        path 'QC/NACHO/png'
    }
    nacho_qc_txt {
        path 'QC/NACHO'
    }
    normalized_counts {
        path 'normalized_counts'
    }
    normalized_counts_wo_hk {
        path 'normalized_counts'
    }
    annotated_endo_data {
        path 'annotated_tables'
    }
    annotated_hk_data {
        path 'annotated_tables'
    }
    gene_scores {
        path 'gene_scores'
    }
    gene_heatmaps {
        path 'gene_heatmaps'
    }
    multiqc_report {
        path 'multiqc'
    }
    multiqc_data {
        path 'multiqc'
    }
    multiqc_plots {
        path 'multiqc'
    }
    software_versions {
        path 'pipeline_info'
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
