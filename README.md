# ebm_peptide

Detect differentially abundant proteins by combining peptide level intensity data with Empirical Browns Method (EBM).

Ensure that you have the "devtools" package installed:
```
install.packages("devtools")
library(devtools)
```

Install the EBMPeptide package and load into R:
```
install_github("brykpnl/ebm_peptide", subdir="EBMPeptide")
library(EBMPeptide)
```

See example data and analysis scripts in the EBMPeptide/inst/testdata and EBM/inst/examples folders.

See more help by entering ```?ebm_analysis``` into your R command prompt.

For more information about EBM, see Poole's paper on combining dependent P-values at https://academic.oup.com/bioinformatics/article/32/17/i430/2450768 and their EBM implementation in R, Matlab, and Python at https://github.com/IlyaLab/CombiningDependentPvaluesUsingEBM.
