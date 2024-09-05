#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p ../newline

# Function to process each file
process_file() {
    file="$1"
    output="../newline/$(basename "$file" .geojson).ndjson"
    
    # Process the GeoJSON file and convert to NDJSON format
    jq -c '.features[] | 
    .geometry.coordinates = (.geometry.coordinates | tostring) |
    .' "$file" >> "$output"

    echo "Converted $file to newline-delimited GeoJSON and saved as $output"
}

export -f process_file

# Find all geojson files in the current directory and process them in parallel
find . -name "*.geojson" | parallel process_file
