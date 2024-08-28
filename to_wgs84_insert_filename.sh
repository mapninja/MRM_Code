#!/bin/bash

# Ensure the output directory exists
mkdir -p ../wgs84

# Define the function that processes each file
process_geojson() {
    file="$1"
    filename=$(basename "$file" .geojson)
    
    # Reproject to WGS84 using ogr2ogr
    ogr2ogr -f GeoJSON -t_srs EPSG:4326 "../wgs84/${filename}_wgs84.geojson" "$file"
    
    # Add the filename as a property in each feature using jq
    jq --arg filename "$filename" '.features[].properties.filename = $filename' "../wgs84/${filename}_wgs84.geojson" > "../wgs84/temp_${filename}_wgs84.geojson" && \
    mv "../wgs84/temp_${filename}_wgs84.geojson" "../wgs84/${filename}_wgs84.geojson"
}

# Export the function so it can be used by parallel
export -f process_geojson

# Use parallel to process files concurrently, utilizing all available CPU cores
find . -name "*.geojson" | parallel --progress --jobs 100% process_geojson {}
