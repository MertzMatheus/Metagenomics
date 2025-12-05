#!/bin/bash

# ============================================================
#   fastp batch processing script (generic version)
#   Use this template in your GitHub pipeline.
#   All directories and binaries are user-configurable.
# ============================================================

# Number of CPU threads to use
THREADS=16

# ================================
# User-defined directories
# ================================

# Directory containing raw paired-end FASTQ files
# Expected format: sample.1.fq.gz and sample.2.fq.gz
RAW_DIR="./data/raw"

# Output directory for cleaned reads
OUT_DIR="./data/clean"

# Directory for fastp HTML/JSON reports
REPORT_DIR="./data/reports"

# Path to fastp binary (assumes fastp is in PATH)
FASTP_BIN="fastp"

# ================================
# Create output directories
# ================================
mkdir -p "$OUT_DIR" "$REPORT_DIR"

echo "Starting fastp batch processing..."
echo "Input directory:  $RAW_DIR"
echo "Output directory: $OUT_DIR"
echo "Reports:          $REPORT_DIR"
echo "Threads:          $THREADS"
echo ""

# ================================
# Loop through paired-end files
# ================================
for R1 in "$RAW_DIR"/*.1.fq.gz; do

    SAMPLE=$(basename "$R1" .1.fq.gz)
    R2="${RAW_DIR}/${SAMPLE}.2.fq.gz"

    # Check if R2 exists
    if [[ ! -f "$R2" ]]; then
        echo "WARNING: Pair not found for $R1 — skipping..."
        continue
    fi

    echo "Processing sample: $SAMPLE"

    $FASTP_BIN \
        -i "$R1" \
        -I "$R2" \
        -o "$OUT_DIR/${SAMPLE}_R1.clean.fastq.gz" \
        -O "$OUT_DIR/${SAMPLE}_R2.clean.fastq.gz" \
        -h "$REPORT_DIR/${SAMPLE}.fastp.html" \
        -j "$REPORT_DIR/${SAMPLE}.fastp.json" \
        --thread $THREADS

    echo "Done: $SAMPLE"
    echo "----------------------------------------"

done

echo "All samples processed successfully."
