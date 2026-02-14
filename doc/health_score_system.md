# Health Condition Score System

A personalized nutrition scoring system that adapts to individual health conditions.

---

## Core Principle

The same scoring system for everyone, but the importance (weight) of each nutritional element changes based on the user's health condition.

---

## Base Elements (Shared Constants)

| Element | Symbol | Base Weight |
|---------|--------|-------------|
| Sugar | Sugar | 0.30 |
| Salt | Salt | 0.15 |
| Fat | Fat | 0.10 |
| Saturated Fat | SatFat | 0.10 |
| Protein | Protein | 0.10 |
| Additives | Additives | 0.25 |
| **Total** | | **1.00** |

---

## Unified Scoring Formula

```
Score = 100 × (1 - Σ w_i × f_i)
```

Where:
- `w_i` = weight of element i
- `f_i` = risk factor of element i

---

## Adjustment Process

### Step 1: Initial Adjustment

```
w_raw[i] = w_base[i] × α[i]
```

### Step 2: Renormalization

```
w_user[i] = w_raw[i] / Σ w_raw
```

### Step 3: Risk Calculation

```
Risk = Σ (w_user[i] × f[i])
```

### Step 4: Final Score

```
Score = 100 × (1 - Risk)
```

---

## Health Conditions

### Condition 0: General Population

- α = 1.0 for all elements
- Result: Same as base weights

---

### Condition 1: Diabetes

| Element | α | Final Weight |
|---------|---|--------------|
| Sugar | 1.5 | 0.38 |
| Saturated Fat | 1.2 | 0.10 |
| Other Elements | 1.0 | Normalized |

**Rationale:** Higher emphasis on sugar control and saturated fat.

---

### Condition 2: Cardiovascular Disease

| Element | α | Final Weight |
|---------|---|--------------|
| Saturated Fat | 1.5 | 0.13 |
| Salt | 1.4 | 0.19 |
| Fat | 1.2 | 0.11 |
| Other Elements | 1.0 | Normalized |

**Rationale:** Focus on heart-healthy nutrients (limiting saturated fat, sodium, and total fat).

---

### Condition 3: High Blood Pressure (Hypertension)

| Element | α | Final Weight |
|---------|---|--------------|
| Salt | 1.6 | 0.22 |
| Saturated Fat | 1.2 | 0.11 |
| Other Elements | 1.0 | Normalized |

**Rationale:** Strong emphasis on sodium restriction.

---

### Condition 4: Food Allergies

- **If product contains allergen:**
```
Score = 0
```

- **If product does not contain allergen:**
  - Use standard model

---

### Condition 5: Children

| Element | α | Final Weight |
|---------|---|--------------|
| Sugar | 1.4 | 0.33 |
| Additives | 1.3 | 0.26 |
| Protein | 1.2 | 0.09 |
| Other Elements | 1.0 | Normalized |

**Rationale:** Limiting sugar and artificial additives; moderate protein needs.

---

## Comparison Table

| Element | General | Diabetes | Heart | Hypertension | Children |
|---------|---------|----------|-------|--------------|----------|
| Sugar | 0.30 | 0.38 | 0.27 | 0.27 | 0.33 |
| Salt | 0.15 | 0.13 | 0.19 | 0.22 | 0.12 |
| Fat | 0.10 | 0.09 | 0.11 | 0.09 | 0.08 |
| Saturated Fat | 0.10 | 0.10 | 0.13 | 0.11 | 0.08 |
| Protein | 0.10 | 0.09 | 0.09 | 0.09 | 0.09 |
| Additives | 0.25 | 0.21 | 0.22 | 0.23 | 0.26 |

---

## Priority Summary

| Condition | Highest Priority Elements |
|-----------|--------------------------|
| Diabetes | Sugar (38%) |
| Cardiovascular | Salt (19%), Saturated Fat (13%), Fat (11%) |
| Hypertension | Salt (22%), Saturated Fat (11%) |
| Allergies | Score = 0 if allergen present |
| Children | Sugar (33%), Additives (26%) |

---

## Important Notes

- Aligned with WHO (World Health Organization) recommendations
- Same mathematical equations for all users
- Only weights change based on health conditions
- Extensible system - new conditions can be easily added
- Decision support tool, not a medical diagnosis
- Always consult a healthcare professional or nutritionist
