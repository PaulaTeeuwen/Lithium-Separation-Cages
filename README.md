# Lithium-Separation-Cages
This repository contains the scripts and xyz-files relevant for studying the Li-separation ability of coordination cages in acetonitrile.


## Cages
1) MM3 modelling in Scigress of the protonated cages
2) GFN2-xTB optimization of the MM3-cages in step 1 using ORCA (CSD3 cluster)

   ORCA.inp:
   ```
   ! XTB2 OPT NUMFREQ
   %PAL NPROCS 8 END
   %maxcore 2658

   ! ALPB(Acetonitrile)

   *xyzfile 0 1 trencage_input.xyz
   ```

3) GFN2-xTB optimization of the cages from step 2 using xtb

   ```
   xtb structure.xyz --ohess vtight --alpb acetonitrile --chrg ... > output
   ```

4) r2SCAN-3c single point energy (SPE) calculation using ORCA

## Clusters

