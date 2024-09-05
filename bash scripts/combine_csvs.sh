#!/bin/bash

# Create the output directory if it doesn't exist
mkdir -p ../combined

# Get the number of combined files to generate as a command-line argument
if [ -z "$1" ]; then
  echo "Please provide the number of combined files."
  exit 1
fi
num_combined_files=$1

# Find all CSV files in the current directory and store them in an array
csv_files=(*.csv)
total_files=${#csv_files[@]}

# Calculate the number of files per combined CSV
files_per_combined=$((total_files / num_combined_files))
remainder=$((total_files % num_combined_files))

# Initialize variables for file combining
current_file_index=0
combined_file_count=0

# Loop through the number of combined files to create
for ((i=0; i<num_combined_files; i++)); do
  combined_file_count=$((combined_file_count + 1))
  output_file="../combined/combined_$(printf "%04d" "$combined_file_count").csv"
  
  # Initialize the combined CSV file and add the header from the first file
  if [ "$current_file_index" -lt "$total_files" ]; then
    # Get header from the first CSV file
    head -n 1 "${csv_files[0]}" > "$output_file"
  fi
  
  # Determine how many files should go into this combined file
  num_files_in_this_combined=$files_per_combined
  if [ "$i" -lt "$remainder" ]; then
    num_files_in_this_combined=$((num_files_in_this_combined + 1))
  fi

  # Append the appropriate number of files to this combined CSV
  for ((j=0; j<num_files_in_this_combined; j++)); do
    if [ "$current_file_index" -lt "$total_files" ]; then
      # Skip the header of the subsequent CSV files and append to the output file
      tail -n +2 "${csv_files[$current_file_index]}" >> "$output_file"
      current_file_index=$((current_file_index + 1))
    fi
  done

  echo "Created $output_file with $num_files_in_this_combined files."
done

echo "Completed combining $total_files CSV files into $num_combined_files combined CSVs."
