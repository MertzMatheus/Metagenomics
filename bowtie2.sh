#!/bin/bash

# ============================================
# User-defined paths (modify before running)
# ============================================

# Path to Bowtie2 indexed genome (e.g., human hg38)
GENOME_INDEX="./genomes/hg38"

# Directory containing clean fastp reads
CLEAN_DIR="./data/clean"

# Output directory for host-filtered reads
OUT_DIR="./data/decontaminated"

# Ensure the output directory exists
mkdir -p "$OUT_DIR"

# ============================================
# Loop through paired-end FASTQ files
# ============================================

echo "Starting Bowtie2 contaminant removal..."
echo "Genome index: $GENOME_INDEX"
echo ""

for R1 in "$CLEAN_DIR"/*_R1.clean.fastq.gz; do

    SAMPLE=$(basename "$R1" _R1.clean.fastq.gz)
    R2="$CLEAN_DIR/${SAMPLE}_R2.clean.fastq.gz"

    echo "Processing sample: $SAMPLE"

    bowtie2 \
        -x "$GENOME_INDEX" \
        -1 "$R1" \
        -2 "$R2" \
        --very-sensitive \
        --dovetail \
        --threads 16 \
        --un-conc-gz "$OUT_DIR/${SAMPLE}_host_clean.fq.gz" \
        -S /dev/null

    echo "Finished: $SAMPLE"
    echo "-------------------------------------------"

done

echo "Bowtie2 contaminant removal completed."
