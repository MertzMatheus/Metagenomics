#!/bin/bash

# ============================
#      USER CONFIGURATION
# ============================
BIN_DIR="<PATH_TO_REFINED_BINS>"           # Folder containing sample folders with metawrap_70_10_bins
OUT_DIR="<PATH_TO_OUTPUT>"                 # Output folder for all BUSCO results

BUSCO_DB="<PATH_TO_BUSCO_LINEAGE_DB>"      # BUSCO lineage database directory
LINEAGE="${BUSCO_DB}/bacteria_odb10"       # Default: Bacteria ODB10 (change if needed)

mkdir -p "$OUT_DIR"

# ============================
#      RUN BUSCO PER BIN
# ============================
for BIN in "$BIN_DIR"/*/metawrap_70_10_bins/"*.fa"; do
    SAMPLE_NAME=$(basename "$(dirname "$(dirname "$BIN")")")
    BIN_NAME=$(basename "$BIN" .fa)

    SAMPLE_OUT="$OUT_DIR/$SAMPLE_NAME/$BIN_NAME"
    mkdir -p "$SAMPLE_OUT"

    echo "Running BUSCO | Sample: $SAMPLE_NAME | Bin: $BIN_NAME"

    busco \
        -i "$BIN" \
        -o "$BIN_NAME" \
        --out_path "$SAMPLE_OUT" \
        -l "$LINEAGE" \
        -m genome \
        --cpu 5
done
