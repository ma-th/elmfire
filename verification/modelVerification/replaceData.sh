#!/bin/bash

# Function to replace lines in the elmfire.data file
function replace_line {
   local MATCH_PATTERN=$1
   local NEW_VALUE="$2"
   local IS_STRING=$3
   local FILE=$4

   LINE=`grep -n "$MATCH_PATTERN" "$FILE" | cut -d: -f1`
   sed -i "${LINE}d" "$FILE"
   if [ "$IS_STRING" = "yes" ]; then
      sed -i "${LINE}i $MATCH_PATTERN = '$NEW_VALUE'" "$FILE"
   else
      sed -i "${LINE}i $MATCH_PATTERN = $NEW_VALUE" "$FILE"
   fi
}

# Begin specifying inputs
CELLSIZE=20.0  # Grid size in meters
DOMAINSIZE=12000.0  # Height and width of domain in meters
SIMULATION_TSTOP=99999.0  # Simulation stop time (seconds)
LH_MOISTURE_CONTENT=30.0  # Live herbaceous moisture content, percent
LW_MOISTURE_CONTENT=60.0  # Live woody moisture content, percent
A_SRS="EPSG: 32610"  # Spatial reference system - UTM Zone 10

# Directory containing all elmfire.data files
DATA_DIR="./"
FILES="${DATA_DIR}elmfire_jfsp*.data"

# Loop through each elmfire.data file
for FILE in $FILES; do
    echo "Processing $FILE..."

    replace_line SIMULATION_TSTOP $SIMULATION_TSTOP no "$FILE"

done

exit 0
