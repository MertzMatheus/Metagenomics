#!/bin/bash

# -------------------------
# User-defined directories
# -------------------------
ASSEMBLY_DIR="$1"   # Folder with assemblies (each sample in a subfolder)
READS_DIR="$2"      # Folder with cleaned paired-end reads per sample
OUT_DIR="$3"        # Output folder for binning results

if [[ -z "$ASSEMBLY_DIR" || -z "$READS_DIR" || -z "$OUT_DIR" ]]; then
    echo "❌ ERROR: Missing arguments."
    echo "Usage: sbatch binning.sh <assembly_dir> <reads_dir> <output_dir>"
    exit 1
fi

mkdir -p "$OUT_DIR"

# -------------------------
# Run binning for each assembly
# -------------------------
for SAMPLE_PATH in "$ASSEMBLY_DIR"/*; do
    SAMPLE=$(basename "$SAMPLE_PATH")
    CONTIGS="$SAMPLE_PATH/final_assembly.fasta"

    READ1="$READS_DIR/$SAMPLE/${SAMPLE}_host_clean_1.fastq"
    READ2="$READS_DIR/$SAMPLE/${SAMPLE}_host_clean_2.fastq"

    if [[ -f "$CONTIGS" && -f "$READ1" && -f "$READ2" ]]; then
        echo "🚀 Starting binning for sample: $SAMPLE"

        metawrap binning \
            -o "$OUT_DIR/$SAMPLE" \
            -t 20 \
            -a "$CONTIGS" \
            --metabat2 --maxbin2 --concoct \
            "$READ1" "$READ2"

        echo "✅ Finished binning for: $SAMPLE"
        echo "-----------------------------------------"
    else
        echo "⚠️ Missing files for sample $SAMPLE. Skipping..."
    fi
done

echo "🎉 All binning processes completed."
