/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT CONFIGS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_gene_score_config         = params.gene_score_yaml   ? Channel.fromPath( params.gene_score_yaml, checkIfExists: true ) : Channel.empty()
ch_heatmap_genes_to_filter   = params.heatmap_genes_to_filter  ? Channel.fromPath( params.heatmap_genes_to_filter, checkIfExists: true ) : Channel.empty()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOWS: Consisting of a mix of local and nf-core/modules
//
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_nanostring_pipeline'
include { QUALITY_CONTROL }        from '../subworkflows/local/quality_control'
include { NORMALIZE }              from '../subworkflows/local/normalize'

//
// MODULES
//
include { CREATE_ANNOTATED_TABLES } from '../modules/local/create_annotated_tables'
include { COMPUTE_GENE_SCORES     } from '../modules/local/compute_gene_scores'
include { CREATE_GENE_HEATMAP     } from '../modules/local/create_gene_heatmap'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { MULTIQC                } from '../modules/nf-core/multiqc/main'

include { paramsSummaryMap       } from 'plugin/nf-validation'

include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NANOSTRING {

    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    //
    // INPUT RCC FILES
    //
    ch_samplesheet
        .map { meta, path -> path}.collect()
        .set{ rcc_files }

    //
    // SUBWORKFLOW: Quality control of input files
    //
    QUALITY_CONTROL (
        rcc_files,
        ch_samplesheet
    )
    ch_versions = ch_versions.mix(QUALITY_CONTROL.out.versions)

    //
    // SUBWORKFLOW: Normalize data
    //
    NORMALIZE (
        rcc_files,
        ch_samplesheet
    )
    ch_versions = ch_versions.mix(NORMALIZE.out.versions)


    //
    // MODULE: Annotate normalized counts with metadata from the samplesheet
    //
    CREATE_ANNOTATED_TABLES (
        NORMALIZE.out.normalized_counts.mix(NORMALIZE.out.normalized_counts_wo_HK),
        ch_samplesheet
    )
    ch_versions = ch_versions.mix(CREATE_ANNOTATED_TABLES.out.versions)

    //
    // MODULE: Compute gene scores for supplied YAML gene score file
    //
    COMPUTE_GENE_SCORES(
        NORMALIZE.out.normalized_counts,
        ch_gene_score_config
    )
    ch_versions = ch_versions.mix(COMPUTE_GENE_SCORES.out.versions)

    //
    // MODULE: Compute gene-count heatmap for MultiQC report based on annotated (ENDO) counts
    //
    if(!params.skip_heatmap){
        CREATE_GENE_HEATMAP (
        CREATE_ANNOTATED_TABLES.out.annotated_endo_data,
        NORMALIZE.out.normalized_counts,
        ch_heatmap_genes_to_filter.toList()
        )
        ch_versions       = ch_versions.mix(CREATE_GENE_HEATMAP.out.versions)
        ch_multiqc_files  = ch_multiqc_files.mix(CREATE_GENE_HEATMAP.out.gene_heatmap.collect())
    }

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(storeDir: "${params.outdir}/pipeline_info", name: 'nf_core_pipeline_software_mqc_versions.yml', sort: true, newLine: true)
        .set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    ch_multiqc_config                     = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config              = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()
    ch_multiqc_logo                       = params.multiqc_logo ? Channel.fromPath(params.multiqc_logo, checkIfExists: true) : Channel.empty()
    summary_params                        = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary                   = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml', sort: false))
    ch_multiqc_files                      = ch_multiqc_files.mix(QUALITY_CONTROL.out.nacho_qc_multiqc_metrics.collect())
    ch_multiqc_files                      = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    ch_multiqc_files                      = ch_multiqc_files.mix(COMPUTE_GENE_SCORES.out.scores_for_mqc.collect())
    ch_multiqc_files                      = ch_multiqc_files.mix(CREATE_ANNOTATED_TABLES.out.annotated_data_mqc.collect())

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )

    emit:
    multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
