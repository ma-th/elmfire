#!/bin/bash

FUEL_SOURCE=landfire
export USE_SLURM=yes
YEARS=`seq 2012 2025`
STATES='ca or wa id nv az ut mt wy co nm'
DO_WUI=no

if [ "$FUEL_SOURCE" = "landfire" ]; then
   RUN_TEMPLATE=hindcast
   FUEL_VERSION[2016]=1.4.0
   FUEL_VERSION[2017]=1.4.0
   FUEL_VERSION[2018]=1.4.0
   FUEL_VERSION[2019]=2.0.0_2019
   FUEL_VERSION[2020]=2.1.0
   FUEL_VERSION[2021]=2.2.0
   FUEL_VERSION[2022]=2.2.0
   FUEL_VERSION[2023]=2.3.0
   FUEL_VERSION[2024]=2.4.0
   FUEL_VERSION[2025]=2.4.0
fi

if [ "$FUEL_SOURCE" = "planet" ]; then
   RUN_TEMPLATE=hindcast10m
   FUEL_VERSION[2016]=2016
   FUEL_VERSION[2017]=2017
   FUEL_VERSION[2018]=2018
   FUEL_VERSION[2019]=2019
   FUEL_VERSION[2020]=2020
   FUEL_VERSION[2021]=2021
   FUEL_VERSION[2022]=2022
   FUEL_VERSION[2023]=2023
   FUEL_VERSION[2024]=2024
   FUEL_VERSION[2025]=2025
fi

ACTIVE_FIRE_TIMESTAMP_NUM=1
ALREADY_BURNED_TIMESTAMP_NUM=null
WEST_BUFFER=30
SOUTH_BUFFER=30
EAST_BUFFER=30
NORTH_BUFFER=30
NUM_ENSEMBLE_MEMBERS=100
RUN_HOURS=24
export CALC_FITNESS=yes

TEMPLATE=$ELMFIRE_BASE_DIR/validation/template.sh
AVAILABLE_POLYGONS_CLI=$ELMFIRE_BASE_DIR/cloudfire/available_polygons.py
CWD=$(pwd)

for YEAR in $YEARS; do
   mkdir -p $CWD/$YEAR
   FIRENAMES=`$AVAILABLE_POLYGONS_CLI --active False --year $YEAR --list fires`

   for FIRENAME in $FIRENAMES; do
      STATE=`echo $FIRENAME | cut -d- -f1`
      RUN_THIS=`echo $STATES | grep $STATE | wc -l`
      if [ "$RUN_THIS" = "0" ]; then
         continue
      fi
      cd $CWD/$YEAR
      rm -f -r $FIRENAME
      mkdir -p $FIRENAME
      cd $FIRENAME
      cp -f $TEMPLATE ./00-run.sh
      cp -f $ELMFIRE_BASE_DIR/runs/hindcasts/* ./ 2> /dev/null
      cp -f -r $ELMFIRE_BASE_DIR/runs/hindcasts/templates ./

      ./00-run.sh $YEAR $FIRENAME $ACTIVE_FIRE_TIMESTAMP_NUM \
                  $ALREADY_BURNED_TIMESTAMP_NUM \
                  $WEST_BUFFER $SOUTH_BUFFER $EAST_BUFFER $NORTH_BUFFER \
                  $NUM_ENSEMBLE_MEMBERS $RUN_HOURS $FUEL_SOURCE ${FUEL_VERSION[YEAR]} \
                  $RUN_TEMPLATE $DO_WUI
   done
done

exit 0
