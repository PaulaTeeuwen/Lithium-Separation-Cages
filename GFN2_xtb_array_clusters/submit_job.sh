#!/bin/bash

# In terminal: bash submit_job.sh

# Define the element symbol as a variable
ELEMENT="Na"  # Replace with your desired element symbol (Na, Mg, Ca, K)

# Define charge based on element
if [[ $ELEMENT == "Na" || $ELEMENT == "Li" || $ELEMENT == "K" ]]; then
    CHRG=1
elif [[ $ELEMENT == "Mg" || $ELEMENT == "Ca" ]]; then
    CHRG=2
elif [[ $ELEMENT == "Solvent" ]]; then
    CHRG=0
else
    echo "Unsupported element: $ELEMENT"
    exit 1
fi

echo "Starting job submission and processing for element: $ELEMENT with charge $CHRG"

log_file="${ELEMENT}_ensemble_GFN2.log"
energies_log="${ELEMENT}_ensemble_GFN2_energies.log"
exec > "${log_file}" 2>&1

echo "Running python3 getxyz.py"
python3 getxyz.py

if [[ $ELEMENT == "Solvent" ]]; then
    num_structures=$(grep -o "\b60\b" crest_conformers.xyz | wc -l)
else
    num_structures=$(cat crest_conformers.xyz | grep "${ELEMENT}" | wc -l)
fi

echo "The number of conformers in crest_conformers is $num_structures"
num_structures=$((num_structures - 1)) #starts at 0

# Submit the array job and capture the job ID
echo "Submitting SLURM job array for $ELEMENT"
job_id=$(sbatch --array=0-${num_structures} --export=ELEMENT=${ELEMENT},CHRG=${CHRG} sbatch.xtb | awk '{print $4}')

echo "Submitted SLURM job array with ID: $job_id"

# Submit the job that extracts the energies and prints the lowest one
echo "Submitting job to extract energies with job dependency"
dependency_string="afterok:$job_id"
sbatch --dependency="$dependency_string" --export=ELEMENT=${ELEMENT} extractenergies.sh > "$energies_log"

echo "Job submission completed for $ELEMENT"
