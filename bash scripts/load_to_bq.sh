#!/bin/bash

# Set the BigQuery dataset and table
DATASET_NAME="sul-g-earth-engine-access:machines_reading_maps"   # Replace with your dataset name
TABLE_NAME="test_bulk_csv_load_WKT_AS_STRING"       # Replace with your table name

# Set the updated BigQuery table schema
SCHEMA="WKT:STRING,text:STRING,score:FLOAT,img_coordinates:STRING,postocr_label:STRING,filename:STRING"

# Loop through all CSV files in the ../csv directory
for file in ../csv/*.csv; do
    # Load the CSV file into BigQuery, appending to the same table
    bq load --source_format=CSV --skip_leading_rows=1 --schema="$SCHEMA" --noreplace "$DATASET_NAME.$TABLE_NAME" "$file"

    echo "Appended $file to BigQuery table $DATASET_NAME.$TABLE_NAME"
done
