# 02_extract_gwas.R
# Extract GWAS associations for SNPs selected from the eQTL data

library(TwoSampleMR)

# Automatically obtain SNPs from the eQTL dataset
snps <- eqtl_dat$SNP

# Extract GWAS outcome associations
chd_out_dat <- extract_outcome_data(
  snps = snps,
  outcomes = "ieu-a-7",
  proxies = FALSE
)

# Inspect the extracted outcome data
chd_out_dat