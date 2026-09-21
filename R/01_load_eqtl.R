# 01_load_eqtl.R
# Load GTEx eQTL data anexists("gtex_eqtl")d select the tissue-gene pair of interest

library(MRInstruments)
library(dplyr)

# Load GTEx eQTL dataset
data(gtex_eqtl)

# Inspect the dataset
dim(gtex_eqtl)
head(gtex_eqtl)
str(gtex_eqtl)

# Define the tissue and gene of interest
tissue_of_interest <- "Adipose Subcutaneous"
gene_of_interest <- "DHRS4-AS1"

# Select eQTL associations for the tissue-gene pair
eqtl_dat <- gtex_eqtl %>%
  filter(
    tissue == tissue_of_interest,
    gene_name == gene_of_interest
  )

# Inspect the selected data
eqtl_dat
nrow(eqtl_dat)