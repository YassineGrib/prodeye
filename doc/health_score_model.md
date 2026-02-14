# Mathematical Model for Health Score Calculation

A model based on WHO (World Health Organization) recommendations for calculating personalized health assessments of food products based on user data and product information.

---

## 1. User Inputs

| Variable | Symbol | Unit | Example |
|----------|--------|------|---------|
| Gender | sex | male / female | male |
| Age | age | years | 30 |
| Weight | weight_kg | kg | 75 |
| Height | height_cm | cm | 175 |
| Activity Level | PAL | multiplier | 1.55 |

### PAL (Physical Activity Level) Values

| Value | Activity Level |
|-------|---------------|
| 1.2 | Sedentary (little to no exercise) |
| 1.375 | Lightly active (1-3 days/week) |
| 1.55 | Moderately active (3-5 days/week) |
| 1.725 | Very active (6-7 days/week) |
| 1.9 | Extra active (physical job/training 2x/day) |

---

## 2. Product Data (Per Serving)

| Nutrient | Symbol | Example |
|----------|--------|---------|
| Sugar | sugar_g | 15 g |
| Fat | fat_g | 8 g |
| Saturated Fat | satfat_g | 3 g |
| Salt | salt_g | 1.2 g |
| Protein | protein_g | 5 g |
| Fiber (optional) | fiber_g | 2 g |
| Additives (optional) | additives_count | 3 |

### Converting from 100g to Serving Size

```
value_serving = (value_per100g × serving_g) / 100
```

---

## 3. System Constants

| Constant | Symbol | Value |
|----------|--------|-------|
| Sugar calories | k_s | 4 kcal/g |
| Fat calories | k_f | 9 kcal/g |
| Protein calories | k_p | 4 kcal/g |
| Salt daily limit | salt_daily | 5 g |
| Protein ratio | ρ_p | 0.15 |

### Base Weights

| Element | Weight |
|---------|--------|
| Sugar | 0.30 |
| Salt | 0.15 |
| Fat | 0.10 |
| Saturated Fat | 0.10 |
| Protein | 0.10 |
| Additives | 0.25 |

---

## 4. Energy Calculation

### Basal Metabolic Rate (BMR)

**For Men:**
```
BMR = 10w + 6.25h - 5a + 5
```

**For Women:**
```
BMR = 10w + 6.25h - 5a - 161
```

Where:
- w = weight in kg
- h = height in cm
- a = age in years

### Total Energy Expenditure (TEE)

```
TEE = BMR × PAL
```

---

## 5. Daily Limits

| Nutrient | Equation |
|----------|----------|
| Sugar | 0.10 × TEE / 4 |
| Fat | 0.30 × TEE / 9 |
| Saturated Fat | 0.10 × TEE / 9 |
| Salt | 5 g |
| Protein | 0.15 × TEE / 4 |

**Example:**
```
TEE = 2633 kcal
```

---

## 6. Normalization (μ)

| Nutrient | Equation |
|----------|----------|
| Sugar | μ = sugar_g / limit |
| Fat | μ = fat_g / limit |
| Saturated Fat | μ = satfat_g / limit |
| Salt | μ = salt_g / 5 |
| Protein | μ = protein_g / limit |
| Additives | μ = count / 5 |

---

## 7. Risk Factor Conversion

| Nutrient | Risk Factor (f) |
|----------|----------------|
| Sugar | f = μ |
| Salt | f = μ |
| Fat | f = μ |
| Saturated Fat | f = μ |
| Protein | f = 1 - μ |
| Additives | f = μ |

---

## 8. Weight Adjustment (Optional)

```
w_user = (w_base × α) / Σ(w_base × α)
```

Where α is the adjustment factor based on health conditions.

---

## 9. Final Score Calculation

```
Risk = Σ(w × f)
Score = (1 - Risk) × 100
```

**Example:**
```
Risk = 0.3686
Score = 63.14
```

---

## 10. Health Classification

| Score | Classification |
|-------|---------------|
| ≥ 80 | Healthy |
| 50 - 79 | Moderate |
| < 50 | Unhealthy |

---

## Complete Example

```
Risk = 0.30×0.228
     + 0.15×0.240
     + 0.10×0.091
     + 0.10×0.102
     + 0.10×0.949
     + 0.25×0.600

     = 0.3686

Score = 63.14
```

**Classification:** Moderate

---

## Important Notes

- Based on WHO recommendations
- Weights are customizable per health condition
- Optional nutrients can be omitted if data unavailable
- Extensible architecture for future enhancements
