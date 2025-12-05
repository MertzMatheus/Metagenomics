#!/bin/bash


##############################################
# DIRECTORIES (SET YOUR OWN PATHS)
##############################################
GENOME_DIR="/path/to/genomes"
BGC_DIR="/path/to/output/bgc"
LOG_DIR="/path/to/output/logs"
THREADS=""

mkdir -p "$BGC_DIR" "$LOG_DIR"

##############################################
# STEP — antiSMASH (BGC IDENTIFICATION)
##############################################
echo "=========================================="
echo " Running antiSMASH (Biosynthetic Gene Clusters)"
echo "=========================================="

for genome in "$GENOME_DIR"/*.fa; do
    
    base=$(basename "$genome" .fa)
    out_dir="$BGC_DIR/$base"

    echo "[+] Running antiSMASH for genome: $base"

    antismash \
        "$genome" \
        --taxon fungi \
        --genefinding-tool glimmerhmm \
        --cb-general --cb-subclusters --cb-knownclusters \
        --cpus "$THREADS" \
        --output-dir "$out_dir" \
        &> "$LOG_DIR/${base}_antismash.log"

done

echo "[✓] antiSMASH analysis completed."
