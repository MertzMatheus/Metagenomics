#!/bin/bash

# === User-defined directories (generic — fill before running) ===
BIN_DIR="<PATH_TO_REFINED_BINS>"              # e.g., /project/bins/bins_refined
OUT_DIR="<PATH_TO_OUTPUT_CHECKM>"             # e.g., /project/bins/checkm_output
CHECKM_DB="<PATH_TO_CHECKM_DB>"               # e.g., /envs/metagenome_env/checkm_data
THREADS=10

mkdir -p "$OUT_DIR"

# Loop through all samples containing refined bins
for SAMPLE_PATH in "$BIN_DIR"/*/metawrap_70_10_bins; do
    SAMPLE=$(basename "$(dirname "$SAMPLE_PATH")")
    echo "Running CheckM for sample: $SAMPLE"

    SAMPLE_OUT="$OUT_DIR/${SAMPLE}"
    mkdir -p "$SAMPLE_OUT"

    # Run CheckM lineage workflow
    checkm lineage_wf -x fa \
        --reduced_tree \
        -t "$THREADS" \
        --pplacer_threads "$THREADS" \
        -d "$CHECKM_DB" \
        "$SAMPLE_PATH" "$SAMPLE_OUT"

    # Generate summary table
    checkm qa "$SAMPLE_OUT/lineage.ms" "$SAMPLE_OUT" -o 2 -t "$THREADS" \
        > "$SAMPLE_OUT/checkm_summary.tsv"

    echo "Completed: $SAMPLE"
done
