🧬 Shotgun Metagenomics Pipeline

A complete, modular, and reproducible pipeline for shotgun metagenomics — including quality control, host decontamination, assembly, genome binning, refinement, taxonomic classification, genome quality assessment, and functional annotation.

This workflow integrates FastP, Bowtie2, Kraken2, and the MetaWRAP framework, along with CheckM, BUSCO, GTDB-Tk, antiSMASH, RGI, StarAMR, and more.

⭐ Features

🔄 End-to-end workflow: from raw reads to curated MAGs

🧱 Modular: run each step independently

🛠️ Tool integration: metaSPAdes, MetaBAT2, MaxBin2, CONCOCT

📦 High-quality MAG reconstruction

🧬 Functional annotation: AMR detection + secondary metabolite prediction

📉 Reproducible: Conda environments or containers for each step

📁 Directory Structure
metagenomics-pipeline/
│── data/
│   ├── raw/
│   ├── clean/
│   ├── host_removed/
│── results/
│   ├── qc/
│   ├── assembly/
│   ├── bins/
│   ├── refined_bins/
│   ├── taxonomy/
│   ├── annotation/
│── scripts/
│── envs/
└── README.md

🚀 1. Installation & Dependencies
📦 Option 1 — Using Conda (recommended)

Install Miniconda/Anaconda and create environments for each module.

Example:

conda create -n qc_env fastp bowtie2 kraken2 -y
conda activate qc_env


MetaWRAP environment:

conda create -n metawrap_env -c ursky -c bioconda -c conda-forge metawrap-mg


Annotation tools:

conda create -n annotation_env checkm-genome busco gtdbtk antismash staramr -y


AMR:

conda create -n amr_env rgi

🔍 2. Quality Control & Decontamination
FastP — Quality Filtering
fastp -i sample_R1.fastq.gz -I sample_R2.fastq.gz \
      -o clean_R1.fastq.gz -O clean_R2.fastq.gz \
      --html fastp_report.html --json fastp_report.json

Bowtie2 — Host Removal
bowtie2 -x human_db -1 clean_R1.fastq.gz -2 clean_R2.fastq.gz \
        --un-conc-gz host_removed.fastq.gz -S host_mapped.sam

Kraken2 — Remove Remaining Contaminants
kraken2 --db kraken_db --paired clean_R1.fastq.gz clean_R2.fastq.gz \
        --unclassified-out final_clean#.fq

🧬 3. Metagenomic Assembly (MetaWRAP)
Assembly using metaSPAdes
metawrap assembly -o assembly_out -t 16 \
                  --metaspades final_clean_1.fq final_clean_2.fq

🧱 4. Genome Binning (MetaWRAP)

This pipeline uses:

MaxBin2

MetaBAT2

CONCOCT

metawrap binning -o bins_out -t 16 \
    -a assembly_out/final_assembly.fasta \
    final_clean_1.fq final_clean_2.fq

♻️ 5. Bin Refinement & Reassembly
Refinement (70% completeness / 10% contamination cutoff)
metawrap bin_refinement -o refined_bins -t 16 \
    -A bins_out/maxbin2_bins \
    -B bins_out/metabat2_bins \
    -C bins_out/concoct_bins \
    -c 70 -x 10

Reassembly
metawrap reassemble_bins -o reassembled_bins -t 16 \
    -b refined_bins/metawrap_70_10_bins \
    -1 final_clean_1.fq -2 final_clean_2.fq

🧪 6. Genome Quality Assessment
CheckM
checkm lineage_wf -t 16 -x fa refined_bins/ checkm_output/

BUSCO
busco -i refined_bins/ -l bacteria_odb10 -m genome -o busco_output

🏷️ 7. Taxonomic Classification
Kraken2
kraken2 --db kraken_db --output kraken.txt \
        --report kraken_report.txt refined_bins/*.fa

GTDB-Tk (taxonomy + phylogeny)
gtdbtk classify_wf --genome_dir refined_bins/ \
                   --out_dir gtdbtk_output --cpus 16

🧬 8. Functional Annotation
🦠 Antibiotic Resistance
RGI (CARD)
rgi main --input_sequence genome.fa \
         --output_file rgi_output \
         --alignment_tool DIAMOND

StarAMR
staramr search --input-genome refined_bins/ \
               --output-dir staramr_output

🌱 Secondary Metabolite Biosynthetic Gene Clusters
antiSMASH
antismash genome.fa --output-dir antismash_output

📊 Outputs
Step	Output
QC	FastP reports, clean reads
Host Removal	host-free FASTQs
Assembly	contigs (FASTA)
Binning	MaxBin2, MetaBAT2, CONCOCT bins
Refinement	high-quality MAGs
CheckM/BUSCO	quality metrics
Kraken2/GTDB-Tk	taxonomy + phylogenetic tree
RGI/StarAMR	AMR genes
antiSMASH	BGC clusters
