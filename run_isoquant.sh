#!/bin/bash                                                                                                                                                               

# el environment que hay que usar es isoquant
                                                                                                                                                                     
REFERENCE="/GRCm39_vM37.primary_assembly.genome.fa"  # <-- adjust path to your reference 
GTF="/gencode.vM37.annotation.gtf"                   # <-- adjust path to your gtf reference
SAMPLES_DIR="dataset.yaml"                           # <-- parent dir of all barcode folders                                                                              
OUTPUT_DIR="../results/isoquant"                     # <-- where output folders will be created                                     
THREADS=24                                           # <-- depend on the computer/cluster you are using                                                                            
                                                                                                                                                                                                                                                                                                                            
mkdir -p "$OUTPUT_DIR"

echo "🚀 Ejecutando IsoQuant..."
echo "Referencia: $REFERENCE"
echo "Anotación: $GTF"
echo "Salida: $OUTPUT_DIR"
echo

isoquant.py \
  --yaml "$SAMPLES_DIR" \
  --reference "$REFERENCE" \
  --genedb "$GTF" \
  --data_type nanopore \
  --threads "$THREADS" \
  --transcript_quantification all \
  --gene_quantification all \
  -o "$OUTPUT_DIR"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "🎉 IsoQuant finish correct."
else
  echo "❌ Error IsoQuant (code $EXIT_CODE)"
fi
