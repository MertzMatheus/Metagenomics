#!/bin/bash

# -------------------------
# User-defined folders
# -------------------------
REFINED_BINS_DIR="$1"   # Directory containing folders for each sample with refined bins (metawrap_70_10_bins inside)
READS_DIR="$2"          # Directory with cleaned reads per sample
OUT_DIR="$3"            # Output directory for reassembled bins

if [[ -z "$REFINED_BINS_DIR" || -z "$READS_DIR" || -z "$OUT_DIR" ]]; then
    echo "❌ ERROR: Missing arguments."
    echo "Usage: sbatch reassembly.sh <refined_bins_dir> <reads_dir> <output_dir>"
    exit 1
fi

mkdir -p "$OUT_DIR"

# -------------------------
# Loop through all samples
# -------------------------
for SAMPLE_DIR in "$REFINED_BINS_DIR"/*; do
    [[ -d "$SAMPLE_DIR" ]] || continue

    SAMPLE=$(basename "$SAMPLE_DIR")
    BINS="$SAMPLE_DIR/metawrap_70_10_bins"

    READ1="$READS_DIR/$SAMPLE/${SAMPLE}_host_clean_1.fastq"
    READ2="$READS_DIR/$SAMPLE/${SAMPLE}_host_clean_2.fastq"

    if [[ -f "$READ1" && -f "$READ2" && -d "$BINS" ]]; then
        echo "🚀 Running reassemble_bins for sample: $SAMPLE"

        metawrap reassemble_bins \
            -o "$OUT_DIR/$SAMPLE" \
            -1 "$READ1" \
            -2 "$READ2" \
            -t 20 \
            -m 200 \
            -c 70 \
            -x 10 \
            -b "$BINS"

        echo "✅ Finished reassembly for: $SAMPLE"
        echo "---------------------------------------------"
    else
        echo "⚠️ Skipping $SAMPLE — reads or refined bins not found."
    fi
done

echo "🎉 All samples processed!"
