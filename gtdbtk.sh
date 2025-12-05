#!/bin/bash

# ============================
#       USER SETTINGS
# ============================

BASE_DIR="<PATH_TO_REASSEMBLED_BINS>"          # Directory containing sample folders with reassembled bins
OUT_DIR="<PATH_TO_OUTPUT>"                     # Output directory for GTDB-Tk results
GTDBTK_DB="<PATH_TO_GTDBTK_DATABASE>"          # e.g., GTDB release R207 / R214 / R226 etc.
ENV_NAME="<GTDBTK_ENVIRONMENT>"                # Your micromamba/conda environment

# ============================
#       ENVIRONMENT
# ============================

module load Miniconda/3
micromamba activate "$ENV_NAME"

# GTDBTk database path
export GTDBTK_DATA_PATH="$GTDBTK_DB"

mkdir -p "$OUT_DIR"

# ============================
#       PROCESS SAMPLES
# ============================

for SAMPLE in "$BASE_DIR"/*; do
    SAMPLE_NAME=$(basename "$SAMPLE")
    GENOME_DIR="$SAMPLE/reassembled_bins"

    # Check for FASTA bins
    if compgen -G "$GENOME_DIR/*.fa" > /dev/null; then
        echo "▶ Running GTDB-Tk for sample: $SAMPLE_NAME"

        gtdbtk classify_wf \
            --genome_dir "$GENOME_DIR" \
            --out_dir "$OUT_DIR/$SAMPLE_NAME" \
            --extension fa \
            --cpus 16 \
            --skip_ani_screen

        echo "✅ Finished: $SAMPLE_NAME"
    else
        echo "⚠ No genome bins found in: $GENOME_DIR"
    fi
done

echo "🎉 GTDB-Tk processing completed for all samples."
