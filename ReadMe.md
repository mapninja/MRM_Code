# Machines Reading Maps on the Stanford Digital Repository

## MRM Versions for download

### Description

#### MRM V1

#### MRM V2

#### MRM V3

V3 is here: https://s3.msi.umn.edu/rumsey.v3/rumsey_57k_english.zip 

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

-----

# Processing MRM
## Processing Annotations

### `to_wgs84_insert_filename.sh`

**Summary:**

The script processes all GeoJSON files in the current directory by converting them to the WGS84 coordinate system and adding the filename as a property to each feature. It performs these tasks concurrently using all available CPU cores to maximize performance.

**Key Steps:**

1. **Output Directory Creation**: Ensures that the `../wgs84` directory exists for storing the processed files.

2. **File Processing Function**: Defines a function `process_geojson` that:
   - **Reprojects to WGS84**: Uses `ogr2ogr` to reproject each GeoJSON file to the WGS84 coordinate system (EPSG:4326) and saves the output with a modified filename in the `../wgs84` directory.
   - **Adds Filename Property**: Utilizes `jq` to insert the original filename as a new property (`filename`) within the properties of each feature in the GeoJSON file.

3. **Function Export**: Exports the `process_geojson` function so it can be accessed by the `parallel` command for multiprocessing.

4. **Parallel Processing**: Uses `find` to locate all `.geojson` files and `parallel` to execute the `process_geojson` function on each file concurrently, utilizing 100% of the available CPU resources.

**Overall Purpose:**

The script standardizes the coordinate system of multiple GeoJSON files to WGS84 and updates each feature with metadata about the source file. By leveraging parallel processing, it significantly reduces the time required to process large numbers of files.


### `wgs84_to_csv.sh`

**Summary:**

The script converts all GeoJSON files in the current directory to CSV format, with the geometry represented in Well-Known Text (WKT) format. It performs the conversion using the `ogr2ogr` tool and processes the files in parallel for improved performance.

**Key Steps:**

1. **Output Directory Creation**: Ensures that the `../csv` directory exists for storing the converted CSV files.

2. **File Processing Function**: Defines a function `process_file` that:
   - Converts each GeoJSON file to CSV format using `ogr2ogr`, storing the geometry in WKT format.
   - Saves the output CSV file in the `../csv` directory with a corresponding filename.

3. **Function Export**: Exports the `process_file` function to make it accessible for parallel processing.

4. **Parallel Processing**: Uses `find` to locate all `.geojson` files in the current directory and subdirectories, and processes them concurrently with `parallel` to speed up the conversion.

**Overall Purpose:**

The script converts multiple GeoJSON files to CSV format with WKT geometry and saves them in a designated directory. By utilizing parallel processing, it speeds up the conversion process, handling multiple files simultaneously.


### `combine_csvs.sh`

**Summary:**

The script combines a set of CSV files in the current directory into a specified number of larger CSV files, distributing the files as evenly as possible and saving the results in a `../combined` directory.

**Key Steps:**

1. **Output Directory Creation**: Ensures that the `../combined` directory exists for saving the combined files.
2. **Number of Combined Files**: The user provides the number of combined files as a command-line argument.
3. **Distribute Files**: The script calculates how many files should be placed in each combined file, distributing any remainder evenly across the first few combined files.
4. **File Combining**: 
   - It creates each combined CSV, including the header from the first file.
   - For each subsequent file, it appends the contents without the header to the combined file.
5. **Output**: The combined files are saved as `../combined/combined_####.csv`.

**Overall Purpose:**

The script organizes a directory of CSV files into a user-specified number of larger combined CSV files, distributing files evenly and retaining the header only once in each combined file.


### `gzip_all.sh`


**Summary:**

The script compresses all files in the `./combined` directory (and its subdirectories) using `gzip`.

**Key Steps:**

1. **Find Files**: The `find` command searches for all files (`-type f`) in the specified directory and its subdirectories.
2. **Compress Files**: For each file found, `gzip` is applied to compress it.

**Overall Purpose:**

The script automates the compression of all files in a specified directory using `gzip`, iterating through each file one by one.

### `Load2Bucket.sh`

**Summary:**

The script uploads files from a specified local directory to a Google Cloud Storage (GCS) bucket. It uses variables for the local directory and the remote GCS bucket path, making it easy to modify the paths without altering the core command.

**Key Steps:**

1. **Local Directory and GCS Bucket Configuration**: The script defines two variables:
   - `LOCAL_DIR`: The path to the local directory where the files are stored.
   - `REMOTE_BUCKET`: The path to the remote GCS bucket where the files will be uploaded.
   
2. **GCS Upload Command**: The script uses the `gcloud storage cp --recursive` command to recursively copy all files from the local directory to the specified GCS bucket.

**Overall Purpose:**

The script automates the process of uploading a local directory's contents to a GCS bucket, allowing for easy modification of the local directory and destination bucket via variables.

### `load_2_bq_from_bucket.sh`

**Summary:**

The script uploads all gzipped CSV files from a specified Google Cloud Storage (GCS) bucket into a BigQuery table. It processes each file by appending its content to the same BigQuery table, skipping the first header row, and applying a defined schema.

**Key Steps:**

1. **BigQuery Dataset and Table Configuration**: Sets the dataset and table to which the CSV files will be uploaded.
2. **Schema Definition**: Defines the schema for the table, specifying the data types for each column.
3. **GCS Bucket File Listing**: Uses `gsutil` to list all gzipped CSV files in the specified GCS bucket.
4. **CSV File Upload**:
   - For each CSV file, the script loads it into BigQuery.
   - The first row (header) is skipped, and the content is appended to the existing table using the `bq load` command.
5. **Logging**: Outputs a message confirming that each file has been appended to the BigQuery table.

**Overall Purpose**:

The script automates the process of loading multiple gzipped CSV files from a GCS bucket into a specific BigQuery table, ensuring that the schema is correctly applied and existing data is preserved while new data is appended.


