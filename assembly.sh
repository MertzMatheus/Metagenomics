#!/bin/bash

# -------------------------
# User-defined input folders
# -------------------------
IN_DIR="$1"     # Directory containing sample folders with *_1.fastq and *_2.fastq
OUT_DIR="$2"    # Directory where assemblies will be saved

# Check inputs
if [[ -z "$IN_DIR" || -z "$OUT_DIR" ]]; then
    echo "❌ ERROR: You must provide input and output directories."
    echo "Usage: sbatch script.sh <input_directory> <output_directory>"
    exit 1
fi

mkdir -p "$OUT_DIR"

# -------------------------
# Run assembly for each sample
# -------------------------
for R1 in "$IN_DIR"/*/*_1.fastq; do
    SAMPLE=$(basename "$(dirname "$R1")")
    R2="${R1/_1.fastq/_2.fastq}"
    SAMPLE_OUT="$OUT_DIR/$SAMPLE"

    if [[ ! -f "$R2" ]]; then
        echo "⚠️ Warning: R2 file not found for sample $SAMPLE. Skipping..."
        continue
    fi

    echo "🚀 Starting assembly for sample: $SAMPLE"
    echo "R1: $R1"
    echo "R2: $R2"
    echo "Output: $SAMPLE_OUT"

    mkdir -p "$SAMPLE_OUT"

    metawrap assembly \
        -1 "$R1" \
        -2 "$R2" \
        -m 200 \
        -t 20 \
        --metaspades \
        -o "$SAMPLE_OUT"

    echo "✅ Finished assembly for: $SAMPLE"
    echo "---------------------------------------"
done

echo "🎉 All assemblies completed."
