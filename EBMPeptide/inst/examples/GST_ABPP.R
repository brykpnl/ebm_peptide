library(EBMPeptide)
set.seed(1)

#Path to .csv file containing peptide-level intensity data
dir <- system.file(package="EBMPeptide")
data_path <- file.path(dir, "testdata/GST_peptides.csv")

#Group data for peptide-level intensity data by sample (column)
groups <- factor(c("noUV", "noUV", "noUV", "UV", "UV", "UV"))

#Contrasts for group comparison. Note that this implementation only performs two-sample comparisons.
comparisons=c("UV-noUV")

#Analyze for differentially abundant proteins using eBayes + EBM
analysis <- ebm_analysis(data_path, groups, comparisons, min_obs=3, log2_transform=TRUE)

#p-value data.frames are now stored in analysis@Pvalues[['noUV-UV']]
pvals_UV <- analysis@Pvalues[["UV-noUV"]]
head(pvals_UV[order(pvals_UV$p_right),], 10)
