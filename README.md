# 🧬 Shotgun Metagenomics Pipeline

A complete, modular, and reproducible pipeline for shotgun metagenomics — including quality control, host decontamination, assembly, genome binning, refinement, taxonomic classification, genome quality assessment, and functional annotation.

This workflow integrates **FastP**, **Bowtie2**, **Kraken2**, and the **MetaWRAP** framework, along with **CheckM**, **BUSCO**, **GTDB-Tk**, **antiSMASH**, **RGI**, **StarAMR**, and more.

---

## ⭐ Features
- 🔄 **End-to-end workflow**: from raw reads to curated MAGs  
- 🧱 **Modular**: each step can be executed independently  
- 🛠️ **Tool integration**: metaSPAdes, MetaBAT2, MaxBin2, CONCOCT  
- 📦 **High-quality MAG reconstruction**  
- 🧬 **Functional annotation**: AMR detection + secondary metabolite prediction  
- 📉 **Reproducible**: isolated Conda environments  

---

# 📁 Directory Structure



---

# 🚀 1. Installation & Dependencies

## 📦 Conda Environments

### Quality Control tools
```bash
conda create -n qc_env fastp bowtie2 kraken2 -y
conda activate qc_env


conda create -n metawrap_env -c ursky -c bioconda -c conda-forge metawrap-mg
