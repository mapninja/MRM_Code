#!/bin/bash

# Function to process GeoJSON files in the input folder using parallel
process_geojson_folder() {
    input_folder="$1"
    output_folder="$2"

    # Ensure the output directory exists
    mkdir -p "$output_folder"

    # Get a list of all JSON files in the input folder
    file_list=("$input_folder"/*.json)

    # Initialize the total number of files
    total_files=${#file_list[@]}
    processed_files=0

    # Export the output folder so it's available to parallel jobs
    export output_folder

    # Process each file in the file list using parallel
    for file_path in "${file_list[@]}"; do
        # Extract the base filename without extension
        filename=$(basename "$file_path" .json)

        # Construct the output file path
        output_file_path="$output_folder/${filename}_processed.geojsonl"

        # Export filename and output_file_path for parallel jobs
        export filename
        export output_file_path

        # Process each line in the file as a separate GeoJSON feature using parallel
        cat "$file_path" | parallel --pipe --block 10M --no-notice --jobs 4 \
        'jq -c --arg filename "$filename" "
            {
                type: \"Feature\",
                properties: {
                    filename: \$filename,
                    img_coordinates: (.properties.img_coordinates // null),
                    postocr_label: (.properties.postocr_label // null),
                    score: (.properties.score // null | tonumber),
                    text: (.properties.text // null)
                },
                geometry: .geometry
            }
        " >> $output_file_path'

        # Update the progress
        processed_files=$((processed_files + 1))
        echo "Processed $processed_files of $total_files files"
    done
}

# Call the function with the input and output directories
process_geojson_folder "./features" "./denested_features"
