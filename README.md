

# longrnaseq

![Just keep smiling](assets/pipeline.png)

## Introduction

**longrnaseq** is a bioinformatics pipeline that processes long-read RNA sequencing data. The pipeline performs quality control, alignment, classification, contamination detection, and transcript quantification for long-read RNA-seq data from multiple samples. This pipeline is part of the [LongPolyASE](https://polyase.readthedocs.io/en/latest/index.html) framework for long-read RNA-seq allele-specific expression analysis in polyploid organisms. 

The pipeline includes the following main steps:

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Present QC for samples ([`MultiQC`](http://multiqc.info/))
3. Genome alignment ([`Minimap2`](https://github.com/lh3/minimap2))
4. Contamination detection ([`Centrifuge`](https://ccb.jhu.edu/software/centrifuge/))
5. Comparion of samples by transcript classification ([`SQANTI-reads`](https://github.com/ConesaLab/SQANTI3))
6. Transcript quantification ([`Oarfish`](https://github.com/COMBINE-lab/oarfish)) and gene-level summarization

## Dependencies

An environment with nextflow (>=24.04.2) and Singularity installed.

**Note:** If you want to run SQANTI-reads quality control, you will also need to:
- Install all [SQANTI3 dependencies](https://github.com/ConesaLab/SQANTI3/blob/master/SQANTI3.conda_env.yml) in the same environment as nextflow/nf-core environment (sorry there is not functional container for nextflow at the moment..)
*Important*: for converting output to html poppler also need to be installed: conda install poppler
- Clone the [SQANTI3 git repository](https://github.com/ConesaLab/SQANTI3)(>=5.5.1) and provide the directory as input.

For running Centrifuge, you also need to create a [Centrifuge database](https://ccb.jhu.edu/software/centrifuge/manual.shtml).

Both of these can be skipped with `--skip_sqanti` and `--skip_centrifuge`

## Usage

1) Clone the repository of the pipeline `git clone https://github.com/nadjano/longrnaseq.git`


2) Prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1
SAMPLE1,sample1.fastq.gz
SAMPLE2,sample2.fastq.gz
```

Each row represents a sample with one fastq file.

## Running the Pipeline


### Required Parameters

The pipeline requires the following mandatory parameters:
- `--input`: Path to samplesheet CSV file
- `--outdir`: Output directory path
- `--fasta`: Path to reference genome FASTA file
- `--gtf`: Path to GTF annotation file (for BAMBU to get the right output with gene_id!)
- `--centrifuge_db`: Path to Centrifuge database
- `--sqanti_dir`: Path to SQANTI3 directory
- `--technology`: ONT (Oxford Nanopore) or PacBio, sets minimap2 parameters for read mapping


*Note about gtf file*
gtf-version 3
should include features: gene, transcript, exon, CDS

### Profile Support

Currently, only the `singularity` profile is supported. Use `-profile singularity` in your command.

### Example Command

```bash
nextflow run main.nf -resume -profile singularity \
    --input assets/samplesheet.csv \
    --outdir results \
    --fasta /path/to/genome.fa \
    --gtf /path/to/annotation.gtf \
    --centrifuge_db /path/to/centrifuge_db \
    --sqanti_dir /path/to/sqanti3 \
    --technology ONT/PacBio

```
##
### Optional Parameters
- `--skip_deseq2_qc`: Skip deseq2, when only one sample is present deseq2 will fail [default: false]
- `--skip_sqanti`: Skip sqanit and sqanti reads [default: false]
- `--skip_centrifuge`: Skip centrigure [default: false]
- `-bg`: Run pipeline in background
- `-resume`: Resume previous run from where it left off
- `--downsample_rate`: fraction between 0-1 for downsampling before running SQANTI3 to reduce runtime and for vizualization to have smaller files [default: 0.05]
- `--large_genome`: In case minimap2 fails druing genome indexing, this can be due to large genomes and long chromosomes. [default: false]

## Pipeline output

The main output is a MultiQC.html and oarfish transcript and gene counts.

An example MultiQC report can be found [here](https://github.com/nadjano/longrnaseq/blob/master/example_output/multiqc_report.html)


## Tutorial

https://polyase.readthedocs.io/en/latest/tutorial_rice.html#part-4-long-read-rna-seq-analysis

## Credits

nf-core/plantlongrnaseq was originally written by Nadja Nolte.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please get in touch nadja.franziska.nolte[at]nib.si

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use nf-core/plantlongrnaseq for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).


## Running on HPC

For running the pipeline on a HPC (e.g SLURM) you need to add some configuartion to the nextflow.config file

e.g 
```bash
process.executor = 'slurm'
process.clusterOptions = '--qos=short' # if you have to submit to a specific queue
```

## Test Run

A test dataset is available for testing and demonstration purposes. This dataset contains a phased genome assembly and annotation for chromosome 1 across all haplotypes of the tetraploid potato cultivar Atlantic.

* long-read RNA-seq fastq files:
    Download from SRA the samples ONT SRR14993893 and SRR14993894.
* genome and annotation files:
    [fasta](https://zenodo.org/records/17590760/files/ATL_v3.asm.chr01_all_haplotypes.fa.gz?download=1&preview=1) and [gtf](https://zenodo.org/records/17590760/files/ATL_unitato_liftoff.chr01_all_haplotypes.gtf.gz?download=1&preview=1)

First add samples to sample sheet, download the annotation files and then run the pipeline like this:

```bash
nextflow run main.nf -profile singularity \
                     --input assets/samplesheet.csv \
                     --outdir output_test \
                     --fasta test_data/ATL_v3.asm.with_chloroplast_and_mito.fa \
                     --gtf  test_data/unitato2Atl.with_chloroplast_and_mito.no_scaffold.agat.gtf \
                     --technology ONT \
                     --downsample_rate 0.99 \
                     --skip_centrifuge \
                     --skip_sqanti \
                     -resume 
```

This should finish in less than one hour (running with 30 cpu) including pulling of singularity images.


## Troubleshooting

- if sqanit3_reads fails with an error like this ``"ImportError: /lib/x86_64-linux-gnu/libstdc++.so.6: version CXXABI_1.3.15' not found"` try running in the provided conda envrionment `sqanti3.yaml`
- if BAMBU fails check your gtf file and make sure it contains `gene_id`
