import os
import shutil
import csv
from geojson_validator import validate_structure

def validate_geojson_files(geojson_path):
    # Create parallel directories for invalid and validated GeoJSON files
    invalid_geojson_path = os.path.join(os.path.dirname(geojson_path), 'invalid_geojson')
    validated_geojson_path = os.path.join(os.path.dirname(geojson_path), 'validated_geojson')
    
    os.makedirs(invalid_geojson_path, exist_ok=True)
    os.makedirs(validated_geojson_path, exist_ok=True)
    
    # Prepare the CSV file for invalid GeoJSON files
    csv_file_path = os.path.join(invalid_geojson_path, 'invalid_geojson_report.csv')
    with open(csv_file_path, mode='w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow(['Filename', 'Validation Errors'])
        
        # Loop through all files in the geojson_path directory
        for filename in os.listdir(geojson_path):
            if filename.endswith(".geojson"):
                file_path = os.path.join(geojson_path, filename)
                with open(file_path, 'r') as file:
                    geojson_data = file.read()
                    # Validate the GeoJSON file structure
                    is_valid, errors = validate_structure(geojson_data, return_dict=True)
                    if is_valid:
                        # Copy valid files to the validated_geojson directory
                        shutil.copy(file_path, validated_geojson_path)
                    else:
                        # Copy invalid files to the invalid_geojson directory
                        shutil.copy(file_path, invalid_geojson_path)
                        # Write the filename and validation errors to the CSV file
                        csv_writer.writerow([filename, '; '.join(errors)])

# Example usage
# geojson_path = '/path/to/your/geojson_directory'
# validate_geojson_files(geojson_path)



