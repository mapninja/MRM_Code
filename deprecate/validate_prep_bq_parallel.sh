#!/bin/bash

# Ensure required directories exist
mkdir -p ../invalid_geometry
mkdir -p ../valid_geometry

# Get total number of files to process
total_files=$(ls *.geojson | wc -l)
processed_files=0

# Start timer
start_time=$(date +%s)

process_file() {
    file=$1
    filename=$(basename "$file" .geojson)
    
    # Initialize valid and invalid GeoJSON files
    valid_geojson="../valid_geometry/${filename}_valid_geometries.geojson"
    invalid_geojson="../invalid_geometry/${filename}_invalid_geometries.geojson"
    
    # Start valid and invalid GeoJSON files with a FeatureCollection structure
    echo '{"type":"FeatureCollection","features":[]}' > "$valid_geojson"
    echo '{"type":"FeatureCollection","features":[]}' > "$invalid_geojson"
    
    # Extract features and check each one for validity
    jq -c '.features[]' "$file" | while read -r feature; do
        # Use ogr2ogr to check if the geometry is valid
        echo "$feature" | jq '.geometry' | ogr2ogr /vsistdin/ /vsistdout/ >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            jq ".features += [$feature]" "$valid_geojson" > "${valid_geojson}.tmp" && mv "${valid_geojson}.tmp" "$valid_geojson"
        else
            jq ".features += [$feature]" "$invalid_geojson" > "${invalid_geojson}.tmp" && mv "${invalid_geojson}.tmp" "$invalid_geojson"
        fi
    done

    # Check if the invalid GeoJSON file has any features
    if [ $(jq '.features | length' "$invalid_geojson") -eq 0 ]; then
        # If no invalid geometries, rename the valid file appropriately
        mv "$valid_geojson" "../valid_geometry/${filename}_all_valid.geojson"
        rm "$invalid_geojson"
    fi

    # Update processed files count
    echo "$file processed."
}

export -f process_file

# Use GNU Parallel to process files in parallel
parallel process_file ::: *.geojson

# Calculate total elapsed time
end_time=$(date +%s)
elapsed_time=$(( (end_time - start_time) / 60 ))

# Final summary
echo "Processing complete. Total time taken: $elapsed_time minutes."
