library(tidyverse)
# Load training and test data
train <- read_csv("application_train-1.csv")
test  <- read_csv("application_test.csv")
# ------------------------------------------------------------
# Feature 1: Applicant Age
# EDA decision:
# DAYS_BIRTH is recorded as a negative number of days.
# In the EDA, AGE_YEARS was easier to interpret, and younger
# applicants tended to have a higher repayment difficulty rate.
# Therefore, convert DAYS_BIRTH into age in years.
# ------------------------------------------------------------

add_age_feature <- function(data) {
  
  data %>%
    mutate(
      AGE_YEARS = -DAYS_BIRTH / 365.25
    )
}
train <- add_age_feature(train)
test  <- add_age_feature(test)



# Check the transformation


# ------------------------------------------------------------
# Feature 2: Employment Duration
# DAYS_EMPLOYED is recorded as days before the application date.
# The value 365243 is an unrealistic special value, so it is
# treated as missing before converting employment duration to years.
# ------------------------------------------------------------

add_employment_feature <- function(data) {

  data %>%
    mutate(
      EMPLOYMENT_YEARS = if_else(
        DAYS_EMPLOYED == 365243,
        NA_real_,
        -DAYS_EMPLOYED / 365.25
      )
    )
}
train <- add_employment_feature(train)
test  <- add_employment_feature(test)


# ------------------------------------------------------------
# Feature 3: Credit-to-Income Ratio
# EDA decision:
# The EDA examined credit amount relative to applicant income.
# Although the ratio showed only a small difference between
# TARGET groups, it may still provide useful information when
# combined with other predictors.
# ------------------------------------------------------------

add_financial_features <- function(data) {

  data %>%
    mutate(
      CREDIT_INCOME_RATIO = if_else(
        AMT_INCOME_TOTAL > 0,
        AMT_CREDIT / AMT_INCOME_TOTAL,
        NA_real_
      )
    )
}

train <- add_financial_features(train)
test  <- add_financial_features(test)


# ------------------------------------------------------------
# Feature 4: Missing-Value Indicators
# EDA decision:
# The EDA showed that missingness in several variables differed
# between TARGET groups. Therefore, identify the five variables
# with the largest missing-rate differences using training data,
# and create missing-value indicators for both train and test.
# ------------------------------------------------------------

missing_by_target <- train %>%
  group_by(TARGET) %>%
  summarise(
    across(everything(), ~ mean(is.na(.)))
  ) %>%
  pivot_longer(
    cols = -TARGET,
    names_to = "variable",
    values_to = "missing_rate"
  ) %>%
  pivot_wider(
    names_from = TARGET,
    values_from = missing_rate,
    names_prefix = "TARGET_"
  ) %>%
  mutate(
    difference = abs(TARGET_1 - TARGET_0)
  ) %>%
  arrange(desc(difference))

print(
  missing_by_target %>%
    select(variable, TARGET_0, TARGET_1, difference) %>%
    head(10)
)

missing_indicator_vars <- missing_by_target %>%
  filter(!variable %in% c(
    "TARGET",
    "AGE_YEARS",
    "EMPLOYMENT_YEARS",
    "CREDIT_INCOME_RATIO"
  )) %>%
  slice_head(n = 5) %>%
  pull(variable)

print(missing_indicator_vars)

add_missing_indicators <- function(data, variables) {

  for (var in variables) {

    new_name <- paste0(var, "_MISSING")

    data[[new_name]] <- if_else(
      is.na(data[[var]]),
      1L,
      0L
    )
  }

  data
}
train <- add_missing_indicators(train, missing_indicator_vars)
test  <- add_missing_indicators(test, missing_indicator_vars)

# ------------------------------------------------------------
# Feature 5: Log-transformed Income
# EDA decision:
# AMT_INCOME_TOTAL contains extreme high-value outliers.
# A log transformation reduces the influence of very large values
# while preserving the ordering of applicant income.
# The original income variable is retained.
# ------------------------------------------------------------

add_income_feature <- function(data) {

  data %>%
    mutate(
      LOG_INCOME = log1p(AMT_INCOME_TOTAL)
    )
}
train <- add_income_feature(train)
test  <- add_income_feature(test)

# ------------------------------------------------------------
# Feature 6: Age Groups
# EDA decision:
# Age showed a relationship with repayment difficulty.
# Quartile thresholds are learned from training data only
# and reused unchanged for the test data.
# ------------------------------------------------------------

age_quantiles <- quantile(
  train$AGE_YEARS,
  probs = c(0.25, 0.50, 0.75),
  na.rm = TRUE
)

age_breaks <- c(
  -Inf,
  age_quantiles,
  Inf
)


print(age_breaks)

add_age_bins <- function(data, breaks) {

  data %>%
    mutate(
      AGE_GROUP = cut(
        AGE_YEARS,
        breaks = breaks,
        include.lowest = TRUE,
        labels = c(
          "Young",
          "Lower_Middle",
          "Upper_Middle",
          "Older"
        )
      )
    )
}

train <- add_age_bins(train, age_breaks)
test  <- add_age_bins(test, age_breaks)



# ------------------------------------------------------------
# Train/Test Consistency Checks
# Verify that train and test contain the same feature columns
# except for TARGET, which exists only in the training data.
# ------------------------------------------------------------

train_feature_names <- setdiff(names(train), "TARGET")
test_feature_names  <- names(test)

same_feature_columns <- identical(
  train_feature_names,
  test_feature_names
)

print(paste(
  "Train/test feature columns identical:",
  same_feature_columns
))

only_in_train <- setdiff(train_feature_names, test_feature_names)
only_in_test  <- setdiff(test_feature_names, train_feature_names)

print("Columns only in train:")
print(only_in_train)

print("Columns only in test:")
print(only_in_test)

train_duplicate_ids <- train %>%
  count(SK_ID_CURR) %>%
  filter(n > 1) %>%
  nrow()

test_duplicate_ids <- test %>%
  count(SK_ID_CURR) %>%
  filter(n > 1) %>%
  nrow()

print(paste("Train duplicate SK_ID_CURR:", train_duplicate_ids))
print(paste("Test duplicate SK_ID_CURR:", test_duplicate_ids))

print(dim(train))
print(dim(test))


write_csv(train, "application_train_prepared.csv")
write_csv(test, "application_test_prepared.csv")
