#!/bin/bash

############################
### Generic Directories  ###
############################

BIN_DIR="/path/to/bins_reassembly"
OUT_DIR="$BIN_DIR/rgi_results"
CARD_DB="/path/to/CARD_database/card.json"

mkdir -p "$OUT_DIR"

# Load CARD database (local mode)
rgi load --card_json "$CARD_DB" --local

########################################
### Loop through all reassembled bins ###
########################################

for SAMPLE_PATH in "$BIN_DIR"/*/reassembled_bins/*.fa; do
    [[ -f "$SAMPLE_PATH" ]] || continue

    # Extract sample directory
    SAMPLE_DIR=$(basename "$(dirname "$(dirname "$SAMPLE_PATH")")")

    # Extract filename without extension
    FILE_NAME=$(basename "$SAMPLE_PATH" .fa)

    # Create output directory per sample/bin
    SAMPLE_OUT_DIR="$OUT_DIR/$SAMPLE_DIR/$FILE_NAME"
    mkdir -p "$SAMPLE_OUT_DIR"

    echo "📌 Running RGI on: Sample = $SAMPLE_DIR | Bin = $FILE_NAME"

    # Run RGI main analysis
    rgi main \
        --input_sequence "$SAMPLE_PATH" \
        --output_file "$SAMPLE_OUT_DIR/$FILE_NAME" \
        --local --clean --low_quality

    # Generate heatmap
    rgi heatmap \
        --input "$SAMPLE_OUT_DIR/$FILE_NAME" \
        --output "$SAMPLE_OUT_DIR/$FILE_NAME"

    echo "✅ Finished: $SAMPLE_DIR / $FILE_NAME"
done
