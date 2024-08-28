total=$(find . -maxdepth 1 -name "*.geojson" | wc -l) && find . -maxdepth 1 -name "*.geojson" | parallel --bar --progress --jobs 100% 'filename=$(basename {} .geojson); ogr2ogr -f GeoJSONSeq /dev/stdout {} | jq -c "." > "../features/${filename}_features.json"; echo "Processed {}"'
