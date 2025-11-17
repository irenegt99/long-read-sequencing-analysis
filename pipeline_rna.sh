#!/bin/bash

# Create a new file called "samples" just in the directory above where this script is located. All the barcodes, etc., coming from the Nanopore analysis should be placed there.Environment: rna_env.

# merge.sh
for dir in ../samplesbarcode*; do
    if [ -d "$dir" ]; then
        output_dir="${dir}/merged_barcode"
        mkdir -p "$output_dir"  # Create the directory if it doesn't exist
        output_file="${output_dir}/$(basename "$dir").merged.fastq.gz"
        cat "$dir"/*.fastq.gz > "$output_file"
        echo "File created: $output_file"
    fi
done

# nanoplot.sh 
for file in ../samplesbarcode*/merged_barcode/*.fastq.gz; do 
    if [ -f "$file" ]; then  
        sample_name=$(basename "$file" .merged.fastq.gz)  
        output_dir="../results/nanoplot/${sample_name}/"
        mkdir -p "$output_dir"

        NanoPlot --fastq "$file" -o "$output_dir" -t 4  
        echo "File created in: $output_dir"
    fi
done

# chopper.sh
#!/bin/bash
for dir in ../samplesbarcode*/merged_barcode; do
    if [ -d "$dir" ]; then
        output_dir="../results/chopper/$(basename "$(dirname "$dir")")/"
        outputnano_dir="../results/nanoplot/filtered/$(basename "$(dirname "$dir")")/"
        mkdir -p "$output_dir" "$outputnano_dir"

        output_fastq="$output_dir/$(basename "$(dirname "$dir")")_filtered.fastq.gz"

        # Find fastq.gz files in merged_barcode
        fastq_files=($(find "$dir" -maxdepth 1 -type f -name "*.fastq.gz"))

        if [ ${#fastq_files[@]} -gt 0 ]; then
            gunzip -c "${fastq_files[@]}" | chopper -q 6 | gzip > "$output_fastq"
            NanoPlot --fastq "$output_fastq" -o "$outputnano_dir" -t 4
            echo "File created in: $output_fastq"
        else
            echo "No FASTQ files found in $dir, skipping..."
        fi
    fi
done


# minimap2_align.sh
# Input and output directories
REFERENCE="/GRCm39_vM37.primary_assembly.genome.fa"
SAMPLES_DIR="../results/chopper"
OUTPUT_DIR="../results/minimap2"
THREADS=24

mkdir -p "$OUTPUT_DIR"

# Process each FASTQ file in the samples directory
for SAMPLE in "$SAMPLES_DIR"/*/*.fastq.gz; do
    if [ -f "$SAMPLE" ]; then
        SAMPLE_NAME=$(basename "$SAMPLE" .fastq.gz)
        OUTPUT_SAM="$OUTPUT_DIR/aligned_${SAMPLE_NAME}.sam"
        
        echo "Alineando $SAMPLE ..."
        minimap2 -ax splice -t "$THREADS" "$REFERENCE" "$SAMPLE" > "$OUTPUT_SAM"
        echo "Finish: $OUTPUT_SAM"
    else
        echo "No valid FASTQ found in $SAMPLE, skipping..."
    fi
done

echo "Alignment completed."

# samtools.sh
# Input and output directories
INPUT_DIR="../results/minimap2"
SAMTOOLS_DIR="../results/samtools"
THREADS=24

mkdir -p "$SAMTOOLS_DIR"

# Process each each SAM file in the input directory
for SAM_FILE in "$INPUT_DIR"/*.sam; do
    if [ -f "$SAM_FILE" ]; then
        SAMPLE_NAME=$(basename "$SAM_FILE" .sam)
        
        SAMPLE_DIR="$SAMTOOLS_DIR/$SAMPLE_NAME"
        mkdir -p "$SAMPLE_DIR"
        
        OUTPUT_BAM="$SAMPLE_DIR/${SAMPLE_NAME}.bam"
        SORTED_BAM="$SAMPLE_DIR/${SAMPLE_NAME}_sorted.bam"
        REPORT="$SAMPLE_DIR/alig_report_${SAMPLE_NAME}.txt"
        
        echo "Convirtiendo $SAM_FILE a BAM..."
        samtools view -@ "$THREADS" -Sb -o "$OUTPUT_BAM" "$SAM_FILE"
        
        echo "Ordenando $OUTPUT_BAM..."
        samtools sort -@ "$THREADS" -o "$SORTED_BAM" "$OUTPUT_BAM"
        
        echo "Indexando $SORTED_BAM..."
        samtools index "$SORTED_BAM"
        
        echo "Generando reporte para $SORTED_BAM..."
        samtools flagstat -@ "$THREADS" "$SORTED_BAM" > "$REPORT"
        
    else
        echo "No valid SAM file found in $SAM_FILE, skipping..."
    fi
done

echo "Finish Pipeline "
