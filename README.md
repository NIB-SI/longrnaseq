

# longrnaseq

![Just keep smiling](assets/pipeline.png)

## Introduction

**longrnaseq** is a bioinformatics pipeline that processes long-read RNA sequencing data. The pipeline performs quality control, alignment, classification, contamination detection, and transcript quantification for long-read RNA-seq data from multiple samples. This pipeline is part of the [LongPolyASE](https://polyase.readthedocs.io/en/latest/index.html) framework for long-read RNA-seq allele-specific expression analysis in polyploid organisms. 

**Disclaimer**: this pipeline uses the nf-core template but it is not part of nf-core itself.

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
- Clone the [SQANTI3 git repository](https://github.com/ConesaLab/SQANTI3)(= v5.5.4) and provide the directory as input.

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

### Download long-read RNA-seq pipeline test data
```bash
conda install -c bioconda sra-tools
cd ..
mkdir -p test_data/rna_seq_reads
cd test_data/rna_seq_reads
fasterq-dump SRR14993892
fasterq-dump SRR14993893
```


### Clone the repository and prepare sample sheet
```bash
git clone https://github.com/NIB-SI/longrnaseq.git --branch v1.0.1
cd longrnaseq
touch assets/samplesheet_test.csv
cat > assets/samplesheet_test.csv << 'EOF'
sample,fastq_1
ATL_rep1,../test_data/rna_seq_reads/SRR14993892.fastq.gz
ATL_rep2,../test_data/rna_seq_reads/SRR14993893.fastq.gz
EOF
```

#### Set up the conda environment
```bash
# Install the sqanti3 requirements and nextflow in the longrnaseq conda environment (not necessary when running with --skip_sqanti)
conda env create -f sqanti3.yaml 
conda activate sqanti3
```

### Install SQANTI3
```bash
git clone https://github.com/ConesaLab/SQANTI3.git --branch v5.5.4
```

### Configure and run the pipeline
```bash
# For our system, we need to set the LD_LIBRARY_PATH to find the correct libraries
# Might not be necessary for other systems
# SQANTI3_ENV_LIB_DIR=$CONDA_PREFIX/lib
# export LD_LIBRARY_PATH="${SQANTI3_ENV_LIB_DIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

# If running on a cluster, make sure to adjust the nextflow.config file accordingly
# e.g., process.executor = 'slurm'

nextflow run main.nf -profile singularity \
  --input assets/samplesheet_test.csv \
  --outdir output_test \
  --fasta ../test_data/ATL_v3.asm.chr01_all_haplotypes.fa \
  --gtf ../test_data/ATL_unitato_liftoff.chr01_all_haplotypes.gtf \
  --sqanti_dir SQANTI3 \
  --technology ONT \
  --skip_centrifuge \
  -resume
```

### Notes

- If running on a cluster, adjust the `nextflow.config` file accordingly (e.g., set `process.executor = 'slurm'`)
- Update the `--sqanti_dir` path to match your SQANTI3 installation location


## Troubleshooting

- if sqanit3_reads fails with an error like this ``"ImportError: /lib/x86_64-linux-gnu/libstdc++.so.6: version CXXABI_1.3.15' not found"` check this [github issue](https://github.com/ConesaLab/SQANTI3/issues/475) and try this:
  ```
  SQANTI3_ENV_LIB_DIR=$CONDA_PREFIX/lib
  export LD_LIBRARY_PATH="${SQANTI3_ENV_LIB_DIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
  ```
- if BAMBU fails check your gtf file and make sure it contains `gene_id`


## Tutorial

https://polyase.readthedocs.io/en/latest/tutorial_rice.html#part-4-long-read-rna-seq-analysis

## Credits

nf-core/plantlongrnaseq was originally written by Nadja Nolte.



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

