//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_rcc_channel(it) }
        .set { counts }

    emit:
    counts                                    // channel: [ val(meta), file(counts_file) ]
    sample_sheet = SAMPLESHEET_CHECK.out.csv  // channel: [ samplesheet.valid.csv ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample
    meta.single_end = row.single_end.toBoolean()

    // add path(s) of the fastq file(s) to the meta map
    def fastq_meta = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (meta.single_end) {
        fastq_meta = [ meta, [ file(row.fastq_1) ] ]
    } else {
        if (!file(row.fastq_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
        fastq_meta = [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
    }
    return fastq_meta
}

def create_rcc_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id = row.SAMPLE_ID
    meta.filename = row.RCC_FILE_NAME
    meta.time = row.TIME
    meta.treatment = row.TREATMENT
    meta.include = row.INCLUDE
    meta.metadata = row.OTHER_METADATA

    // add path(s) of the rcc file(s) to the meta map
    if (!file(row.RCC_FILE).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> RCC file does not exist!\n${row.RCC_FILE}"
    }

    return [ meta, file(row.RCC_FILE) ]
}

