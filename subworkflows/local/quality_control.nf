//
// Perform quality control
//

include { NACHO_QC } from '../../modules/local/nacho/qc'

workflow QUALITY_CONTROL {
    take:
    counts      // channel: [ meta, path(rcc) ]
    samplesheet // file: /path/to/samplesheet.csv

    main:
    NACHO_QC ( counts, samplesheet )

    emit:
    //nacho_qc_reports = NACHO_QC.out.nacho_qc_reports                              // channel: [ val(meta), [ counts ] ]
    nacho_qc_multiqc_metrics = NACHO_QC.out.nacho_qc_multiqc_metrics  // channel: [ samplesheet.valid.csv ]
    versions = NACHO_QC.out.versions // channel: [ versions.yml ]
}
