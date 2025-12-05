#!/bin/bash

# -----------------------------------------
# User-provided arguments
# -----------------------------------------
BINS_DIR="$1"      # Directory containing sample subfolders with metabat2, maxbin2, concoct bins
OUT_DIR="$2"       # Output directory for refined bins
THREADS="$3"       # Number of threads to use

if [[ -z "$BINS_DIR" || -z "$OUT_DIR" || -z "$THREADS" ]]; then
    echo "❌ ERROR: Missing input arguments."
    echo "Usage: sbatch refined.sh <bins_dir> <output_dir> <threads>"
    exit 1
fi

mkdir -p "$OUT_DIR"

# -----------------------------------------
# Loop through all sample bin folders
# -----------------------------------------
for SAMPLE_DIR in "$BINS_DIR"/*; do
    [[ -d "$SAMPLE_DIR" ]] || continue

    SAMPLE=$(basename "$SAMPLE_DIR")

    META_DIR="$SAMPLE_DIR/metabat2_bins"
    MAX_DIR="$SAMPLE_DIR/maxbin2_bins"
    CON_DIR="$SAMPLE_DIR/concoct_bins"

    # Ensure bin directories exist
    if [[ ! -d "$META_DIR" || ! -d "$MAX_DIR" || ! -d "$CON_DIR" ]]; then
        echo "⚠️ Skipping $SAMPLE — missing binning results."
        continue
    fi

    echo "🔧 Running bin refinement for sample: $SAMPLE"

    metawrap bin_refinement \
        -o "$OUT_DIR/$SAMPLE" \
        -t "$THREADS" \
        -A "$META_DIR" \
        -B "$MAX_DIR" \
        -C "$CON_DIR" \
        -c 70 -x 10

    echo "✅ Finished: $SAMPLE"
    echo "-----------------------------------------"
done

echo "🎉 All samples processed!"
