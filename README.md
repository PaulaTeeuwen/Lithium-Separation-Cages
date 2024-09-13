# Lithium-Separation-Cages
This repository contains the scripts and xyz-files relevant for studying the Li-separation ability of coordination cages in acetonitrile.


## Cages
1) MM3 modelling in Scigress of the protonated cages
2) GFN2-xTB optimization of the MM3-cages in step 1 using *ORCA* (CSD3 cluster). Charge c is 4, 8 or 12 depending on the cage.

   ORCA.in:
   ```
   ! XTB2 OPT NUMFREQ
   %PAL NPROCS 8 END
   %maxcore 2658

   ! ALPB(Acetonitrile)

   *xyzfile c 1 input.xyz
   ```

3) GFN2-xTB optimization of the cages from step 2 using *xtb* (NEST cluster)

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
   *xyzfile 8 1  xtbopt.xyz
   ```

## Clusters

