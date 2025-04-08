#!/bin/bash
function replace_line {
   MATCH_PATTERN=$1
   NEW_VALUE="$2"
   IS_STRING=$3

   LINE=`grep -n "$MATCH_PATTERN" ./inputs/elmfire.data | cut -d: -f1`
   sed -i "$LINE d" ./inputs/elmfire.data
   if [ "$IS_STRING" = "yes" ]; then
      sed -i "$LINE i $MATCH_PATTERN = '$NEW_VALUE'" ./inputs/elmfire.data
   else
      sed -i "$LINE i $MATCH_PATTERN = $NEW_VALUE" ./inputs/elmfire.data
   fi
}

A_SRS="EPSG: 32610" # Spatial reference system - UTM Zone 10

# End inputs specification

ELMFIRE_VER=2024.0916

#./functions/functions.sh



SCRATCH=./scratch

OUTPUTS=./outputs
MISC=./misc

rm -f -r $SCRATCH $OUTPUTS #$MISC
mkdir $SCRATCH $OUTPUTS #$MISC

#cp $ELMFIRE_BASE_DIR/build/source/fuel_models.csv $MISC
#cp $ELMFIRE_BASE_DIR/build/source/building_fuel_models.csv $MISC

A_SRS="EPSG: 32610" # Spatial reference system - UTM Zone 10

~/binYiren/elmfire_$ELMFIRE_VER ./inputs/elmfire.data


   # Postprocess
   for f in $OUTPUTS/*.bil; do
      gdal_translate -a_srs "$A_SRS" -co "COMPRESS=DEFLATE" -co "ZLEVEL=9" $f $OUTPUTS/`basename $f | cut -d. -f1`.tif
   done
   gdal_contour -i 3600 `ls $OUTPUTS/time_of_arrival*.tif` ./outputs/hourly_isochrones.shp

   # Clean up and exit:
   rm -f -r $OUTPUTS/*.csv $OUTPUTS/*.bil $OUTPUTS/*.hdr

exit 0
