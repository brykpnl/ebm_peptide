#Perform eBayes + EBM on peptide level data by:
# 1. Filtering peptides based on a minimum number of observations in atleast one of two comparative groups.
# 2. Log2 transforming peptide intensities (optional) and imputing missing data.
# 3. Statistically testing peptide intensities across desired group contrasts with eBayes.
# 4. Splitting eBayes models into right and left-tailed P-values.
# 5. Grouping peptides by protein identifier and combining right tailed P-values and left tailed P-values separately with EBM to obtain protein level P-values.
#
# TO USE: Run the "ebm_analysis" function on your data (see ./inst/examples for example analyses on example data located in ./inst/testdata).
# NOTE: right and left tailed protein level P-values can be found in the Pvalues slot of the returned S4 object.
# NOTE: set log2_transform to "FALSE" and min_obs=0 if you have already completely pre-processed your data.

#Class for storing all proteomics data and analysis results.
setClass("proteomics", slots=list(Protein="character",
                                  Peptide="character",
                                  Intensities="matrix",
                                  Design="matrix",
                                  Contrasts="matrix",
                                  Pvalues="list",
                                  GroupData="list"))

#Input: peptide intensities, optional log2_transform as TRUE or FALSE.
#Output: missing-value imputed peptide intensities optionally log2 transformed.
prepare <- function(intensities, log2_transform) {
  if (log2_transform==TRUE) {
    imputed <- imputeLCMD::impute.MinProb(log2(intensities));
  }
  else {
    imputed <- imputeLCMD::impute.MinProb(intensities);
  }
  return(imputed)
}

#Input: eBayes model fit for peptides.
#Output: Right and left-tailed P-values for each peptide group comparison.
# NOTE: Right or left tailed P-values are needed for EBM as we can only combine right or left tailed P-values together.
split_pvals = function (fit) {
  se.coef <- sqrt(fit$s2.post) * fit$stdev.unscaled
  df.total <- fit$df.prior + fit$df.residual
  left <- pt(fit$t, df=df.total, lower.tail=TRUE)
  right <- pt(fit$t, df=df.total, lower.tail=FALSE)
  df <- cbind.data.frame(right, left)
  colnames(df) <- c("p_right", "p_left")
  return(df)
}

#Input: dataframe containing peptide level P-values for a particular protein.
#Output: dataframe containing right and left protein level P-values.
# NOTE: Called in p_combine function.
ebm <- function(df) {
  positive <- EmpiricalBrownsMethod::empiricalBrownsMethod(data_matrix=df[, 5:length(df)], p_values=df$p_right)
  negative <- EmpiricalBrownsMethod::empiricalBrownsMethod(data_matrix=df[, 5:length(df)], p_values=df$p_left)
  results_df <- data.frame(positive, negative)
  return(results_df)
}

#Input: EBM P-values for peptides, protein and peptide identifiers, and data used for EBM combination.
#Output: Combined protein level P-values.
# NOTE: Called in compare_peptides function.
p_combine <- function(p_right, p_left, proteins, peptides, data.matrix) {
  full <- cbind.data.frame(proteins, peptides, p_right, p_left, data.matrix)
  colnames(full)[1:4] <- c("protein", "peptide", "p_right", "p_left")
  grouped <- split(full, full["protein"], drop=TRUE)
  EB <- lapply(grouped, ebm)
  EB_df <- data.frame(dplyr::bind_rows(EB, .id="protein"), row.names="protein")
  return(EB_df)
}

#Input: Group comparison data, design matrix, contrast matrix, and protein/peptide identifiers.
#Output: Combined protein level P-values.
# NOTE: Wraps together eBayes peptide level tests and EBM combination.
compare_peptides <- function(A_data, B_data, design_matrix, contrast_matrix, proteins, peptides) {

  peptide_fc <- rowMeans(A_data) - rowMeans(B_data)
  protein_fc <- aggregate(peptide_fc, list(proteins), mean, na.action = na.omit)
  n_peptides <- plyr::count(proteins)

  #print(protein_fc)
  #print(n_peptides)
  #print(colnames(protein_fc))


  data.matrix <- cbind(A_data, B_data)
  ebayes_fit <- limma::eBayes(limma::contrasts.fit(fit=limma::lmFit(data.matrix, design=design_matrix), contrast=contrast_matrix))
  ebayes_p <- split_pvals(ebayes_fit)
  ebayes_combined <- p_combine(ebayes_p$p_right, ebayes_p$p_left, proteins, peptides, data.matrix)
  ebayes_combined$fc <- protein_fc[, 2]
  ebayes_combined$n_peptides <- n_peptides[, 2]
  colnames(ebayes_combined) <- c("p_right",
                                 "p_left",
                                 "fc",
                                 "n_peptides")
  return(ebayes_combined)
}

#Input: path to peptide level data, group sample names, and desired comparisons.
# NOTE: Hierarichal experimental designs aren't implemented.
# NOTE: min_obs refers to the required minimun number of observations in either comparative group for a peptide to be considered for analysis.
#Output: proteomics S4 object containing all input data and P-value results for EBM combination.
# NOTE: P-values can be found for each comparison in the Pvalues slot.
ebm_analysis <- function(data_path, groups, comparisons, min_obs=3, log2_transform=TRUE, sep=",") {
  set.seed(1)
  design_matrix <- model.matrix(~0 + groups)
  colnames(design_matrix) <- levels(groups)
  contrast_matrix <- limma::makeContrasts(contrasts=comparisons, levels=design_matrix)
  raw_data <- read.delim(data_path, header=TRUE, sep=sep)
  raw_data[raw_data==0] <- NA
  data <- new("proteomics",
              Protein=as.character(raw_data$Protein),
              Peptide=as.character(raw_data$Sequence),
              Intensities=as.matrix(subset(raw_data, select=-c(Protein, Sequence))),
              Design=design_matrix,
              Contrasts=contrast_matrix)
  for (sample in colnames(data@Design)) {
    select_samples  <- data@Design[, sample]
    data@GroupData[[sample]][["Raw Data"]] <- data@Intensities[, which(select_samples==1)]
  }
  for (sample_contrast in colnames(data@Contrasts)) {
    print(sample_contrast)
    tryCatch(
      expr = {
        A_group <- names(which(data@Contrasts[,sample_contrast] == 1) == TRUE)
        A_passing <- row.names(data@GroupData[[A_group]][["Raw Data"]][rowSums(!is.na(data@GroupData[[A_group]][["Raw Data"]])) >= min_obs, ])
        B_group <- names(which(data@Contrasts[,sample_contrast] == -1) == TRUE)
        B_passing <- row.names(data@GroupData[[B_group]][["Raw Data"]][rowSums(!is.na(data@GroupData[[B_group]][["Raw Data"]])) >= min_obs, ])
        all_passing <- unique(c(A_passing, B_passing))
        outlog <- capture.output({
          A_data <- prepare(data@GroupData[[A_group]][["Raw Data"]][all_passing, ], log2_transform)
          B_data <- prepare(data@GroupData[[B_group]][["Raw Data"]][all_passing, ], log2_transform)
        })
        proteins <- data@Protein[as.numeric(all_passing)]
        peptides <- data@Peptide[as.numeric(all_passing)]
        ab_groups <- factor(c(rep(A_group, times=dim(A_data)[2]),
                              rep(B_group, times=dim(B_data)[2])))
        ab_design_matrix <- model.matrix(~0 + ab_groups)
        colnames(ab_design_matrix) <- levels(ab_groups)
        contrast_cmd <- paste("limma::makeContrasts(", sample_contrast, ", levels = ab_design_matrix)", sep = '"')
        ab_contrast_matrix <- eval(parse(text = contrast_cmd))
        data@Pvalues[[sample_contrast]] <- compare_peptides(A_data,
                                                            B_data,
                                                            ab_design_matrix,
                                                            ab_contrast_matrix,
                                                            proteins,
                                                            peptides)
    },
      error = function(e) {
        print(e)
      }
    )
  }
  return(data)
}

