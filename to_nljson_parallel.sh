#!/bin/bash

# Create the output directory if it doesn't exist
mkdir -p ../features

# Count the total number of .geojson files in the current directory (ignoring subdirectories)
total=$(find . -maxdepth 1 -name "*.geojson" | wc -l)

# Find all .geojson files and process them in parallel
find . -maxdepth 1 -name "*.geojson" | parallel --bar --progress --jobs 100% '
    # Extract the base filename without the .geojson extension
    filename=$(basename {} .geojson)
    
    # Convert the GeoJSON file to newline-delimited JSON (GeoJSONSeq)
    # and save the output to a new file in the ../features directory
    ogr2ogr -f GeoJSONSeq /dev/stdout {} | jq -c "." > "../features/${filename}_features.json"
    
    # Print feedback indicating that the file has been processed
    echo "Processed {}"
'

# Print the total number of files processed
echo "Total files processed: $total"
