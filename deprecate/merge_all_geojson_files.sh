#!/bin/bash

# Initialize the output file
> mrm_v2_annotations_all.geojsonl

# Get a list of all GeoJSON files in the output directory
files=(output/*.geojson)
total_files=${#files[@]}

# Initialize a counter
count=0

# Record the start time
start_time=$(date +%s)

# Iterate over each GeoJSON file
for file in "${files[@]}"; do
  # Increment the counter
  ((count++))

  # Use jq to parse the file and write each line (feature) to the output file
  jq -c '.' "$file" >> mrm_v2_annotations_all.geojsonl

  # Calculate the elapsed time and the estimated total time
  elapsed_time=$(($(date +%s) - start_time))
  estimated_total_time=$(($elapsed_time * $total_files / $count))

  # Print progress information
  echo "Processed $count of $total_files files. Estimated time remaining: $(($estimated_total_time - $elapsed_time)) seconds."
done