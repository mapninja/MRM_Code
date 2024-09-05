gcloud storage cp --recursive /Users/maples/Scratch/MRM/data/v3/combined gs://machines_reading_maps/csvgz #!/bin/bash

# Set the local directory and remote bucket as variables
LOCAL_DIR="/Users/maples/Scratch/MRM/data/v3/combined"   # Change this to the desired local directory
REMOTE_BUCKET="gs://machines_reading_maps/csvgz"          # Change this to the desired GCS bucket

# Run the gcloud command to copy files from the local directory to the remote GCS bucket
gcloud storage cp --recursive "$LOCAL_DIR" "$REMOTE_BUCKET"
