#!/bin/bash

# Groups file (uses commas)
GROUP_FILE="groups.tsv"
# Base folder for samples
SAMPLES_DIR="../samples"
# Output YAML file
OUTPUT_YAML="dataset.yaml"

echo "data_format: fastq" > "$OUTPUT_YAML"
echo "experiments:" >> "$OUTPUT_YAML"

# Get all unique groups (second column, comma separator)
for group in $(awk -F',' '{print $2}' "$GROUP_FILE" | sort | uniq); do
  echo "  - name: $group" >> "$OUTPUT_YAML"
  echo "    long_read_files:" >> "$OUTPUT_YAML"
  
  # Add all fastq.gz paths corresponding to the group
  awk -F',' -v grp="$group" -v dir="$SAMPLES_DIR" '
    $2==grp {
      fastq=sprintf("%s/%s/merged_barcode", dir, $1)
      cmd = "find " fastq " -name \"*.fastq.gz\" | head -n 1"
      cmd | getline fq
      close(cmd)
      if (fq != "") print "      - " fq
    }' "$GROUP_FILE" >> "$OUTPUT_YAML"

  echo "    labels:" >> "$OUTPUT_YAML"
  awk -F',' -v grp="$group" '
    $2==grp {print "      - " $1}
  ' "$GROUP_FILE" >> "$OUTPUT_YAML"
done

echo "✅ YAML file generated at $OUTPUT_YAML"
