# NOAA Storms Pipeline
 
A one-command pipeline that downloads a month of NOAA Storm Events location data,
converts it to GeoParquet, and lands it ready for analysis in DuckDB,
GeoPandas, or QGIS.
 
## What it does
 
`pipeline.sh` takes a month (default: 2024 01), pulls the raw `locations` file
from NOAA's public archive and converts it to a single
GeoParquet file at `data/processed/storms_{YEAR}_{MONTH}.parquet`.
 
Total runtime: about 90 seconds for a typical year on a home internet
connection.
 
## The data
 
- Source: NOAA Storm Events Database
- License: Public domain (US federal data)
- What's in it: every recorded storm event location in the United States for the
  given month
- NOAA now publishes monthly archives rather than the annual file referenced in the course material, 
  so the pipeline was adapted to process a selected month.
- NOAA also now publishes the details and locations file separately so this is currently only pulling in the locations.
 
## How to run it
 
Requires GDAL (for `ogr2ogr`) and standard Unix utilities.
 
    git clone https://github.com/{your-username}/noaa-storms-pipeline.git
    cd noaa-storms-pipeline
    chmod +x pipeline.sh
    ./pipeline.sh
 
To run for a specific year and month:
 
    ./pipeline.sh 2023 09
 
## What I learned
 
The NOAA source structure has changed from the course specification. The originally targeted details files no longer contained coordinate information, so I adapted
the pipeline to dynamically discover source files and tested geometry creation against the companion locations dataset. The biggest challenge was debugging the interaction
between Bash, GDAL, and NOAA's current publication pattern.
 
## Stack
 
- bash
- curl
- GDAL / ogr2ogr
- GeoParquet
