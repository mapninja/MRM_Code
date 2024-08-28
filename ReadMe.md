# Machines Reading Maps on Google Cloud Platform

## GCP Bucket Name:

The following bucket contains the complete results of Machines Reading Maps v1 & v2:  

`https://console.cloud.google.com/storage/browser/machines_reading_maps`

The `machines_reading_maps` bucket is organized into 4 folders:

1. `/downloads/` - Zipped files for direct download of the complete corpus of MRM results, including:
    * luna_omo_metadata_56628_20220724.zip - metadata for mrm v1 & v2, in csv format
    * normalized_luna_omo_metadata_20230405.zip - metadata for mrm v1 & v2, in json format
    * geojson_testr_syn_54119.zip - v1 results geojson files
    * geojson_202211.zip - v2 results geojson files

2. `/metadata/` - unzipped metadata files in json & csv formats
3. `/v1/` - Version 1 geojson files, unzipped to `./geojson_testr_syn/`
4. `/v2/` - Version 2 geojson files, unzipped to `./geojson_202211/`

## Metadata on BigQuery

The metadata files have been ingested to table on BigQuery:
`sul-g-earth-engine-access.machines_reading_maps.luna_omo_metadata_56628_20220724_orig`

## Annotations on BigQuery

Getting annotations into a BigQuery table is non-trivial, and is currently ongoing. There are several complications, including:

1. GeoJSON produced by MRM uses `EPSG:3857` Web Mercator coordinates for the `geometry` property, rather than `EPSG:4326`, and is therefore non-compliant geojson
2. MRM GeoJSON features are contained in FeatureCollections, while BQ requires features and properties are unnested.
3. MRM GeoJSON records the `geometry` coordinates as arrays, while BQ requires `geometry` coordinates are stored as `STRING`
4. MRM GeoJSON contains invalid `geometry` values, including `geometry='NULL'`, out-of-range LATLONG coordinates, and polygons with intersecting edges. BQ Rejects these records.
5. The data collection is massive. At ~54k gejson files, with >90 million annotation records, the dataset approaches 100GB in newline delimited format. 

## Processing Annotations

## mrm_2_bq_tools_nb.ipynb


### to_geojson()

The `to_geojson` function converts all output MRM "geojson'" files to WGS84, restructures them into a valid GeoJSON format, and adds the filename property to each feature.


1. **Directory Iteration**: The function iterates over all `.geojson` files in the provided directory.
2. **GeoJSON Handling**: Each file is opened using GDAL/OGR.
3. **Coordinate Transformation**: Geometries are transformed to WGS84 using the coordinate transformation.
4. **Field Addition**: The original fields are copied, and a new `filename` field is added to each feature.
5. **Output Writing**: The reprojected features are written to new GeoJSON files in the specified output directory.


### separate_geometries()

1. Invalid Filename Handling: The invalid geometries file is named using the pattern {original_filename}_invalid_geometries.geojson.
2. Directory Iteration and File Handling: The function processes each GeoJSON file, validates geometries, and saves valid and invalid geometries into separate files and directories.
3. Output Directory Structure: Valid geometries are stored in the valid_output_path directory, while invalid geometries are stored in the invalid_output_path directory with the new naming pattern for easier identification.


# Processing MRM


V3 is here: https://s3.msi.umn.edu/rumsey.v3/rumsey_57k_english.zip 



