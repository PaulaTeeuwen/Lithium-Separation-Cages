import os
from ase.io import read, write

all_configs = read('crest_conformers.xyz', index=':')

for i, config in enumerate(all_configs):
    folder = f"GFN2_{i}"
    os.makedirs(folder, exist_ok=True)
    output_file = f'GFN2_{i}/crest_conformer_{i}.xyz'
    write(output_file, config)
    print(f"Saved conformer {i} to {output_file}")
