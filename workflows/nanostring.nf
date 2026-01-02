/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT CONFIGS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_gene_score_yaml         = params.gene_score_yaml   ? Channel.fromPath( params.gene_score_yaml, checkIfExists: true ) : Channel.empty()
ch_heatmap_genes_to_filter   = params.heatmap_genes_to_filter  ? Channel.fromPath( params.heatmap_genes_to_filter, checkIfExists: true ) : Channel.empty()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOWS: Consisting of a mix of local and nf-core/modules
//
include { methodsDescriptionText      } from '../subworkflows/local/utils_nfcore_nanostring_pipeline'
include { QUALITY_CONTROL             } from '../subworkflows/local/quality_control'
include { NORMALIZE                   } from '../subworkflows/local/normalize'
include { COMPUTE_GENE_SCORES_HEATMAP } from '../subworkflows/local/compute_gene_scores_heatmap'

//
// MODULES
//
include { CREATE_ANNOTATED_TABLES } from '../modules/local/create_annotated_tables'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { MULTIQC                } from '../modules/nf-core/multiqc/main'

include { paramsSummaryMap       } from 'plugin/nf-schema'

include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NANOSTRING {

    take:
    ch_samplesheet   // channel: [ meta, rcc_path ]
    samplesheet_path // channel: [ meta, path/to/samplesheet ]

    main:

<<<<<<< HEAD
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

=======
    ch_versions = channel.empty()
    ch_multiqc_files = channel.empty()
>>>>>>> origin/nf-core-template-merge-3.5.1
    //
    // INPUT RCC FILES
    //
    ch_samplesheet
        .map { meta, rcc_path -> rcc_path}
        .collect()
        .map{ rcc_path ->
            tuple( [ id: file(params.input).getName() ], rcc_path )
        }
        .set{ rcc_files }

    //
    // SUBWORKFLOW: Quality control of input files
    //
    QUALITY_CONTROL (
        rcc_files,
        samplesheet_path.first()
    )
    ch_versions      = ch_versions.mix(QUALITY_CONTROL.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(QUALITY_CONTROL.out.nacho_qc_multiqc_metrics.collect())

    //
    // SUBWORKFLOW: Normalize data
    //
    NORMALIZE (
        rcc_files,
        samplesheet_path.first()
    )
    ch_versions         = ch_versions.mix(NORMALIZE.out.versions)
    ch_normalized       = NORMALIZE.out.normalized_counts
    ch_normalized_wo_hk = NORMALIZE.out.normalized_counts_wo_HK

    //
    // MODULE: Annotate normalized counts with metadata from the samplesheet
    //
    CREATE_ANNOTATED_TABLES (
        ch_normalized.mix(ch_normalized_wo_hk).toSortedList{ a, b -> a[1].getName() <=> b[1].getName() }.flatMap(), // Order tuples (based on file name) to stabilize tests and reproducibility
        samplesheet_path.first()
    )
    ch_versions            = ch_versions.mix(CREATE_ANNOTATED_TABLES.out.versions)
    ch_annotated_endo_data = CREATE_ANNOTATED_TABLES.out.annotated_endo_data
    ch_multiqc_files       = ch_multiqc_files.mix(CREATE_ANNOTATED_TABLES.out.annotated_data_mqc.map{it[1]}.collect())

    //
    // Run compute gene scores and plot heatmap subworkflow
    //
    COMPUTE_GENE_SCORES_HEATMAP (
        ch_normalized,
        ch_annotated_endo_data,
        ch_gene_score_yaml,
        ch_heatmap_genes_to_filter,
        params.skip_heatmap
    )
    ch_versions      = ch_versions.mix(COMPUTE_GENE_SCORES_HEATMAP.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(COMPUTE_GENE_SCORES_HEATMAP.out.multiqc_files)

    //
    // Collate and save software versions
    //
    def topic_versions = Channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'nanostring_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        channel.fromPath(params.multiqc_config, checkIfExists: true) :
        channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        []
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
