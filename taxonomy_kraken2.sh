#!/bin/bash


# ============================
#       ENVIRONMENT
# ============================

module load Miniconda/3
micromamba activate <METAGENOME_ENVIRONMENT>

# ============================
#       USER SETTINGS
# ============================

KRAKEN_DB="<PATH_TO_KRAKEN2_DATABASE>"           # e.g. Kraken2 standard, PlusPF, custom DB
BIN_DIR="<PATH_TO_REFINED_BINS>"                 # Directory containing sample folders with metawrap_70_10_bins
OUT_DIR="<OUTPUT_DIRECTORY_FOR_KRAKEN_RESULTS>"
KREPORT2KRONA="<PATH_TO_kreport2krona.py>"       # Usually inside KrakenTools

mkdir -p "$OUT_DIR"

# ============================
#       PROCESS EACH BIN
# ============================

for BIN in "$BIN_DIR"/*/metawrap_70_10_bins/*.fa; do
    SAMPLE=$(basename "$(dirname "$(dirname "$BIN")")")
    BIN_NAME=$(basename "$BIN" .fa)

    echo "🔎 Classifying bin: $BIN_NAME | Sample: $SAMPLE"

    # 1. Kraken2 classification
    kraken2 \
        --db "$KRAKEN_DB" \
        --threads 8 \
        --use-names \
        --report "$OUT_DIR/${SAMPLE}_${BIN_NAME}.report" \
        --memory-mapping \
        "$BIN"

    # 2. Convert Kraken2 report to Krona input
    python "$KREPORT2KRONA" \
        -r "$OUT_DIR/${SAMPLE}_${BIN_NAME}.report" \
        -o "$OUT_DIR/${SAMPLE}_${BIN_NAME}.krona"

    # 3. Generate Krona HTML visualization
    ktImportText "$OUT_DIR/${SAMPLE}_${BIN_NAME}.krona" \
        -o "$OUT_DIR/${SAMPLE}_${BIN_NAME}.krona.html"

    echo "✅ Completed: $SAMPLE"
done
