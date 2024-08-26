#!/bin/bash

# Ensure the output directory exists
mkdir -p ../wgs84

# Define the function that processes each file
project_to_wgs84() {
    file="$1"
    filename=$(basename "$file" .geojson)
    
    # Reproject to WGS84
    ogr2ogr -f GeoJSON -t_srs EPSG:4326 "../wgs84/${filename}_wgs84.geojson" "$file"
}

# Export the function so it can be used by parallel
export -f project_to_wgs84

# Use parallel to process files concurrently
parallel project_to_wgs84 ::: *.geojson
