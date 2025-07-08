#!/bin/bash

. ./99-post_funcs.sh --source-only

#export PROJ_DATA=/global/home/groups/consultsw/sl-7.x86_64/modules/proj/9.1.0/share/proj

STARTSEC=`date +%s`

progress_message "Start new episode"

RUN_DIR=$(dirname "$0")
cd "$RUN_DIR" || exit 1

DATA_FILE=$1
RUN_ID=$2
ELMFIRE_VER=$3

OUTPUTS=./outputs
SCRATCH=./scratch
OUT_DIR="out_${RUN_ID}"

rm -f -r $SCRATCH $OUTPUTS 
mkdir -p $SCRATCH $OUTPUTS

cp 01-run.sh $OUTPUTS/01-run.sh
cp $DATA_FILE $OUTPUTS/$DATA_FILE


#export ELMFIRE_INSTALL_DIR="$ELMFIRE_BASE_DIR/build/linux/bin"
#ELMFIRE_INSTALL_DIR=${ELMFIRE_INSTALL_DIR:-$ELMFIRE_BASE_DIR/build/linux/bin}
ELMFIRE=$ELMFIRE_INSTALL_DIR/elmfire_$ELMFIRE_VER

echo "${ELMFIRE}"
echo "SLURM_NTASKS: ${SLURM_NTASKS}"


SOCKETS=`lscpu | grep 'Socket(s)' | cut -d: -f2 | xargs`
CORES_PER_SOCKET=`lscpu | grep 'Core(s) per socket' | cut -d: -f2 | xargs`
let "NP = SOCKETS * CORES_PER_SOCKET"

progress_message "Launching ELMFIRE"
mpirun --mca btl tcp,self,vader --map-by core --bind-to core --oversubscribe -np 20 $ELMFIRE $DATA_FILE >& $OUTPUTS/elmfire.out

wait

ENDSEC=`date +%s`
let "RUNTIME = ENDSEC - STARTSEC"
progress_message "ELMFIRE run is complete"
echo "Simulation wall clock time:  $RUNTIME s"


echo "Post-processing raster percentiles."

#source /global/software/rocky-8.x86_64/manual/modules/langs/anaconda3/2024.02-1/etc/profile.d/conda.sh
#conda activate fuels
#echo "Using Conda Environment: $(conda info --envs | grep '*' | awk '{print $1}')"


source ~/envs/fuels/bin/activate


OUTPUT_TYPES=("ember_flux" "flame_length" "time_of_arrival" "total_dfc" "total_rad" "hrr_transient" "flin" "hpua" "tagged" "spread")
PERCENTILES=("50")

./raster_percentile_p.py --root_dir "$OUTPUTS" --output_types "${OUTPUT_TYPES[@]}" --percentile_vals "${PERCENTILES[@]}"
wait

#rm ./post_processed/hrr_transient_tb_t_25200.tif ./post_processed/hrr_transient_tb_t_25200.tif


echo "Post-processing complete. Cleaning up."

mkdir -p $OUTPUTS/raw

for FILE in "${OUTPUT_TYPES[@]}"; do
   FILE_PATTERN="${FILE}_*.tif"
   find "$OUTPUTS" -maxdepth 1 -type f -name "$FILE_PATTERN" -exec mv {} "$OUTPUTS/raw/" \;
done
wait

rm -f -r $OUT_DIR
mkdir -p $OUT_DIR
cp -r $OUTPUTS/* $OUT_DIR/

rm -f -r $SCRATCH $OUTPUTS ./inputs ./99-post_funcs.sh ./raster_percentile_p.py ./TIME_CHECK.csv ./TIME_CHECK_GIT.csv

exit 0
