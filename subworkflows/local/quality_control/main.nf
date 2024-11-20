//
// Perform quality control
//

include { NACHO_QC } from '../../../modules/local/nacho/qc/main.nf'

workflow QUALITY_CONTROL {
    take:
    counts      // channel: path(rcc files)
    samplesheet // file: /path/to/samplesheet.csv

    main:
    NACHO_QC ( counts, samplesheet )

    emit:
    nacho_qc_multiqc_metrics = NACHO_QC.out.nacho_qc_multiqc_metrics // channel: [ .png and .txt mqc files ]
    versions                 = NACHO_QC.out.versions                 // channel: [ versions.yml ]
}
