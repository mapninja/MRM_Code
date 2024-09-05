#!/bin/bash

# Redirect all output (stdout and stderr) to a log file
exec > >(tee -a ./log.txt) 2>&1

# Set the BigQuery dataset and table
DATASET_NAME="sul-g-earth-engine-access:machines_reading_maps"   # Replace with your dataset name
TABLE_NAME="mrm_v3_cleaned_annotations"       # Replace with your table name

# Set the updated BigQuery table schema
SCHEMA="WKT:STRING,text:STRING,score:FLOAT,img_coordinates:STRING,postocr_label:STRING,filename:STRING"

# Set the GCS bucket path
GCS_BUCKET="gs://machines_reading_maps/csvgz/combined/"  # Replace with your GCS bucket path

# Loop through all gzipped CSV files in the GCS bucket
for file in $(gsutil ls ${GCS_BUCKET}*.csv.gz); do
    # Load the gzipped CSV file into BigQuery, appending to the same table
    bq load --source_format=CSV --skip_leading_rows=1 --autodetect --schema="$SCHEMA" --noreplace "$DATASET_NAME.$TABLE_NAME" "$file"

    echo "Appended $file to BigQuery table $DATASET_NAME.$TABLE_NAME"
done
