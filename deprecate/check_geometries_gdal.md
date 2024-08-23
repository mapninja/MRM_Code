## Check for invalid geometries

```bash
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
```


1. Creates directories for valid and invalid geometries if they do not exist.
2. Iterates over each `.geojson` file in the current directory.
3. Initializes temporary files for valid and invalid geometries as empty GeoJSON FeatureCollections.
4. Extracts each feature from the GeoJSON file and checks its geometry validity using `ogrinfo`.
5. Appends valid features to the `valid_temp` file and invalid features to the `invalid_temp` file.
6. If there are no invalid geometries, copies the original file to the `../valid_geometry` directory.
7. If there are invalid geometries, writes valid and invalid geometries to their respective files in the appropriate directories.
8. Cleans up temporary files.

Make sure you have `jq` and `ogrinfo` installed on your system. You can install them using package managers like `apt`, `brew`, or `yum`, depending on your operating system.

Save this script as a shell script file (e.g., `process_geojson.sh`), give it permissions, and run it in the directory containing your GeoJSON files:


```bash
chmod +x process_geojson.sh
./process_geojson.sh
```

