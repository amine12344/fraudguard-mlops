# FraudGuard DVC Lineage Report

## Purpose

This report documents the reproducible DVC pipeline for FraudGuard.

## Project Parameters

```yaml
data:
  synthetic_rows: 5000
  synthetic_seed: 42
quality_gate:
  min_pr_auc: 0.03
  min_roc_auc: 0.7
train:
  learning_rate: 0.04
  min_recall: 0.7
  n_estimators: 350
  random_state: 42
  test_size: 0.2

```

## Model Metrics

```json
{
  "threshold": 0.8474623369832645,
  "roc_auc": 0.9978978534418949,
  "pr_auc": 0.9286497260297968,
  "precision": 0.8974358974358975,
  "recall": 1.0,
  "f1": 0.9459459459459459,
  "model_type": "LightGBM",
  "train_rows": 4000,
  "test_rows": 1000,
  "positive_rate": 0.035
}
```

## Pipeline DAG

```text
+----------------+                        
                        | data_synthetic |                        
                        +----------------+**                      
                   *****          *         ****                  
                ***                *            ****              
             ***                   *                ***           
+---------------+         +----------------+         +-------+    
| data_validate |         | features_build |         | train |    
+---------------+         +----------------+         +-------+    
                                                          *       
                                                          *       
                                                          *       
                                                  +-------------+ 
                                                  | model_check | 
                                                  +-------------+
```

## DVC Status

```text
Data and pipelines are up to date.
```
