# 03_wald_ratio.R
# Calculate SNP-specific Wald ratios

# SNPs used as instrumental variables
snps <- c(
  "rs10151793",
  "rs59434518"
)

# Exposure associations:
# SNP -> DHRS4-AS1 expression
beta_x <- c(
  -0.956368,
  -0.766910
)

se_x <- c(
  0.0713899,
  0.0807102
)

# Outcome associations:
# SNP -> coronary heart disease
beta_y <- c(
  0.005636,
  0.008426
)

se_y <- c(
  0.0218646,
  0.0217027
)

# Calculate the Wald ratio for each SNP
wald_ratio <- beta_y / beta_x

# Create a summary table
mr_dat <- data.frame(
  SNP = snps,
  beta_x = beta_x,
  se_x = se_x,
  beta_y = beta_y,
  se_y = se_y,
  wald_ratio = wald_ratio
)

# Display the results
mr_dat