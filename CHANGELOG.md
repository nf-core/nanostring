# nf-core/nanostring: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## dev

### `Added`

- [#95](https://github.com/nf-core/nanostring/pull/95) - Add pipeline level nf-tests.

## v1.3.0 - 2024-08-27 - Micrometre

### `Added`

- [#66](https://github.com/nf-core/nanostring/pull/66) - Updated to nf-core template 2.12.1
- [#71](https://github.com/nf-core/nanostring/pull/71) - Updated to nf-core template 2.13.1
- [#73](https://github.com/nf-core/nanostring/pull/73) - Updated to nf-core template 2.14.1

### `Fixed`

- [#65](https://github.com/nf-core/nanostring/pull/65) - Issue with `CREATE_GENE_HEATMAP` if no list of genes was provided

### `Changed`

- [#71](https://github.com/nf-core/nanostring/pull/71) - Made column `RCC_FILE_NAME` mandatory
- [#78](https://github.com/nf-core/nanostring/pull/78) - Added Nanostring Tubemap original designfile to repository for future changes, fixed typo and removed version in picture

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `multiqc`  | 1.19        | 1.24.1      |

## v1.2.1 - 2024-01-18 - Nanometre

### `Added`

- [#55](https://github.com/nf-core/nanostring/pull/55) - Added the Bioinformatics publication to the citation list
- [#55](https://github.com/nf-core/nanostring/pull/55) - Updated to nf-core template 2.11.1
- [#58](https://github.com/nf-core/nanostring/pull/58) - Granularized the containers for NACHO and Heatmaps

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `nacho`    | 2.0.5       | 2.0.6       |

## v1.2.0 - 2023-08-24 - Nanometre

### `Added`

- [#48](https://github.com/nf-core/nanostring/pull/48) - Allow users to specify id column for heatmap [#39](https://github.com/nf-core/nanostring/issues/39)
- [#46](https://github.com/nf-core/nanostring/pull/46) - Update to nf-core template `2.9`
- [#42](https://github.com/nf-core/nanostring/pull/42) - Allow users to specify normalization method: `GEO` (default) or `GLM`

### `Fixed`

- [#51](https://github.com/nf-core/nanostring/pull/51) - Prevent HK-normalization while loading counts
- [#51](https://github.com/nf-core/nanostring/pull/51) - Use provided normalization method for Non-HK-normalized counts
- [#46](https://github.com/nf-core/nanostring/pull/46) - Publish `NACHO` QC reports [#44](https://github.com/nf-core/nanostring/issues/44)
- [#47](https://github.com/nf-core/nanostring/pull/47) - Update `NACHO` R package including bug fix [#45](https://github.com/nf-core/nanostring/issues/45)
- [#47](https://github.com/nf-core/nanostring/pull/47) - Set correct `conda` environment for `COMPUTE_GENE_SCORES` process

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `nacho`    | 2.0.4       | 2.0.5       |

### `Deprecated`

## v1.1.1 - 2023-06-23

### `Added`

- [#37](https://github.com/nf-core/nanostring/pull/37) - Allow skipping heatmap creation [#38](https://github.com/nf-core/nanostring/issues/38)

### `Fixed`

- [#37](https://github.com/nf-core/nanostring/pull/37) - Use unique rownames for Heatmap creation

### `Dependencies`

### `Deprecated`

## v1.1.0 - 2023-06-22 - Picometre

### `Added`

- [#33](https://github.com/nf-core/nanostring/pull/33) - Add functionality to generate gene-count heatmaps [#17](https://github.com/nf-core/nanostring/issues/17)
- [#32](https://github.com/nf-core/nanostring/pull/32) - Add functinoality to compute gene scores [#16](https://github.com/nf-core/nanostring/issues/16)

### `Fixed`

### `Dependencies`

### `Deprecated`

## v1.0.0 - 2023-06-12 - Femtometre

Initial release of nf-core/nanostring, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- [#21](https://github.com/nf-core/nanostring/pull/21) - Add quality control using [NACHO](https://github.com/mcanouil/NACHO/) [#11](https://github.com/nf-core/nanostring/issues/11)
- [#21](https://github.com/nf-core/nanostring/pull/21) - Add normalization with and without Housekeeping genes using [NACHO](https://github.com/mcanouil/NACHO/) [#12](https://github.com/nf-core/nanostring/issues/12)
- [#21](https://github.com/nf-core/nanostring/pull/21) - Add tests and respective test data [#19](https://github.com/nf-core/nanostring/issues/19)
- [#23](https://github.com/nf-core/nanostring/pull/23) - Add tables with non-housekeeping-normalized counts to MultiQC report

### `Fixed`

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `nacho`    | -           | 2.0.4       |

### `Deprecated`
