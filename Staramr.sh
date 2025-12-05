#!/bin/bash

############################
### Generic Directories  ###
############################

BIN_DIR="/path/to/bins_reassembly"
OUT_DIR="$BIN_DIR/staramr_results"

mkdir -p "$OUT_DIR"

########################################
### Loop through reassembled bin files ###
########################################

for SAMPLE_PATH in "$BIN_DIR"/*/reassembled_bins/*.fa; do
    [[ -f "$SAMPLE_PATH" ]] || continue

    # Get sample folder name
    SAMPLE_DIR=$(basename "$(dirname "$(dirname "$SAMPLE_PATH")")")

    # Get base filename without extension
    FILE_NAME=$(basename "$SAMPLE_PATH" .fa)

    # Output directory per sample
    SAMPLE_OUT_DIR="$OUT_DIR/$SAMPLE_DIR"
    mkdir -p "$SAMPLE_OUT_DIR"

    echo "Running staramr on: $SAMPLE_PATH → $SAMPLE_OUT_DIR"

    staramr search \
        -o "$SAMPLE_OUT_DIR/$FILE_NAME" \
        "$SAMPLE_PATH"
done
