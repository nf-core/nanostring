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
    normalized_counts = NACHO_NORMALIZE.out.normalized_counts                              // channel: [ val(meta), [ counts ] ]
    normalized_counts_wo_HK = NACHO_NORMALIZE.out.normalized_counts_wo_HK  // channel: [ samplesheet.valid.csv ]
    versions = NACHO_NORMALIZE.out.versions // channel: [ versions.yml ]
}
