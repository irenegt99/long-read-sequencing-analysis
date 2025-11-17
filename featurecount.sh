#!/bin/bash

# Define input and output directories
INPUT_BASE_DIR="/results/samtools/"
OUTPUT_BASE_DIR="/results/FeatureCounts/"
REFERENCE_GTF="/gencode.vM37.annotation.gtf"

# Set parameters
THREADS=4
STRANDNESS=0
QUALITY=0
FEATURE_TYPE="exon"
ATTRIBUTE="gene_id"
MIN_OVERLAP=1
FRAC_OVERLAP=0
FRAC_OVERLAP_FEATURE=0

# Create output directory if not exists
mkdir -p "$OUTPUT_BASE_DIR"

# Loop through all barcode directories
for BARCODE_DIR in ${INPUT_BASE_DIR}aligned_barcode*_filtered/; do
    # Extract barcode identifier (assuming the format is consistent)
    BARCODE=$(basename "$BARCODE_DIR" | sed -E 's/aligned_(barcode[0-9]+)_filtered/\1/')
    
    # Define BAM file path
    BAM_FILE="${BARCODE_DIR}aligned_${BARCODE}_filtered_sorted.bam"
    
    # Check if BAM file exists
    if [ ! -f "$BAM_FILE" ]; then
        echo "BAM file not found for $BARCODE, skipping..."
        continue
    fi
    
    # Print progress
    echo "Processing barcode: $BARCODE"
    
    # Output file
    OUTPUT_FILE="${OUTPUT_BASE_DIR}featurecount_${BARCODE}"
    
    # Run featureCounts
    featureCounts -a "$REFERENCE_GTF" -F "GTF" -o "$OUTPUT_FILE" -T "$THREADS" -s "$STRANDNESS" -Q "$QUALITY" -t "$FEATURE_TYPE" -g "$ATTRIBUTE" -L --minOverlap "$MIN_OVERLAP" --fracOverlap "$FRAC_OVERLAP" --fracOverlapFeature "$FRAC_OVERLAP_FEATURE" "$BAM_FILE"

done

# Merge counts from all generated featureCounts output files
MERGE_DIR="${OUTPUT_BASE_DIR}merged_output"
mkdir -p "$MERGE_DIR"

# Collect only the relevant featureCounts output files (excluding .summary)
COUNT_FILES=($(ls ${OUTPUT_BASE_DIR}featurecount_barcode* | grep -v ".summary"))

# Extract counts and merge
for FILE in "${COUNT_FILES[@]}"; do
    awk 'NR==2{next} {print $1"\t"$7}' "$FILE" | sort -k1,1 > "$MERGE_DIR/$(basename "$FILE").sorted"
done

# Use the first file as the base
SORTED_FILES=($MERGE_DIR/*.sorted)
cp "${SORTED_FILES[0]}" "$MERGE_DIR/merged_output.txt"

# Merge all files by GeneID
for (( i=1; i<${#SORTED_FILES[@]}; i++ )); do
    join -1 1 -2 1 "$MERGE_DIR/merged_output.txt" "${SORTED_FILES[$i]}" > "$MERGE_DIR/temp.txt"
    mv "$MERGE_DIR/temp.txt" "$MERGE_DIR/merged_output.txt"

done

# Create header
HEADER="Geneid"
for FILE in "${COUNT_FILES[@]}"; do
    BARCODE=$(basename "$FILE" | sed -E 's/featurecount_(barcode[0-9]+)/\1/')
    HEADER+="\t$BARCODE"
done

# Add header to final output
awk -v header="$HEADER" 'BEGIN{print header} {print}' "$MERGE_DIR/merged_output.txt" > "$MERGE_DIR/final_output.txt"

echo "Merging completed! Final output: $MERGE_DIR/final_output.txt"
