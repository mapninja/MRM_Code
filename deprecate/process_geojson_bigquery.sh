#!/bin/bash

# Ensure required directories exist
mkdir -p ../invalid_geometry
mkdir -p ../valid_geometry_nl

process_file() {
    file=$1
    filename=$(basename "$file" .geojson)

    valid_geojson_nl="../valid_geometry_nl/${filename}_valid.geojson"
    invalid_geojson="../invalid_geometry/${filename}_invalid_features.geojson"

    # Start valid and invalid GeoJSON files with a FeatureCollection structure
    echo '{"type":"FeatureCollection","features":[]}' > "$invalid_geojson"

    # Process features, convert geometry to STRING, and handle invalid geometries
    jq -c '.features[]' "$file" | while read -r feature; do
        geometry=$(echo "$feature" | jq -c '.geometry')
        
        if [ "$geometry" == "null" ] || ! echo "$geometry" | ogrinfo /vsistdin/ -ro -al -so > /dev/null 2>&1; then
            jq ".features += [$feature]" "$invalid_geojson" > "${invalid_geojson}.tmp" && mv "${invalid_geojson}.tmp" "$invalid_geojson"
        else
            geometry_str=$(echo "$geometry" | jq -Rs .)
            feature_with_string_geometry=$(echo "$feature" | jq ".geometry = $geometry_str")
            echo "$feature_with_string_geometry" >> "$valid_geojson_nl"
        fi
    done

    # Check if the invalid GeoJSON file has any features, remove if empty
    if [ $(jq '.features | length' "$invalid_geojson") -eq 0 ]; then
        rm "$invalid_geojson"
    fi
}

export -f process_file

# Process each geojson file in parallel
parallel process_file ::: *.geojson

echo "Processing complete."
