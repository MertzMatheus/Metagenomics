#!/bin/bash

# ============================================================
# Kraken2 Human Read Removal + Krona Visualization
# Generic version for GitHub
# ============================================================

# Load conda/mamba (adjust according to your cluster)
module load Miniconda/3
source ~/.bashrc
micromamba activate metagenome_env

# ============================================================
# User-defined paths (edit these)
# ============================================================

# Kraken2 database (must be pre-built or downloaded)
DB="./db/kraken2/kraken2_pluspf"

# Directory with raw/clean metagenomic reads
CLEAN_DIR="./data/clean_reads"

# Output directory
OUT_DIR="./results/remove_human"

# Path to KrakenTools (inside your environment)
KRAKENTOOLS_DIR="./tools/KrakenTools"

# Make sure output directory exists
mkdir -p "$OUT_DIR"

# ============================================================
# Loop through paired-end FASTQ files
# Expected naming: sample_1.fq and sample_2.fq
# ============================================================

for R1 in "$CLEAN_DIR"/*_1.fq; do
    
    SAMPLE=$(basename "$R1" _1.fq)
    R2="$CLEAN_DIR/${SAMPLE}_2.fq"
    SAMPLE_DIR="$OUT_DIR/$SAMPLE"

    mkdir -p "$SAMPLE_DIR"

    echo "Processing sample: $SAMPLE"

    # --------------------------------------------------------
    # 1) Initial Kraken2 classification
    # --------------------------------------------------------
    kraken2 \
        --db "$DB" \
        --threads 20 \
        --memory-mapping \
        --paired "$R1" "$R2" \
        --report "$SAMPLE_DIR/${SAMPLE}.report" \
        --output "$SAMPLE_DIR/${SAMPLE}.kraken"

    # --------------------------------------------------------
    # 2) Remove human reads with KrakenTools
    # --------------------------------------------------------
    python3 "$KRAKENTOOLS_DIR/extract_kraken_reads.py" \
        -k "$SAMPLE_DIR/${SAMPLE}.kraken" \
        -r "$SAMPLE_DIR/${SAMPLE}.report" \
        -s1 "$R1" \
        -s2 "$R2" \
        -t 9606 \
        --exclude \
        --include-parents \
        --fastq-output \
        -o  "$SAMPLE_DIR/${SAMPLE}_host_clean_1.fastq" \
        -o2 "$SAMPLE_DIR/${SAMPLE}_host_clean_2.fastq"

    # --------------------------------------------------------
    # 3) Reclassify host-clean reads with Kraken2
    # --------------------------------------------------------
    kraken2 \
        --db "$DB" \
        --threads 20 \
        --memory-mapping \
        --paired "$SAMPLE_DIR/${SAMPLE}_host_clean_1.fastq" "$SAMPLE_DIR/${SAMPLE}_host_clean_2.fastq" \
        --report "$SAMPLE_DIR/${SAMPLE}_host_clean.final.report" \
        --output "$SAMPLE_DIR/${SAMPLE}_host_clean.final.kraken"

    # --------------------------------------------------------
    # 4) Convert Kraken2 report → Krona input
    # --------------------------------------------------------
    python3 "$KRAKENTOOLS_DIR/kreport2krona.py" \
        -r "$SAMPLE_DIR/${SAMPLE}_host_clean.final.report" \
        -o "$SAMPLE_DIR/${SAMPLE}_host_clean.final.krona"

    # --------------------------------------------------------
    # 5) Generate HTML Krona plot
    # --------------------------------------------------------
    ktImportText \
        "$SAMPLE_DIR/${SAMPLE}_host_clean.final.krona" \
        -o "$SAMPLE_DIR/${SAMPLE}_host_clean.final.krona.html"

    echo "Finished sample: $SAMPLE"
    echo "-----------------------------------------------"

done

echo "All samples processed successfully."
