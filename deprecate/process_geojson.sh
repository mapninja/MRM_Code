bash
#!/bin/bash

mkdir -p ../invalid_geometry
mkdir -p ../valid_geometry

for file in *.geojson; do
    filename=$(basename "$file" .geojson)
    
    # Create temporary files for valid and invalid geometries
    valid_temp=$(mktemp)
    invalid_temp=$(mktemp)
    
    # Initialize the temporary files as empty GeoJSON FeatureCollections
    echo '{"type":"FeatureCollection","features":[]}' > "$valid_temp"
    echo '{"type":"FeatureCollection","features":[]}' > "$invalid_temp"
    
    # Extract features and check each one for validity
    jq -c '.features[]' "$file" | while read -r feature; do
        echo "$feature" | jq '.geometry' | ogrinfo /vsistdin/ -ro -al -so > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$feature" | jq -c '.' >> "$valid_temp"
        else
            echo "$feature" | jq -c '.' >> "$invalid_temp"
        fi
    done

    # Check if invalid_temp is empty (i.e., no invalid geometries)
    if [ $(jq '.features | length' "$invalid_temp") -eq 0 ]; then
        cp "$file" "../valid_geometry/${filename}_all_valid.geojson"
    else
        # Write valid and invalid geometries to their respective files
        jq -s '{type: "FeatureCollection", features: .}' "$valid_temp" > "../valid_geometry/${filename}_valid_geometries.geojson"
        jq -s '{type: "FeatureCollection", features: .}' "$invalid_temp" > "../invalid_geometry/${filename}_invalid_geometries.geojson"
    fi

    # Clean up temporary files
    rm "$valid_temp" "$invalid_temp"
done