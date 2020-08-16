\name{ebm_analysis}
\alias{ebm_analysis}
\title{Perform eBayes + EBM analysis on peptide level LC-MS proteomics data for differential abundance detection}
\description{Perform eBayes + EBM on peptide level data by:

1. Filtering peptides based on a minimum number of observations in atleast one of two comparative groups.

2. Log2 transforming peptide intensities (optional) and imputing missing data.

3. Statistically testing peptide intensities across desired group contrasts with eBayes.

4. Splitting eBayes models into right and left-tailed P-values.

5. Grouping peptides by protein identifier and combining right tailed P-values and left tailed P-values separately with EBM to obtain protein level P-values.



Returns an S4 object with a "Pvalues" slot, which contains a list of dataframes containing protein level P-values for each comparison.
}
\usage{ebm_analysis(data_path, groups, comparisons, min_obs = 3, log2_transform = TRUE)}
\arguments{
  \item{data_path}{Path to peptide intensity data (see example format in EBMPeptide/inst/testdata)}
  \item{groups}{Sample replicate groups (see example format in EBMPeptide/inst/examples or Examples section of this documentation )}
  \item{comparisons}{Desired group comparisons}
  \item{min_obs}{Minimum number of observations for a peptide to be present}
  \item{log2_transform}{Set to TRUE to log2 transform peptide intensities, FALSE for using intensities as provided}
}
\value{Returns an S4 object with slots for data and results. See Pvalues slot for P-values resulting from each comparison}
\examples{
library(EBMPeptide)
set.seed(1)

#Path to .csv file containing peptide-level intensity data
data_path <- "./inst/testdata/GST_peptides.csv"

#Group data for peptide-level intensity data by sample (column)
groups <- factor(c("noUV", "noUV", "noUV", "UV", "UV", "UV"))

#Contrasts for group comparison. Note that this implementation only performs two-sample comparisons.
comparisons=c("UV-noUV")

#Analyze for differentially abundant proteins using eBayes + EBM
analysis <- ebm_analysis(data_path, groups, comparisons, min_obs=3, log2_transform=TRUE)

#p-value data.frames are now stored in analysis@Pvalues[['noUV-UV']]
pvals_UV <- analysis@Pvalues[["UV-noUV"]]
head(pvals_UV[order(pvals_UV$p_right),], 10)
}
