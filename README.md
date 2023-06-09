## Introduction

**Streit-lab/enhancer_annotation_and_motif_analysis** is a bioinformatic analysis pipeline for identifying enhancers associated to genes of interest and screening for motif binding sites.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a portable, reproducible manner.

## Pipeline summary

1. Conditionally unzip genome (--fasta) and GTF/GFF (--gtf or --gff) files
2. Index genome in order to retrieve chromosome lengths
3. Filter genes of interest (--gene_list) from GTF and filter gene biotype entries in GTF/GFF
4. Conditionally extend length of peaks (--peaks) by a given length (--extend_peaks)
5. Assign TSS to peaks:

   a) Assign TSS to peaks if they fall within CTCF sites flanking the peak of interest:
      1. For each peak retrieve nearest CTCF sites upstream (CTCF start site) and downstream (CTCF end site)
      2. Sort flanking CTCF coordinates
      3. Annotate peaks to TSS within flanking CTCF sites

   b) Assign TSS to peaks if they fall within an x.kb window of the peak of interest

6. Retrieve filtered peak fasta sequences
7. Calculate background base frequencies for motif screening
8. Identify motif binding sites in peaks ([`fimo`](https://meme-suite.org/meme/doc/fimo.html))
9. Annotate peak-motif file with nearby genes

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.3`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)).

3. Download the pipeline

   ```bash
   nextflow pull Streit-lab/enhancer_annotation_and_motif_analysis
   ```

4. Test the pipeline on a minimal dataset with a single command:

   ```bash
   nextflow run Streit-lab/enhancer_annotation_and_motif_analysis \
      -r main \
      -profile test,docker \
      --outdir output
   ```

5. Start running your own analysis!

   - Typical command for Streit-lab/enhancer_annotation_and_motif_analysis analysis:

   ```bash
   nextflow run Streit-lab/enhancer_annotation_and_motif_analysis \
      -r main \
      --fasta <FASTA_PATH_OR_URL> \
      --gtf <GTF_PATH_OR_URL> \
      --peaks_bed <PEAK_BED_FILE> \
      -profile <docker/singularity/conda>
   ```
   
   > - The pipeline comes with config profiles called `docker`, `singularity` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
   > - If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
   > - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.


## Pipeline parameters

`--fasta`
   > *Required*. Path or URL to fasta file, can be gzipped.

</br>

`--gtf` or `--gff`
   > *Required*. Path or URL to GTF or GFF file, can be gzipped.



`--peaks_bed`
   > *Required*. Path to peak file in BED format. First four columns must contain; chrom, start, end, peakid. [`Example file`](https://github.com/Streit-lab/enhancer_annotation_and_motif_analysis/blob/main/test_data/peaks.bed).

</br>

`--gene_ids`
   > *Optional*. List of gene ids present in GTF to screen for enhancers and motifs. One gene id per line. [`Example file`](https://github.com/Streit-lab/enhancer_annotation_and_motif_analysis/blob/main/test_data/gene_ids.txt). If --gene_ids is not specified, all gene_ids will be extracted from the GTF or GFF. Default = null.

</br>

`--extend_peaks`
   > *Optional*. Number of bases by which to extend peaks (up and downstream). Default = 0.

</br>

`--enhancer_window`
   > *Optional*. Distance from TSS in GTF or GFF within which enhancers are screened. Default = 50000.

</br>

`--ctcf`
   > *Optional*. BED file containing co-ordinates for CTCF peaks to use for annotating enhancers to genes. If this argument is specified, the pipeline will annotate enhancers using CTCF windows rather than using `--enhancer_window`. Default = null.

</br>

`--motif_matrix`
   > *Optional*. By default the pipeline will screen against all motifs in the JASPAR core vertebrate non-redundant database `--motif_matrix jaspar_core_vert_nonredundant_motifs`. The redundant database can also be selected using `--motif_matrix jaspar_core_vert_redundant_motifs`. Alternatively, a path to matrix file in [`meme`](https://meme-suite.org/meme/doc/meme-format.html) format can also be provided. [`Example file`](https://github.com/Streit-lab/enhancer_annotation_and_motif_analysis/blob/main/test_data/six1_motifs.txt).

</br>

`--markov_background`
   > *Optional*. Markov background model used to define base frequencies for motif screening. This is calculated by default from the provided `--fasta` input.

</br>

`--fimo_pval`
   > *Optional*. p-value threshold used by FIMO for motif screening. Default = 0.0001.

</br>

`--gene_name_col`
   > *Optional*. Entry in GTF or GFF corresponding to gene names. Default = 'gene_name'.

</br>

`--gene_id_col`
   > *Optional*. Entry in GTF or GFF corresponding to gene IDs. Default = 'gene_id'.

</br>

`--skip_motif_analysis`
   > *Optional*. Boolean parameter which determines whether to run motif analysis after annotating enhancers. Default = false.

</br>

`--outdir`
   > *Optional*. Directory to output results to. Default = 'results'.