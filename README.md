# Home Credit Default Risk | Credit Risk Analytics Portfolio

**Author:** Wei Wang  
**Project:** Home Credit Default Risk (Kaggle)  
**Focus:** Exploratory Data Analysis · Feature Engineering · Predictive Modeling · Model Explainability · Business Decision Support

## Project Overview: Business Problem and Objective

Lenders must balance two competing goals: extending credit to eligible applicants and managing the losses associated with repayment difficulty. A model that ranks borrowers by risk can support more consistent screening, but predictive accuracy alone does not determine whether a lending strategy is commercially useful.

This project uses the **Home Credit Default Risk** dataset to investigate factors associated with repayment difficulty and develop a transparent credit-risk prediction workflow. My objectives were to:

- Explore borrower characteristics and data-quality challenges.
- Build reproducible preprocessing and feature-engineering workflows.
- Compare and tune classification models using **stratified cross-validation** and **ROC AUC**.
- Translate model probabilities into an illustrative business decision using a threshold and explicit financial assumptions.
- Examine interpretability, fairness, and practical limitations before considering deployment.

## My Solution

**1. Exploratory data analysis (EDA).** I investigated repayment difficulty across applicant attributes such as age, education, income, and housing; checked missing values and unusual codes; and examined class imbalance (approximately **8.1%** of training applicants had repayment difficulty).

**2. Data preparation.** I used an R script to derive interpretable variables including applicant age, employment years, credit-to-income ratio, log income, age groups, and missingness indicators. Rules depending on dataset statistics were learned from the training data and reused for the test data. I also checked consistent feature columns and duplicate applicant IDs.

**3. Predictive modeling.** I compared logistic regression, class-weighted logistic regression, and random forest. The modeling workflow used preprocessing pipelines, including missing-value imputation and categorical encoding, to support consistent model evaluation. I then tuned logistic regression using stratified cross-validation.

**4. Decision support and model review.** I examined predicted probabilities using a business-oriented decision threshold, assessed explanations using SHAP, and discussed subgroup fairness and deployment limitations in a model card. The proposed model is **decision support**, not a fully autonomous lending approval system.

## Results

| Model or evaluation | ROC AUC |
|---|---:|
| Baseline logistic regression — mean CV | 0.7188 |
| Balanced logistic regression — mean CV | 0.7138 |
| Random forest — mean CV | 0.7137 |
| Tuned logistic regression — mean CV | **0.7308** |
| Final Kaggle public leaderboard | **0.73969** |
| Final Kaggle private leaderboard | **0.73645** |

The selected model was **logistic regression** (`C = 0.01`, `class_weight = None`). Its Kaggle AUC scores were reasonably close to the cross-validation result, providing encouraging evidence of performance on the competition's held-out data. These scores do not, by themselves, establish production readiness.

## Business Value

In a lending setting, a predicted probability becomes useful only when it informs a decision rule and the trade-offs of that rule are understood. I evaluated an illustrative **18% risk threshold** instead of relying on a conventional 50% classification cutoff.

Under the project's **simplified financial assumptions**, the 18% threshold yielded approximately **5.7% higher normalized business value** than the 50% threshold on a **10,000-row evaluation sample**. The model card reports an **approval rate of 91.24%** at the selected threshold. These results are **scenario estimates**, not observed lender profits or a validated production policy.

The practical takeaway is that **model quality and business value are different questions**: AUC measures ranking ability, while approval thresholds determine how a model might affect lending decisions and financial outcomes. Any real implementation would need lender-specific returns, losses, operating costs, policy constraints, and additional fairness and compliance review.

## Challenges and How I Addressed Them

- **Imbalanced outcomes:** Repayment difficulty represented only about 8.1% of the training sample. I used stratified cross-validation and ROC AUC for model comparisons, rather than interpreting accuracy alone.
- **Messy and incomplete data:** Some fields were highly missing, income contained extreme values, and `DAYS_EMPLOYED = 365243` was not a plausible employment duration. I incorporated explicit treatment of these issues into reusable data-preparation code.
- **Consistent preprocessing:** Train/test differences and leakage could undermine evaluation. I reused transformations learned from training data and checked output consistency. Modeling preprocessing was built into the workflow.
- **Choosing an actionable threshold:** A high AUC does not specify which applicants should be approved. I made threshold selection a separate analysis with transparent, simplified financial assumptions.
- **Interpretability and fairness:** A prediction score does not automatically explain a decision or ensure equitable outcomes. I documented SHAP-based explanation, subgroup analysis, and risks that would require review before deployment.

## What I Learned

This project strengthened my ability to connect **data exploration, reproducible preprocessing, statistical evaluation, and business decisions**. My most important learning was that model selection should not stop at a leaderboard score: stakeholders also need to understand how the model will be used, what assumptions drive its apparent value, and where human oversight remains necessary.

I also practiced presenting technical findings in a way a nontechnical audience can interrogate: stating the objective, explaining what was tested, reporting comparable metrics, and describing uncertainty and limitations without overstating the results.

## Repository Guide

| File | Purpose |
|---|---|
| `README.md` | Portfolio overview, results, business value, challenges, and lessons |
| `data_preparation.R` | R data-cleaning and feature-engineering script |
| `home_credit_modeling.qmd` | Python-based modeling experiments, model selection, tuning, and Kaggle submission |
| `modeling_utils.py` | Reusable Python modeling utilities |
| `Home Credit Default Risk Model Card.qmd` | Model card source: performance, threshold, explainability, fairness, and limitations |
| `Home_Credit_Default_Risk_Model_Card.html` | Rendered model card (download or view locally; GitHub does not render HTML as a notebook) |
| `.gitignore` | Excludes local raw and generated datasets |

**Individual EDA notebook:** My exploratory work is discussed above. Add and link the individual EDA `.qmd`, `.ipynb`, `.Rmd`, or PDF file here once it is uploaded to this repository. The README should link to work that is actually present rather than to a missing file.

### Reproducing the Work

**Data:** Obtain the Home Credit Default Risk competition data from [Kaggle](https://www.kaggle.com/competitions/home-credit-default-risk). The datasets are not included in this repository. The current R script expects locally stored `application_train-1.csv` and `application_test.csv` in the paths specified by the script; adjust those paths to your environment if needed.

**Data preparation (R):** Install `tidyverse`, place the required datasets where the script expects them, and run:

```r
source("data_preparation.R")
```

The preparation process produces `application_train_prepared.csv` and `application_test_prepared.csv` and performs train/test consistency checks.

**Modeling (Python / Quarto):** Open `home_credit_modeling.qmd` in Positron or another Quarto-capable environment. Install its required packages, including `pandas`, `numpy`, and `scikit-learn`, and run the Python cells in order after preparing the datasets. The workflow generates a Kaggle prediction file, `home_credit_submission.csv`.

The notebooks and scripts contain the implementation details; readers should consult them for the exact environment and execution settings.

## Limitations and Responsible Use

- Results come from the Home Credit competition dataset and may not generalize to other time periods, populations, or loan products.
- The 18% threshold is based on simplified economics and a sample-based illustration, not actual loan-level financial outcomes.
- Credit decisions can have substantial consequences. Model explanations, fairness analysis, regulatory requirements, human review, and ongoing monitoring would be necessary before real-world deployment.

**Detailed technical documentation:** See [Model Card source](Home%20Credit%20Default%20Risk%20Model%20Card.qmd) and [Modeling notebook](home_credit_modeling.qmd).
