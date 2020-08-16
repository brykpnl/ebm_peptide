# ebm_peptide

Detect differentially abundant proteins by combining peptide level intensity data with Empirical Browns Method (EBM).

Install the package in R:
```
install_github("brykpnl/ebm_peptide", subdir="EBMPeptide")
```

Load into R:
```
library(EBMPeptide)
```

See example data and analysis scripts in the inst/testdata and inst/examples folders.

See more help by writing ```?ebm_analysis``` from your R command prompt.

For more information about EBM, see Poole's paper on combining dependent P-values at https://academic.oup.com/bioinformatics/article/32/17/i430/2450768 and their EBM implementation in R, Matlab, and Python at https://github.com/IlyaLab/CombiningDependentPvaluesUsingEBM.
