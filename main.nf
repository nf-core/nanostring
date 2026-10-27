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
include { getGenomeAttribute      } from './subworkflows/local/utils_nfcore_nanostring_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

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
    samplesheet // channel: samplesheet read in from --input

    main:

    //
    // WORKFLOW: Run pipeline
    //
    NANOSTRING (
        samplesheet,
        channel.from(file(params.input)).map{ input -> tuple( [id: file(params.input).getName()], input) }
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
    // WORKFLOW: Run main workflow
    //
    NFCORE_NANOSTRING (
        PIPELINE_INITIALISATION.out.samplesheet
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
