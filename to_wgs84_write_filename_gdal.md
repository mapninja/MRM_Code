# GDAL Scripts and commands for prepping MRM geojson for BigQuery

## Convert to valid wgs84 geojson, and add `filename` property

```bash
mkdir -p ../wgs84
for file in *.geojson; do
    filename=$(basename "$file" .geojson)
    ogr2ogr -f GeoJSON -t_srs EPSG:4326 "../wgs84/${filename}_wgs84.geojson" "$file"
    jq --arg filename "$filename" '.features[].properties.filename = $filename' "../wgs84/${filename}_wgs84.geojson" > "../wgs84/temp_${filename}_wgs84.geojson" && mv "../wgs84/temp_${filename}_wgs84.geojson" "../wgs84/${filename}_wgs84.geojson"
done
```

This script performs the following steps:

1. Creates the output directory `../wgs84` if it does not exist.
2. Iterates over each `.geojson` file in the current directory.
3. Extracts the base filename without the `.geojson` extension.
4. Uses `ogr2ogr` to reproject the file to EPSG:4326 (WGS84) and saves the output to the `../wgs84` directory with a new filename.
5. Uses `jq` to add a `filename` property to each feature in the reprojected GeoJSON file, setting its value to the base filename.
6. Renames the temporary file to the final output file.

This approach ensures that the `filename` property is correctly added to each feature in the reprojected GeoJSON files.

## Check/Sort invalid geojson

```bash
mkdir -p ../invalid_geojson
for file in ../wgs84/*.geojson; do
    echo "Validating $file"
    ogrinfo -ro -al -so "$file" >/dev/null
    if [ $? -eq 0 ]; then
        echo "$file is valid."
    else
        echo "$file is invalid. Moving to ../invalid_geojson"
        mv "$file" ../invalid_geojson/
    fi
done
```

This script does the following:

1. Creates the `../invalid_geojson` directory if it does not exist.
2. Iterates over each `.geojson` file in the `../wgs84` directory.
3. Uses `ogrinfo` to attempt to read the file, suppressing the output.
4. Checks the exit status of `ogrinfo` using `$?`. If it is `0`, the file is valid. Otherwise, the file is considered invalid.
5. Prints the validation result for each file.
6. Moves invalid files to the `../invalid_geojson` directory.

