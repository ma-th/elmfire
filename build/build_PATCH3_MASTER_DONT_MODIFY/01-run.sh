#!/bin/bash

#. ./99-post_funcs.sh --source-only
ELMFIRE_VER=2025.0526


ELMFIRE_EXECUTABLE=/home/dwip/bin_PATCH3/elmfire_$ELMFIRE_VER
ELMFIRE_MPIRUN=/usr/bin/mpirun
ELMFIRE_NUM_MPI_PROCESSES=`cat /proc/cpuinfo | grep "cpu cores" | cut -d: -f2 | tail -n 1 | xargs`
ELMFIRE_HOSTS=`printf "$(hostname),%.0s" {1..64}`




echo "Start: "`date +%H:%M:%S`
STARTSEC=`date +%s`

rm -f -r ./scratch ./misc ./outputs
mkdir ./scratch ./misc ./outputs

#cp elmfire.data.in $INPUTS/elmfire.data
cp ./miscSOTA/fuel_models.csv ./misc
cp ./miscSOTA/building_fuel_models.csv ./misc

#/home/dwip/bin_PATCH3/elmfire_debug_$ELMFIRE_VER elmfire-bfm7-H-SS-Copy1.data
#/home/dwip/binYiren/elmfire_2024.0916 elmfire-bfm7-H-SS-Copy1.data

ELMFIRE=$ELMFIRE_EXECUTABLE
MPIRUN=$ELMFIRE_MPIRUN

$MPIRUN -np $ELMFIRE_NUM_MPI_PROCESSES -host $ELMFIRE_HOSTS $ELMFIRE elmfire-bfm7-H-SS-Copy1.data

echo "www"


echo "Finish: "`date +%H:%M:%S`
ENDSEC=`date +%s`
let "RUNTIME = ENDSEC - STARTSEC"
echo "Wall clock time:  $RUNTIME s"


exit 0

#DUMP_TOTAL_DFC_RECEIVED         = .TRUE.
#DUMP_TOTAL_RAD_RECEIVED         = .TRUE.
#DUMP_HRR_TRANSIENT              = .TRUE.
