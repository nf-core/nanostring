# nf-core/nanostring: Output

This document describes the output produced by the pipeline.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/)
and processes data using the following steps:

* [NachoQC](#nachoqc) - compute QC metrics for Nanostring data, assess data quality
* [Normalize](#normalize) - computes normalized gene counts given RCC files
* [Annotate](#annotate) - annotates the normalized gene counts with metadata from samplesheet
* [Boxplots](#boxplots) - creates boxplots for the normalized gene expression data
* [nSolver Visualize](#nsolver) - creates heatmaps for nSolver Pathway and Celltype Scores provided
* [Gene Scores](#genescores) - creates gene scores based on supplied gene sets
* [MultiQC](#multiqc) - aggregate report, describing results of the whole pipeline

## NACHO QC

This step uses the NACHO Nanostring analysis package to perform basic QC of the input RCC files. Several quality metrics are created and the majority of these are available in the MultiQC report.These have been created using the `bin/nanoQC.R` script in the pipeline. In addition to this, the output also has two NACHO reports, once with outliers highlighted and once without highlighting outliers in the visualizations:

**Output directory: `results/QC`**

* `NanoQC.html`
  * Basic Nacho QC report - a standalone HTML file that can be viewed in your web browser
* `NanoQC_with_outliers.html`
  * The same as above, but with highlighted outliers

## Normalize

This holds the normalized gene expression data, normalized using an in-house Python Script.

**Output directory: `results/Normalized_Data/`**

* `normalized_qc_mqc.tsv`
  * QC Results of the normalization method applied. This is also shown in table format in the MultiQC table and usually there is no need to have a look at this.
* `normalized_counts.tsv`
  * Normalized gene expression matrix, unmodified.
* `normalized_counts_wo_HK.tsv`
  * Normalized gene expression matrix but without Housekeeper Normalization applied, unmodified. DO NOT USE THIS IF YOU DO NOT KNOW WHAT THIS MEANS.

## Annotate

This holds the normalized and annotated gene expression data. There are always two tables - one for endogenous genes of interest, one for housekeeping genes. Negative and positive control spike ins are filtered out already in this step as these are only of importance for QC analysis. Annotation is performed using the custom script `bin/write_out_prepared_gex.R` in the pipeline.

**Output directory: `results/annotated_gex_tables/`**

* `*GEX_HK_mqc.tsv`
  * TSV table holding all housekeeping gene expression values with annotation.
* `*GEX_ENDO.tsv`
  * TSV table holding the endogenous gene expression values with annotation.

## nSolver

If the pipeline was provided with Pathway and CellType score tables from Nanostring nSolver v4.0+, the pipeline can produce a heatmap for these types of data and integrates this automatically in the MultiQC report. Note, that this requires loading all of the RCC files into nSolver and performing an "Advanced Analysis" manually in that software - this pipeline cannot automate these steps unfortunately.

## Boxplots

Directory holding boxplots for various categories on the normalized gene expression data. Depending on available metadata columns, this typically has subfolders that contain per-gene or per SAMPLE_ID boxplots. These have been created using the `bin/boxplots_expression.R` script in the pipeline.

**Output directory: `results/expression_boxplots/`**

* `SAMPLE_ID`
  * Grouping based on SAMPLE_ID (each SAMPLE on X-Axis), Gene on Y axis
* `TIME`
  * Gene expression grouped by TIME points. If only one, only one is used.
* `TREATMENT`
  * Gene expression per treatment, if only one available, only one is used.
* `EXTRA_GROUP`
  * If multiple extra groups are availble - each of these extra groups gets a separate grouping boxplot.


## Genescores

The pipeline creates gene scores based on a user-provided YAML file (see usage documentation for this and an example).
The results have been created using the `bin/perform_gene_score_analysis.R` script in the pipeline.

**Output directory: `results/gene_set_scores`**

* `gene_scores.tsv`
  * Contains gene scores computed for all samples
  * Multiple scores in the YAML create multiple lines in the TSV file
  * Results are also tabularized in the subsequent MultiQC report

## MultiQC

[MultiQC](http://multiqc.info) is a visualisation tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in within the report data directory.

The pipeline has special steps which allow the software versions used to be reported in the MultiQC output for future traceability.

**Output directory: `results/MultiQC`**

* `DATE_TIME_nanostring_Report.html`
  * MultiQC report - a standalone HTML file that can be viewed in your web browser
* `DATE_TIME_nanostring_Report_data/`
  * Directory containing parsed statistics from the different tools used in the pipeline
* `DATE_TIME_nanostring_Report_plots/`
  * Directory containing the plots that MultiQC created (if any).

For more information about how to use MultiQC reports, see [http://multiqc.info](http://multiqc.info)


<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
