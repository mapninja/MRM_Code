# Validate feature geometries and prep for BigQuery



A script that checks for invalid geometries, separates them, and prepares the data for BigQuery:



```bash
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
```


1. Creates directories for valid and invalid geometries if they do not exist.
2. Iterates over each `.geojson` file in the current directory.
3. Initializes valid and invalid GeoJSON files with a basic FeatureCollection structure.
4. Extracts each feature and checks its geometry validity using `ogr2ogr`.
5. Adds valid features to the valid GeoJSON file and invalid features to the invalid GeoJSON file.
6. If no invalid geometries are found, renames the valid GeoJSON file to indicate all features are valid and removes the empty invalid file.


Reporting:

1. **Total files count**: The total number of GeoJSON files is determined at the start.
2. **Start timer**: The processing start time is recorded.
3. **Progress tracking**: After processing each file, the script updates the count of processed files and calculates the elapsed and estimated remaining time.
4. **Feedback**: Provides real-time feedback on the number of files processed, elapsed time, and estimated remaining time.
5. **Final summary**: Outputs the total time taken once processing is complete.

To run the script:

1. Save it as `validate_prep_bq.sh`.
2. Give it execution permission: `chmod +x validate_prep_bq.sh`.
3. Execute the script: `./validate_prep_bq.sh`.

Make sure `jq` and `ogr2ogr` are installed on your system. You can install them using package managers like `apt`, `brew`, or `yum`, depending on your OS.