# Home Credit Default Risk Project

## Author
Wei Wang

## Project Description

This project analyzes the Home Credit Default Risk dataset to better understand applicant characteristics associated with repayment difficulty and to prepare the data for predictive modeling.

The exploratory data analysis (EDA) identified important data quality issues and relationships with the target variable. The data preparation script translates those findings into reusable cleaning and feature-engineering steps that are applied consistently to both the training and test datasets.

## Data Preparation Script

The `data_preparation.R` script performs the following transformations:

### 1. Applicant Age

`DAYS_BIRTH` is stored as a negative number of days before the loan application date. The script converts it into a more interpretable variable:

`AGE_YEARS`

This transformation was based on the EDA finding that applicants with repayment difficulties tended to be younger.

### 2. Employment Duration

`DAYS_EMPLOYED` is converted from days into years.

The value `365243` was identified as an unrealistic special value rather than a valid employment duration. These observations are treated as missing before creating:

`EMPLOYMENT_YEARS`

### 3. Credit-to-Income Ratio

The script creates:

`CREDIT_INCOME_RATIO = AMT_CREDIT / AMT_INCOME_TOTAL`

The EDA showed that this ratio had only a small difference between TARGET groups, but it was retained because it may still provide useful information when combined with other predictors.

### 4. Missing-Value Indicators

The EDA showed that missingness in several housing-related variables differed between applicants with and without repayment difficulty.

Using the training data, the script identifies the five variables with the largest differences in missing rates between TARGET groups and creates binary missing-value indicators for them.

The selected variables were:

- `EMERGENCYSTATE_MODE`
- `TOTALAREA_MODE`
- `ENTRANCES_AVG`
- `ENTRANCES_MODE`
- `ENTRANCES_MEDI`

A value of 1 indicates that the original value is missing, while 0 indicates that it is present.

The variables are selected using the training data only, and the same missing indicators are then created in the test data.

### 5. Log-Transformed Income

The EDA identified extreme high-income values in `AMT_INCOME_TOTAL`.

The script creates:

`LOG_INCOME = log(1 + AMT_INCOME_TOTAL)`

This reduces the influence of extremely large income values while retaining the original income variable.

### 6. Age Groups

Because age showed a relationship with repayment difficulty in the EDA, the script also creates an age-group feature.

The age thresholds are calculated from the training data only using the 25th, 50th, and 75th percentiles:

- 25th percentile: approximately 33.98 years
- 50th percentile: approximately 43.12 years
- 75th percentile: approximately 53.89 years

These same thresholds are reused when processing the test dataset.

The resulting categories are:

- Young
- Lower_Middle
- Upper_Middle
- Older

## Train/Test Consistency

All preprocessing rules that require information from the data are learned from the training dataset and then reused on the test dataset.

This prevents information from the test data from influencing preprocessing decisions.

Final validation checks showed:

- Training and test feature columns are identical after excluding `TARGET`: `TRUE`
- Columns appearing only in training after excluding `TARGET`: none
- Columns appearing only in test: none
- Duplicate `SK_ID_CURR` values in training data: 0
- Duplicate `SK_ID_CURR` values in test data: 0

Final prepared data dimensions:

- Training data: 307,511 rows × 132 columns
- Test data: 48,744 rows × 131 columns

The one-column difference occurs because `TARGET` is available only in the training dataset.

## EDA Decisions Not Implemented

The EDA also examined education level, income type, housing type, credit amount, and class imbalance.

These variables were not given additional transformations in this script because they can remain as original predictors for later modeling.

Supplementary tables were not joined because they were not part of the EDA used for this stage of the project.

Class imbalance is also not modified during data preparation because it will be addressed during model training and evaluation rather than by changing the original target distribution at this stage.

## Input Files

The script uses:

- `application_train-1.csv`
- `application_test.csv`

The data files are stored locally and are excluded from GitHub using `.gitignore`.

## Output Files

Running the script creates:

- `application_train_prepared.csv`
- `application_test_prepared.csv`

These generated data files are also excluded from GitHub using `.gitignore`.

## How to Run

The project requires R and the `tidyverse` package.

From the project directory, run:

```r
source("data_preparation.R")
```

The script will:

1. Load the training and test datasets.
2. Create the engineered features.
3. Learn required preprocessing parameters from the training data.
4. Apply the same transformations to the test data.
5. Check train/test consistency.
6. Check for duplicate applicant IDs.
7. Write the prepared datasets to CSV files.

## Project Files

- `Home_Credit_Default_Risk_EDA.qmd` — exploratory data analysis
- `data_preparation.R` — reusable data preparation and feature-engineering script
- `README.md` — project documentation
- `.gitignore` — prevents raw and generated data files from being committed to GitHub