# ebm_peptide

Performs pre-processing on peptide-level LC-MS intensity data before performing one-tailed t-tests between samples to obtain peptide-level P-values. These P-values are combined using the empirical Brown's method (EBM) for dependent P-values to obtain protein-level P-values indicative of protein differential abundance. These P-values are then FDR-adjusted using the Benjamini–Yekutieli correction to obtain q-values.

See Poole's paper on combining dependent P-values for more details on EBM at https://academic.oup.com/bioinformatics/article/32/17/i430/2450768 and their EBM implementation in R, Matlab, and Python (cloned here) at https://github.com/IlyaLab/CombiningDependentPvaluesUsingEBM.
