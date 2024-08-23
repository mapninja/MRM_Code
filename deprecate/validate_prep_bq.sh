#!/bin/bash

# Ensure required directories exist
mkdir -p ../invalid_geometry
mkdir -p ../valid_geometry

# Get total number of files to process
total_files=$(ls *.geojson | wc -l)
processed_files=0

# Start timer
start_time=$(date +%s)

for file in *.geojson; do
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
    processed_files=$((processed_files + 1))

    # Calculate elapsed time and estimated time remaining
    current_time=$(date +%s)
    elapsed_time=$(( (current_time - start_time) / 60 ))
    estimated_total_time=$(( (elapsed_time * total_files) / processed_files ))
    estimated_remaining_time=$(( estimated_total_time - elapsed_time ))

    # Provide processing feedback
    echo "Processed $processed_files of $total_files files."
    echo "Elapsed time: $elapsed_time minutes."
    echo "Estimated remaining time: $estimated_remaining_time minutes."
done

# Final summary
echo "Processing complete. Total time taken: $elapsed_time minutes."
