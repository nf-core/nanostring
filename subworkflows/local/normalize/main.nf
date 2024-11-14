//
// Perform normalizations (currently using Nacho)
//

include { NACHO_NORMALIZE } from '../../../modules/local/nacho/normalize'

workflow NORMALIZE {
    take:
    counts      // channel: path(rcc files)
    samplesheet // file: /path/to/samplesheet.csv

    main:
    NACHO_NORMALIZE ( counts, samplesheet )

    emit:
    normalized_counts       = NACHO_NORMALIZE.out.normalized_counts        // channel: [ normalized_counts.tsv ]
    normalized_counts_wo_HK = NACHO_NORMALIZE.out.normalized_counts_wo_HK  // channel: [ normalized_counts_wo_HK.tsv ]
    versions                = NACHO_NORMALIZE.out.versions                 // channel: [ versions.yml ]
}
