# 04_ivw.R
# Version 3.0.0
# Attempt IVW MR analysis and diagnose harmonisation issues

library(TwoSampleMR)

# Check harmonisation status
harmonised_dat[, c(
  "SNP",
  "effect_allele.exposure",
  "other_allele.exposure",
  "effect_allele.outcome",
  "other_allele.outcome",
  "eaf.exposure",
  "eaf.outcome",
  "palindromic",
  "ambiguous",
  "remove",
  "mr_keep"
)]

# Count SNPs available for MR
cat(
  "Number of SNPs available for MR:",
  sum(harmonised_dat$mr_keep, na.rm = TRUE),
  "\n"
)

# Attempt IVW only if eligible SNPs are available
if (sum(harmonised_dat$mr_keep, na.rm = TRUE) > 0) {
  
  ivw_result <- mr(
    harmonised_dat,
    method_list = "mr_ivw"
  )
  
  print(ivw_result)
  
} else {
  
  cat("\n")
  cat("IVW MR was not performed.\n")
  cat("Reason: no SNPs passed harmonisation.\n")
  cat("\n")
  
  cat("Diagnostic information:\n")
  
  print(
    harmonised_dat[, c(
      "SNP",
      "palindromic",
      "ambiguous",
      "remove",
      "mr_keep"
    )]
  )
}