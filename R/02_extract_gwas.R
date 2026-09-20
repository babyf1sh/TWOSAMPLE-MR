# 02_extract_gwas.R
# Extract coronary heart disease GWAS associations for selected SNPs

library(TwoSampleMR)

# SNP instruments selected from the GTEx eQTL dataset
snps <- c(
  "rs10151793",
  "rs59434518"
)

# Extract GWAS outcome associations
# Outcome ID: ieu-a-7
# Outcome: Coronary heart disease

chd_out_dat <- extract_outcome_data(
  snps = snps,
  outcomes = "ieu-a-7",
  proxies = FALSE
)

# Inspect the extracted outcome data
chd_out_dat