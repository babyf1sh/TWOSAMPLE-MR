```r
# 03_wald_ratio.R
# Version 2
# Automatically match eQTL and GWAS data
# and calculate SNP-specific Wald ratios

library(dplyr)
library(TwoSampleMR)

# --------------------------------------------------
# 1. Check input data
# --------------------------------------------------

# eqtl_dat:
# SNP -> gene expression
#
# chd_out_dat:
# SNP -> coronary heart disease

eqtl_dat
chd_out_dat


# --------------------------------------------------
# 2. Find SNPs shared by exposure and outcome data
# --------------------------------------------------

common_snps <- intersect(
  eqtl_dat$SNP,
  chd_out_dat$SNP
)

cat("Number of shared SNPs:", length(common_snps), "\n")

common_snps


# --------------------------------------------------
# 3. Keep only shared SNPs
# --------------------------------------------------

eqtl_matched <- eqtl_dat %>%
  filter(SNP %in% common_snps)

gwas_matched <- chd_out_dat %>%
  filter(SNP %in% common_snps)


# --------------------------------------------------
# 4. Convert eQTL data to TwoSampleMR format
# --------------------------------------------------

exposure_dat <- format_data(
  eqtl_matched,
  type = "exposure",
  snp_col = "SNP",
  beta_col = "beta",
  se_col = "se",
  effect_allele_col = "effect_allele",
  other_allele_col = "other_allele",
  pval_col = "pval"
)


# --------------------------------------------------
# 5. GWAS outcome data
# --------------------------------------------------

outcome_dat <- gwas_matched


# --------------------------------------------------
# 6. Harmonise exposure and outcome data
# --------------------------------------------------

harmonised_dat <- harmonise_data(
  exposure_dat = exposure_dat,
  outcome_dat = outcome_dat,
  action = 2
)


# --------------------------------------------------
# 7. Calculate SNP-specific Wald ratios
# --------------------------------------------------

wald_results <- harmonised_dat %>%
  mutate(
    wald_ratio = beta.outcome / beta.exposure
  ) %>%
  select(
    SNP,
    beta.exposure,
    se.exposure,
    beta.outcome,
    se.outcome,
    wald_ratio
  )


# --------------------------------------------------
# 8. Display results
# --------------------------------------------------

wald_results
