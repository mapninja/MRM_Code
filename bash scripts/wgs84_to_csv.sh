#!/bin/bash

# Create the output directory if it doesn't exist
mkdir -p ../csv

# Function to process a single file
process_file() {
    file="$1"
    filename=$(basename "$file" .geojson)
    output="../csv/${filename}.csv"
    
    # Run the GDAL command to convert GeoJSON to CSV with WKT geometry
    ogr2ogr -f CSV "$output" "$file" -lco GEOMETRY=AS_WKT
    
    # Print a message for each processed file
    echo "Converted $file to $output"
}

export -f process_file

# Use find to locate all geojson files and process them in parallel
find . -name "*.geojson" | parallel process_file
