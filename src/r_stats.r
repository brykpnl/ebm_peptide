library(oompaBase)
library(ClassComparison)
library(base)
library(stats)
library(DescTools)
library(Biobase)
library(vsn)

vsn_normalize <- function(peptides) {
  peptides = as.matrix(peptides)
  peptides[is.nan(peptides)] = NA
  peptide_vsn = justvsn(ExpressionSet(peptides))
  return(peptide_vsn@assayData[["exprs"]])
}
