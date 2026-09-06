#!/usr/bin/env bash     ## Run this script with Bash.
#
# pipeline.sh - Download a year of NOAA Storm Events, convert to GeoParquet.
#
# Usage:  ./pipeline.sh [YEAR]
# Example: ./pipeline.sh 2024
#
# Requires: bash, curl, gunzip, ogr2ogr (GDAL >= 3.5)


# Fail loudly instead of continuing through errors.
set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIG
# ---------------------------------------------------------------------------

# Use the first argument as the year, defaulting to 2024 if not provided
# Use the second argument as the month, defaulting to January (01) if not provided
YEAR=${1:-2024}
MONTH=${2:-01}

# Set a variable for the URL of the NOAA storm events dataset
# Set a variable for the search pattern to find the correct file for the specified year and month
# Directly access the NOAA data directory for the specified year and month, and search for the appropriate CSV file.
BASE_URL="https://www.ncei.noaa.gov/data/storm-events/access/original/${YEAR}/"
SEARCH="StormEvents_locations_s${YEAR}${MONTH}"

FILE_NAME=$(
    curl -s "$BASE_URL" |
    grep "$SEARCH" |
    grep -o 'StormEvents_locations[^"]*\.csv' |
    head -n 1
)

echo "Found NOAA file:"
echo "$FILE_NAME"

URL="${BASE_URL}${FILE_NAME}"

echo "Download URL:"
echo "$URL"

# Create directories for raw and processed data
mkdir -p data/raw data/processed

# Download the dataset and save it to the raw data directory
curl -LO "$URL" --output-dir data/raw

# Convert the CSV file to Parquet format using ogr2ogr
# Tell GDAL which fields to convert into geometry
ogr2ogr.exe -f Parquet data/processed/storms_${YEAR}_${MONTH}.parquet \
    -oo X_POSSIBLE_NAMES=LON \
    -oo Y_POSSIBLE_NAMES=LAT \
    -a_srs EPSG:4326 \
    "data/raw/$(basename "$URL")"

# Print a message indicating that the process is complete
echo "Done. Output: data/processed/storms_${YEAR}_${MONTH}.parquet"
