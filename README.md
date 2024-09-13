# Lithium-Separation-Cages
This repository contains the scripts and xyz-files relevant for studying the Li-separation ability of coordination cages in acetonitrile.


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
1) Use Quantum Cluster Growth (QCG) algorithm in CREST to build solvent shells of n = 10 or n = 20 MeCN molecules around a metal ion (M = Li, Na, K, Ca, Mg). Charge c is 1 for Li, Na and K and 2 for Ca and Mg. The K(n=10) cluster is made in three qcg steps. Two additional QCG runs are performed starting from 〖[K@(MeCN)_6]〗^(1+) and 〖[Ca@(MeCN)_6]〗^(2+) found in the Cambridge Structural Database (CSD).

   ```
   /path-to-crest/crest M.xyz -qcg acetonitrile.xyz -nsolv n --gfnff --chrg 2 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile --ensemble --mdtime 50 > output

   ```
   Pure solvent clusters are made via the -gsolv keyword for the Na-cluster generation:
   ```
   /sharedscratch/pp555/bin/crest Na.xyz -qcg acetonitrile.xyz -nsolv 10 --gfnff --chrg 1 -T $SLURM_CPUS_PER_TASK --alpb acetonitrile **--gsolv** --mdtime 50 --freqlvl gfnff > output 
   ```

2) The lowest energy clusters found in crest_best.xyz is used as input for NCI conformational sampling.
   
