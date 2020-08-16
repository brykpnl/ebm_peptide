library(EBMPeptide)
set.seed(1)

#Path to .csv file containing peptide-level intensity data
dir <- system.file(package="EBMPeptide")
data_path <- file.path(dir, "testdata/CPTAC_peptides.csv")

#Group data for peptide-level intensity data by sample (column)
groups <- factor(c("A", "A", "A", "B", "B", "B", "C", "C", "C"))

#Contrasts for group comparison. Note that this implementation only performs two-sample comparisons.
comparisons=c("B-A",
              "C-B",
              "C-A")

#Analyze for differentially abundant proteins using eBayes + EBM
analysis <- ebm_analysis(data_path, groups, comparisons, min_obs=3, log2_transform=TRUE)

#p-value data.frames are now stored in analysis@Pvalues[['B-A']], analysis@Pvalues[['C-B']], and analysis@Pvalues[['C-A']]
pvals_CA <- analysis@Pvalues[["C-A"]]
head(pvals_CA[order(pvals_CA$p_right),], 10)
