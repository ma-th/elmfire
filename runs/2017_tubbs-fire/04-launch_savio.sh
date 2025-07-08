#!/bin/bash
'''
#SBATCH --account=co_gollner
#SBATCH --partition=savio4_htc
#SBATCH --qos=gollner_htc4_normal
#SBATCH --job-name=tubbs_54-test
#SBATCH --output=./logs/output_%A_%a.log         
#SBATCH --error=./logs/error_%A_%a.log           
#SBATCH --time=0-20:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=56
'''

#source ~/.bashrc


RUN_FILE="01-run.sh"
INPUTS="inputs"
DATA_FILES="elmfire-const.data" 
RUN_IDS="62-C" 


ELMFIRE_VER=${ELMFIRE_VER:-2025.0526}

data_file=$DATA_FILES
run_id=$RUN_IDS
WORK_DIR="./run_${run_id}"


mkdir -p "${WORK_DIR}"
cp "${RUN_FILE}" "${WORK_DIR}/"
cp -r "${INPUTS}" "${WORK_DIR}/"
cp "${data_file}" "${WORK_DIR}/"

cp -r "misc" "${WORK_DIR}/"
cp "raster_percentile_p.py" "${WORK_DIR}/"
cp "99-post_funcs.sh" "${WORK_DIR}/"

SCRIPT_PATH="$(realpath "$0")"
cp "$SCRIPT_PATH" "$WORKDIR/"

echo "Contents of ${WORK_DIR}:"
ls -l "${WORK_DIR}"

#echo "Running Simulation $simulation_index on $(hostname)"
echo "Script: ${RUN_FILE}, Data File: ${data_file}, Run ID: ${run_id}"

# Execute the script within the work directory
cd "${WORK_DIR}" || exit 1
chmod +x "${RUN_FILE}"
./"${RUN_FILE}" "${data_file}" "${run_id}" ${ELMFIRE_VER}

