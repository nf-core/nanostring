//
// Perform normalizations (currently using Nacho)
//

include { NACHO_NORMALIZE } from '../../modules/local/nacho/normalize'

workflow NORMALIZE {
    take:
    counts      // channel: [ meta, path(rcc) ]
    samplesheet // file: /path/to/samplesheet.csv

    main:
    NACHO_NORMALIZE ( counts, samplesheet )

    emit:
    nacho_qc_reports = NACHO_NORMALIZE.out.nacho_qc_reports                              // channel: [ val(meta), [ counts ] ]
    nacho_qc_multiqc_metrics = NACHO_NORMALIZE.out.nacho_qc_multiqc_metrics  // channel: [ samplesheet.valid.csv ]
    versions = NACHO_NORMALIZE.out.versions // channel: [ versions.yml ]
}
