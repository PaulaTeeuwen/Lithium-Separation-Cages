# Lithium-Separation-Cages
This repository contains the scripts and xyz-files relevant for studying the Li-separation ability of coordination cages in acetonitrile.

## Software used
- [Scigress] (https://www.fqs.pl/en/chemistry/products/scigress) v2.6
- [ORCA](https://www.faccts.de/orca/) v5.0.4
- [xtb](https://github.com/grimme-lab/xtb) v6.6.0
- [CREST](https://github.com/crest-lab/crest) v3.0.2
- SLURM scheduler (for job arrays)
- Python 3.9.12 (for script execution)

  For installing these tools, refer to their respective documentation or package managers suitable for your system.

## Repository Structure
- Scripts/: contains all bash and python scripts
- MM3_Scigres_cages/: contains all MM3 optimized cage structures (*cage.mol*)
- GFN2_ORCA_cages/: contains all GFN2-xTB optimized cage structures (*cage.xyz*), including the files (*cage.in* and *cage_input.xyz*) used as input for the *ORCA* calculations
- GFN2_xtb_cages/: contains all the GFN2-xTB optimized cage structures (*cage_xtbopt.xyz*), their calculated vibrational spectra (*cage_vibspectrum*) and the input used for the *xtb* calculation (*cage_ORCA.xyz*).
- DFT_SPE_ORCA_cages/: contains the input (*cage.in*) and output (*cage_output*) files for the r2SCAN-3c SPE calculations on the cages using *ORCA*.
- GFN2_lowest_clusters/: lowest energy conformers of metal-clusters found at GFN2-xTB level
- DFT_lowest_clusters/: lowest energy conformers of metal-clusters found at r2SCAN-3c//GFN2-xTB level

Here, "*cage*" refers to the type of cage: trencage, trenLi, trenNa, trenK, trenCa, trenMg, trenH, trenHLi, trenHNa, trenHK, trenHCa and trenHMg.

## Cages
1) MM3 modelling in Scigress of the protonated cages (local computer).
2) GFN2-xTB optimization of the MM3-cages in step 1 using *ORCA* (CSD3 cluster). Charge c is 4, 8 or 12 depending on the cage.

   ORCA.in:
   ```
   ! XTB2 OPT NUMFREQ
   %PAL NPROCS 8 END
   %maxcore 2658

   ! ALPB(Acetonitrile)

   *xyzfile c 1 input.xyz
   ```

3) GFN2-xTB optimization of the cages from step 2 using *xtb* (NEST cluster).The trenLiH cage input structure was obtained from XRD.

   ```
   xtb structure.xyz --ohess vtight --alpb acetonitrile --chrg c > output
   ```

4) r2SCAN-3c single point energy (SPE) calculation using *ORCA* (NEST cluster)
   
   ORCA.in:
   ```
   ! r2SCAN-3c ENERGY TightSCF defgrid3 def2/J
   %maxcore 8000
   %PAL NPROCS 10 END
   %CPCM SMD TRUE
          SMDSOLVENT "MeCN"
   END
   *xyzfile c 1  xtbopt.xyz
   ```

## Clusters
1) Use Quantum Cluster Growth (QCG) algorithm in CREST to build solvent shells of n = 10 or n = 20 MeCN molecules around a metal ion (M = Li, Na, K, Ca, Mg). Charge c is 1 for Li, Na and K and 2 for Ca and Mg. A file called *crest_best* is created after each QCG run.
   
   ```
   /path-to-crest/crest M.xyz -qcg acetonitrile.xyz -nsolv n --gfnff --chrg 2 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile --ensemble --mdtime 50 > output
   ```
   
   Pure solvent clusters are made via the -gsolv keyword for the Na-cluster generation:
   ```
   /path-to-crest/crest Na.xyz -qcg acetonitrile.xyz -nsolv 10 --gfnff --chrg 1 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile **--gsolv** --mdtime 50 --freqlvl gfnff > output 
   ```
   
   The K<sub>n=10</sub> cluster is made in three consecutive qcg steps:
   - ```/path-to-crest/crest K.xyz -qcg acetonitrile.xyz -nsolv n --gfnff --chrg 2 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile --ensemble --mdtime 50 > output```
   - ```/path-to-crest/crest K_n10_step1_crest_best_-2MeCN.xyz -qcg acetonitrile.xyz -nsolv n --gfnff --chrg 2 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile --ensemble --mdtime 50 > output```
   - ```/path-to-crest/crest K_n10_step2_crest_best_-1MeCN.xyz -qcg acetonitrile.xyz -nsolv n --gfnff --chrg 2 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile --ensemble --mdtime 50 > output```

   Finally, additional QCG runs are performed starting from [K@(MeCN)<sub>6</sub>]<sup>1+</sup> and [Na@(MeCN)<sub>6</sub>]<sup>2+</sup> found in the Cambridge Structural Database (CSD). In these cases, n is either 4 or 14 in order to generate clusters with 10 or 20 MeCN molecules.
   - ```/path-to-crest/crest KMeCN6_fromXRD.xyz -qcg acetonitrile.xyz -nsolv n --gfnff --chrg 2 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile --ensemble --mdtime 50 > output```
   - ```/path-to-crest/crest NaMeCN6_fromXRD.xyz -qcg acetonitrile.xyz -nsolv n --gfnff --chrg 2 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile --ensemble --mdtime 50 > output```

3) The lowest energy clusters found in *crest_best.xyz* from each qcg run are used as input for NCI conformational sampling. Four different settings are screened during this sampling step. After the run, a file called *crest_conformers.xyz* is created.
   - ```/path-to-crest/crest crest_best.xyz --gfnff --chrg c --nci --noreftopo --alpb acetonitrile > output```
   - ```/path-to-crest/crest crest_best.xyz --gfnff --chrg c --nci --notopo --noreftopo --alpb acetonitrile > output```
   - ```/path-to-crest/crest crest_best.xyz --gfnff --chrg c --nci --noreftopo --mdlen x3 --alpb acetonitrile > output```
   - ```/path-to-crest/crest crest_best.xyz --gfnff --chrg c --nci --notopo --noreftopo --mdlen x3 --alpb acetonitrile > output```
  
4) The conformers reported in the *crest_conformers.xyz* files during the qcg run are extracted and placed in separate folders (*GFN2_i*) using the python script *getxyz.py*. GFN2-xTB calculations are performed on each extracted conformer by submitting the *sbatch.xtb* script using job-arrays to the SLURM scheduler. Then, the Gibbs free energies are extracted and reported in a log-file (*M_ensemble_GFN2_energies.log*) by submitting the *extractenergies.sh* file to the SLURM scheduler. Additionally, the ID-number i and Gibbs free energy of the lowest conformer is reported.

   This whole process is automated by running the *submit_job.sh* script, whose messages are directed to the log-file *M_ensemble_GFN2.log*.:
   
   ```>> bash submit_job.sh```
   
   The scripts can be found in the folder *Scripts* in this repository, as well as an example of a *M_ensemble_GFN2_energies.log* file.

7) DFT SPE energy calculations are performed on the lowest energy conformers found in step 4 for each metal and setting.  The settings are analogous to those used for cages:
   
   ORCA.in:
   ```
   ! r2SCAN-3c ENERGY TightSCF defgrid3 def2/J
   %maxcore 8000
   %PAL NPROCS 10 END
   %CPCM SMD TRUE
          SMDSOLVENT "MeCN"
   END
   *xyzfile c 1  xtbopt.xyz
   ```

The lowest energy conformers (all settings combined) at the GFN2-xTB level for each metal are shown in the GFN2_lowest_clusters in this github repository. The lowest energy conformer at the r2SCAN-3c//GFN2-xTB level for each metal (all settings combined) are shown in the folder DFT_lowest_clusters.
