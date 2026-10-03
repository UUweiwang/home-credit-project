import numpy as np

from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.model_selection import cross_val_score


def add_engineered_features(df):
    """
    Create additional modeling features.
    """
    df = df.copy()

    df["CREDIT_INCOME_RATIO"] = (
        df["AMT_CREDIT"] / df["AMT_INCOME_TOTAL"]
    )

    df["ANNUITY_INCOME_RATIO"] = (
        df["AMT_ANNUITY"] / df["AMT_INCOME_TOTAL"]
    )

    df["CREDIT_TERM_RATIO"] = (
        df["AMT_ANNUITY"] / df["AMT_CREDIT"]
    )

    df["EMPLOYED_BIRTH_RATIO"] = (
        df["DAYS_EMPLOYED"] / df["DAYS_BIRTH"]
    )

    df = df.replace([np.inf, -np.inf], np.nan)

    return df


def build_preprocessor(X):
    """
    Build preprocessing steps for numeric and categorical predictors.
    """
    numeric_features = X.select_dtypes(
        include=np.number
    ).columns.tolist()

    categorical_features = [
        col for col in X.columns
        if col not in numeric_features
    ]

    numeric_pipeline = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler())
        ]
    )

    categorical_pipeline = Pipeline(
        steps=[
            (
                "imputer",
                SimpleImputer(strategy="most_frequent")
            ),
            (
                "onehot",
                OneHotEncoder(handle_unknown="ignore")
            )
        ]
    )

    preprocessor = ColumnTransformer(
        transformers=[
            (
                "numeric",
                numeric_pipeline,
                numeric_features
            ),
            (
                "categorical",
                categorical_pipeline,
                categorical_features
            )
        ]
    )

    return preprocessor


def evaluate_model(model, preprocessor, X, y, cv):
    """
    Evaluate a model using cross-validation and ROC AUC.
    """
    pipeline = Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("model", model)
        ]
    )

    scores = cross_val_score(
        pipeline,
        X,
        y,
        cv=cv,
        scoring="roc_auc",
        n_jobs=1
    )

    return scores