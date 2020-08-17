# ebm_peptide

Detect differentially abundant proteins from bottom-up LC-MS proteomics data by combining peptide level P-values with Empirical Browns Method (EBM).

This implementation is written in R and performs clean up of raw peptide intensities, detects differentially abundant peptides with eBayes, and combines peptide level P-values with EBM to obtain protein level P-values.

To use for your own analysis to detect differentially abundant proteins in R, first ensure that you have the "devtools" package installed and loaded:
```
install.packages("devtools")
library(devtools)
```

Then install the EBMPeptide package and load it into R:
```
install_github("brykpnl/ebm_peptide", subdir="EBMPeptide")
library(EBMPeptide)
```

You can see example data and analysis scripts in the EBMPeptide/inst/testdata and EBM/inst/examples folders.

See more help for running your own analysis by entering ```?ebm_analysis``` into your R command prompt.

For more information about EBM, see Poole's paper on combining dependent P-values at https://academic.oup.com/bioinformatics/article/32/17/i430/2450768 and their EBM implementation in R, Matlab, and Python at https://github.com/IlyaLab/CombiningDependentPvaluesUsingEBM.
