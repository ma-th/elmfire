#!/bin/bash

if ! command -v conda &> /dev/null; then
    source ~/miniconda3/etc/profile.d/conda.sh 
fi

TAR_NAME="fuels-topography"

conda run -n elmfire python3 $ELMFIRE_BASE_DIR/cloudfire/fuel_wx_ign.py \
    --name="$TAR_NAME" --outdir="$TAR_NAME" \
    --center_lon=-122.3587911100 --center_lat=38.4566559094 \
    --do_fuel=True \
    --fuel_source='landfire' --fuel_version='2.4.0' \
    --do_wx=False \
    --wx_type='historical' --wx_start_time="2018-11-08 14:00" --wx_num_hours=72 \
    --do_ignition=False \
#    --point_ignition=True --ignition_lon=-121.3 --ignition_lat=40.2 --ignition_radius=300.

wait

tar -xf "$TAR_NAME/$TAR_NAME.tar" -C "$TAR_NAME"

#TAR_FILE="$TAR_NAME.tar"
#if [[ -f "$TAR_FILE" ]]; then
#    echo "Extracting $TAR_FILE..."
#    tar -xf "$TAR_NAME/$TAR_FILE"
#    echo "Extraction complete."
#else
#    echo "Error: Expected tar file '$TAR_FILE' not found."
#fi
