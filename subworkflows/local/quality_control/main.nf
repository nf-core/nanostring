//
// Perform quality control
//

include { NACHO_QC } from '../../../modules/nf-core/nacho/qc/main'

workflow QUALITY_CONTROL {
    take:
    counts      // channel: [ meta, [rcc files] ]
    samplesheet // channel: [ meta, path/to/samplesheet.csv ]

    main:
    NACHO_QC ( counts, samplesheet )

    emit:
    nacho_qc_multiqc_metrics = NACHO_QC.out.nacho_qc_png.map{it[1]}.mix(NACHO_QC.out.nacho_qc_txt.map{it[1]}) // channel: [ .png and .txt mqc files ]
    versions                 = NACHO_QC.out.versions                                                          // channel: [ versions.yml ]
}
