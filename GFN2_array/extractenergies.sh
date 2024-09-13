#!/bin/bash
#SBATCH --time=0-0:05:0
#SBATCH -J GFN2_ensemble_energies.QCG
#SBATCH --mincpus=10
# Number of MPI tasks
#SBATCH -n 1

# Number of cores per task
#SBATCH -c 1

##SBATCH -p TEST

export SLURM_SUBMIT_DIR
export SLURM_ARRAY_TASK_ID

dir_path="$SLURM_SUBMIT_DIR"
cd "$dir_path"

element="$ELEMENT"
log_file="${element}_ensemble_GFN2_energies.log"
exec > "$log_file" 2>&1

echo $element

if [[ $element == "Solvent" ]]; then
    num_structures=$(grep -o "\b60\b" crest_conformers.xyz | wc -l)
else
    num_structures=$(cat crest_conformers.xyz | grep "${ELEMENT}" | wc -l)
fi

num_structures=$((num_structures - 1))

echo $num_structures

energies=()

# Loop through each structure and extract energies
for (( i=0; i<=${num_structures}; i++ )); do
    # Extract total free energy from output file
    energy=$(grep "TOTAL FREE ENERGY" GFN2_${i}/${element}_GFN2_${i}_output | awk '{print $5}')
    
    # Add energy to energies array
    energies+=("$energy")
done

# Print all energies
echo "Total Free Energies:"
for energy in "${energies[@]}"; do
    echo "$energy"
done

# Find the lowest energy and its index
lowest_free_energy=$(printf '%s\n' "${energies[@]}" | sort -n | head -n 1)

# Find index of lowest energy
lowest_free_energy_index=$(for i in "${!energies[@]}"; do echo "${energies[$i]} $i"; done | awk -v min="$lowest_free_energy" '{if ($1 == min) print $2}')

echo "Lowest total free energy found: $lowest_free_energy at index $lowest_free_energy_index"

