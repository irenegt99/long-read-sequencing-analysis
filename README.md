# long-read-sequencing-analysis
# RNA-seq analysis pipeline (Nanopore)

## WORK IN PROGRESS ##

This repository contains a series of Bash scripts to process Nanopore RNA-seq data in mouse (GRCm39 / Gencode vM37),but could be easily change to other reference genome, from raw FASTQ files to:

- Genome alignments (sorted and indexed BAM files)
- Alignment metrics
- **Gene-level count matrix** (featureCounts)
- **Transcript-level quantification** (IsoQuant)

---

## 1. Requirements

### 1.1. Conda environments

- `rna_env`  
  For preprocessing, QC and alignment:
  - `NanoPlot`
  - `chopper`
  - `minimap2`
  - `samtools`
  - `awk`, `join`, `find`, `gzip`, `gunzip` (standard coreutils)
  - `featurecounts`
- `isoquant`  
  For transcript quantification:
  - `isoquant.py`
  - Python and IsoQuant dependencies

### 1.2. External software

- [samtools](https://github.com/samtools/samtools)
- [minimap2](https://github.com/nanoporetech/ont-minimap2)
- [NanoPlot](https://github.com/wdecoster/NanoPlot)
- [chopper] https://github.com/nanoporetech/pychopper
- [Subread / featureCounts](https://subread.sourceforge.net/)
- [IsoQuant](https://github.com/ablab/IsoQuant)
    ```conda create -c conda-forge -c bioconda -n isoquant python=3.8 isoquant```

### 1.3. References

Adjust the paths in the scripts to your local reference files:

- Genome (FASTA)  
  `GRCm39_vM37.primary_assembly.genome.fa`
- Annotation (GTF)  
  `gencode.vM37.annotation.gtf`
- Input file
- Output file
- Threads 

Example, paths like the following are used:

```bash
REFERENCE="/GRCm39_vM37.primary_assembly.genome.fa"
REFERENCE_GTF="/gencode.vM37.annotation.gtf"
INPUT_DIR="../results/minimap2"
SAMTOOLS_DIR="../results/samtools"
THREADS=24
```


## 2. Directory layout (expected)

The scripts assume something like:

Raw Nanopore barcoded data:
```
../sample/barcode01/
../sample/barcode02/
../sample/barcodeXX/
```
Output directories created by the pipeline:
```
../sample/barcodeX/merged_barcode/
../results/nanoplot/
../results/chopper/
../results/minimap2/
../results/samtools/
../results/FeatureCounts/
../samples/Isoquant
```

## 3. Making the scripts executable

From the directory where the scripts are stored:
```
chmod +x pipeline_rna.sh
chmod +x featurecounts.sh      # name you give to the featureCounts script
chmod +x generate_isoquant_yaml.sh
chmod +x run_isoquant.sh  
```
## 4. Running the pipeline in the terminal
### 4.1.Preprocessing, QC and alignment (Conda env: rna_env) 

Activate the environment and move to the folder containing the scripts:
```
conda activate rna_env

./pipeline_rna.sh
```
### 4.2.Gene expression analysis (Conda env: rna_env) 

Activate the environment and move to the folder containing the scripts:
```
conda activate rna_env

./featurecounts.sh
```
### 4.3.Transcript expression analysis (Conda env: isoquant) 

Create groups.tsv

Example:
```
barcode01,grupo1
barcode02,grupo1
barcode03,grupo1
barcode04,grupo2
barcode05,grupo2
```

```
conda activate isoquant

./generate_isoquant_yaml.sh

./run_isoquant.sh```