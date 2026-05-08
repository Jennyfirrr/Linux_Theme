---
name: ml-audit
description: Audit the ML pipeline for train-serve drift and format consistency.
---

# /ml-audit — Machine Learning Pipeline Audit

Detect silent bugs in the ML pipeline by auditing features, labels, and serialization formats.

## Scans
1.  **Feature Drift**: Verify that field changes in model features are symmetrically updated in both training and inference paths.
2.  **Label Drift**: Check if label computation logic has changed, requiring model retraining.
3.  **Metric Drift**: Ensure that metrics (e.g., accuracy) are computed using the same formula across the entire pipeline.
4.  **Format Drift**: Verify that serialization versions (stamps, snapshots, models) are bumped when data shapes change.
5.  **Path Drift**: Ensure that metadata lookup logic (e.g., `.stamp` files) handles versioning or symlinks correctly.
6.  **Threshold Drift**: Check for hardcoded threshold values that should be synchronized via central configuration.
7.  **Data-Source Parity**: Verify that training data (e.g., CSV) and inference data (e.g., WebSocket) have identical shapes and precision.

## Output
A report listing findings as [PASS], [DRIFT-SAFE], [DRIFT-RISK], or [DRIFT-BUG]. Provide a concrete fix proposal for any risk or bug.
