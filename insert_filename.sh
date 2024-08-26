#!/bin/bash

# Ensure the output directory exists
mkdir -p ../wgs84

# Define the function that processes each file
add_filename_to_features() {
    file="$1"
    filename=$(basename "$file" .geojson)
    
    # Insert the filename as a property in each feature
    jq --arg filename "$filename" '.features[].properties.filename = $filename' "$file" > "../wgs84/temp_${filename}_wgs84.geojson" && \
    mv "../wgs84/temp_${filename}_wgs84.geojson" "../wgs84/${filename}_wgs84.geojson"
}

# Export the function so it can be used by parallel
export -f add_filename_to_features

# Use parallel to process files concurrently
parallel add_filename_to_features ::: *.geojson
