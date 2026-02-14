# API Documentation

## Overview

ProdEye's API layer consists of Cloud Firestore database operations and Cloud Functions for complex business logic. This document describes all available endpoints, data models, and security rules.

## Base URLs

| Environment | Firestore | Functions |
|-------------|-----------|-----------|
| Development | `localhost:8080` | `http://localhost:5001` |
| Production | `https://firestore.googleapis.com` | `https://us-central1-prodeye.cloudfunctions.net` |

## Authentication

All API calls require Firebase Authentication. Include the ID token in the request:

```javascript
// Get current user token
const token = await firebase.auth().currentUser.getIdToken();

// Include in headers
headers: {
  'Authorization': 'Bearer ' + token
}
```

## Firestore Collections API

### Users Collection

#### Get User Profile
```
GET /users/{userId}
```

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | String | Yes | Firebase Auth UID |

**Response**:
```json
{
  "userId": "abc123",
  "email": "user@example.com",
  "name": "John Doe",
  "profile": {
    "age": 30,
    "gender": "male",
    "height": 175,
    "weight": 75,
    "activityLevel": 1.55
  },
  "healthProfile": {
    "conditions": ["diabetes"],
    "allergens": [],
    "lifestyle": "healthy",
    "dietType": "normal"
  },
  "createdAt": "2026-01-15T10:30:00Z",
  "updatedAt": "2026-02-10T14:20:00Z"
}
```

#### Update User Profile
```
PATCH /users/{userId}
```

**Request Body**:
```json
{
  "name": "John Doe Updated",
  "profile": {
    "age": 31,
    "weight": 74
  },
  "healthProfile": {
    "conditions": ["diabetes", "hypertension"],
    "lifestyle": "athlete"
  }
}
```

**Response**: Updated user document

---

### Products Collection

#### Get Product by ID
```
GET /products/{productId}
```

**Response**:
```json
{
  "productId": "prod_001",
  "barcode": "6134567890123",
  "name": "Whole Wheat Bread",
  "brand": "Boulangerie Algerienne",
  "companyId": "comp_001",
  "category": "Bakery",
  "imageUrl": "https://storage.../product_001.jpg",
  "nutrition": {
    "servingSize": 100,
    "calories": 247,
    "sugar": 6.0,
    "fat": 3.4,
    "saturatedFat": 0.6,
    "salt": 1.0,
    "protein": 13.0,
    "fiber": 7.0
  },
  "allergens": {
    "contains": ["gluten"],
    "mayContain": ["sesame"]
  },
  "additives": {
    "eNumbers": [],
    "count": 0
  },
  "createdAt": "2026-01-10T08:00:00Z",
  "updatedAt": "2026-01-10T08:00:00Z"
}
```

#### Search Products
```
GET /products?search={query}&category={cat}&limit={n}
```

**Query Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| search | String | No | Search term for name/brand |
| category | String | No | Filter by category |
| limit | Number | No | Max results (default: 20) |

**Response**: Array of product documents

---

### Scan History Collection

#### Get User Scan History
```
GET /scanHistory/{userId}/scans?limit={n}&orderBy={field}
```

**Query Parameters**:
| Name | Type | Default | Description |
|------|------|---------|-------------|
| limit | Number | 50 | Number of records |
| orderBy | String | scannedAt | Field to sort by |
| descending | Boolean | true | Sort direction |

**Response**:
```json
{
  "scans": [
    {
      "scanId": "scan_001",
      "userId": "user_001",
      "productId": "prod_001",
      "barcode": "6134567890123",
      "healthScore": 78.5,
      "compatibility": {
        "isCompatible": true,
        "warnings": []
      },
      "productSnapshot": {
        "name": "Whole Wheat Bread",
        "imageUrl": "https://..."
      },
      "scannedAt": "2026-02-14T09:30:00Z"
    }
  ],
  "total": 156
}
```

#### Add Scan Record
```
POST /scanHistory/{userId}/scans
```

**Request Body**:
```json
{
  "productId": "prod_001",
  "barcode": "6134567890123",
  "healthScore": 78.5,
  "compatibility": {
    "isCompatible": true,
    "warnings": []
  }
}
```

---

### Favorites Collection

#### Get User Favorites
```
GET /favorites/{userId}/items
```

**Response**:
```json
{
  "favorites": [
    {
      "favoriteId": "fav_001",
      "userId": "user_001",
      "itemType": "product",
      "itemId": "prod_001",
      "productData": {
        "name": "Whole Wheat Bread",
        "imageUrl": "https://..."
      },
      "addedAt": "2026-02-01T15:00:00Z"
    }
  ]
}
```

#### Add to Favorites
```
POST /favorites/{userId}/items
```

**Request Body**:
```json
{
  "itemType": "product",
  "itemId": "prod_001"
}
```

#### Remove from Favorites
```
DELETE /favorites/{userId}/items/{favoriteId}
```

---

## Cloud Functions API

### 1. scanBarcode

Processes barcode scanning requests and returns product information.

**Endpoint**:
```
POST /scanBarcode
```

**Request**:
```json
{
  "barcode": "6134567890123",
  "userId": "user_001"
}
```

**Response**:
```json
{
  "success": true,
  "product": {
    "productId": "prod_001",
    "name": "Whole Wheat Bread",
    "barcode": "6134567890123",
    "nutrition": {
      "calories": 247,
      "sugar": 6.0,
      "fat": 3.4,
      "saturatedFat": 0.6,
      "salt": 1.0,
      "protein": 13.0
    },
    "allergens": {
      "contains": ["gluten"]
    }
  },
  "healthScore": {
    "score": 78.5,
    "classification": "moderate",
    "color": "#EB8E17"
  },
  "compatibility": {
    "isCompatible": true,
    "warnings": [],
    "recommendations": [
      "Good source of fiber",
      "Low in saturated fat"
    ]
  },
  "scanId": "scan_001",
  "scannedAt": "2026-02-14T09:30:00Z"
}
```

**Error Responses**:
| Code | Description |
|------|-------------|
| 404 | Product not found |
| 401 | Unauthorized |
| 500 | Server error |

---

### 2. calculateHealthScore

Calculates the health score for a product based on WHO nutritional guidelines.

**Endpoint**:
```
POST /calculateHealthScore
```

**Request**:
```json
{
  "productId": "prod_001",
  "userId": "user_001"
}
```

**Response**:
```json
{
  "success": true,
  "score": 78.5,
  "classification": "moderate",
  "color": "#EB8E17",
  "breakdown": {
    "sugar": {
      "value": 6.0,
      "limit": 25.0,
      "normalized": 0.24,
      "riskFactor": 0.24,
      "weightedRisk": 0.072
    },
    "salt": {
      "value": 1.0,
      "limit": 5.0,
      "normalized": 0.20,
      "riskFactor": 0.20,
      "weightedRisk": 0.030
    },
    "fat": {
      "value": 3.4,
      "limit": 60.0,
      "normalized": 0.057,
      "riskFactor": 0.057,
      "weightedRisk": 0.006
    },
    "saturatedFat": {
      "value": 0.6,
      "limit": 20.0,
      "normalized": 0.03,
      "riskFactor": 0.03,
      "weightedRisk": 0.003
    },
    "protein": {
      "value": 13.0,
      "limit": 100.0,
      "normalized": 0.13,
      "riskFactor": 0.87,
      "weightedRisk": 0.087
    },
    "additives": {
      "count": 0,
      "normalized": 0.0,
      "riskFactor": 0.0,
      "weightedRisk": 0.0
    }
  },
  "totalRisk": 0.215,
  "weights": {
    "sugar": 0.30,
    "salt": 0.15,
    "fat": 0.10,
    "saturatedFat": 0.10,
    "protein": 0.10,
    "additives": 0.25
  }
}
```

---

### 3. checkCompatibility

Checks if a product is compatible with a user's health profile.

**Endpoint**:
```
POST /checkCompatibility
```

**Request**:
```json
{
  "productId": "prod_001",
  "userId": "user_001"
}
```

**Response**:
```json
{
  "success": true,
  "isCompatible": false,
  "checks": [
    {
      "type": "allergen",
      "passed": false,
      "message": "Contains lactose - not suitable for lactose intolerance",
      "severity": "high"
    },
    {
      "type": "condition_diabetes",
      "passed": false,
      "message": "High sugar content (15g per serving) - exceeds recommendation for diabetes",
      "severity": "medium"
    },
    {
      "type": "condition_hypertension",
      "passed": true,
      "message": "Salt content within acceptable range",
      "severity": "low"
    }
  ],
  "warnings": [
    "Contains lactose - not suitable for lactose intolerance",
    "High sugar content - not suitable for diabetes"
  ],
  "recommendations": [
    "Consider low-sugar alternatives",
    "Check ingredient list carefully"
  ],
  "userHealthProfile": {
    "conditions": ["diabetes"],
    "allergens": ["lactose"],
    "lifestyle": "healthy",
    "dietType": "normal"
  }
}
```

---

## Data Models

### User Model

```typescript
interface User {
  userId: string;
  email: string;
  name: string;
  profile: {
    age: number;
    gender: 'male' | 'female';
    height: number;  // cm
    weight: number;  // kg
    activityLevel: number;  // PAL multiplier
  };
  healthProfile: {
    conditions: HealthCondition[];
    allergens: string[];
    lifestyle: LifestyleType;
    dietType: DietType;
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

type HealthCondition = 
  | 'diabetes' 
  | 'hypertension' 
  | 'cardiovascular' 
  | 'kidney_disease'
  | 'lactose_intolerance'
  | 'gluten_intolerance';

type LifestyleType = 
  | 'normal' 
  | 'athlete' 
  | 'bodybuilder' 
  | 'diet' 
  | 'healthy';

type DietType = 
  | 'normal' 
  | 'vegetarian' 
  | 'vegan' 
  | 'meat_based' 
  | 'pescatarian';
```

### Product Model

```typescript
interface Product {
  productId: string;
  barcode: string;
  name: string;
  brand: string;
  companyId: string;
  category: string;
  imageUrl: string;
  nutrition: NutritionInfo;
  allergens: AllergenInfo;
  additives: AdditiveInfo;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

interface NutritionInfo {
  servingSize: number;  // grams
  calories: number;
  sugar: number;        // grams
  fat: number;          // grams
  saturatedFat: number; // grams
  salt: number;         // grams
  protein: number;      // grams
  fiber?: number;       // grams (optional)
}

interface AllergenInfo {
  contains: string[];
  mayContain: string[];
}

interface AdditiveInfo {
  eNumbers: string[];
  count: number;
}
```

### Health Score Model

```typescript
interface HealthScore {
  score: number;        // 0-100
  classification: 'healthy' | 'moderate' | 'unhealthy';
  color: string;        // Hex color code
  breakdown: {
    [nutrient: string]: NutrientScore;
  };
  totalRisk: number;    // 0-1
  weights: {
    [nutrient: string]: number;
  };
}

interface NutrientScore {
  value: number;
  limit: number;
  normalized: number;   // value/limit
  riskFactor: number;   // normalized or (1-normalized)
  weightedRisk: number; // riskFactor * weight
}
```

### Compatibility Model

```typescript
interface CompatibilityResult {
  isCompatible: boolean;
  checks: CompatibilityCheck[];
  warnings: string[];
  recommendations: string[];
}

interface CompatibilityCheck {
  type: string;
  passed: boolean;
  message: string;
  severity: 'low' | 'medium' | 'high';
}
```

---

## Error Handling

All API responses follow a consistent error format:

```json
{
  "success": false,
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "Product with barcode 6134567890123 not found",
    "details": {
      "barcode": "6134567890123"
    }
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or missing authentication |
| `PRODUCT_NOT_FOUND` | 404 | Barcode not in database |
| `USER_NOT_FOUND` | 404 | User ID not found |
| `INVALID_REQUEST` | 400 | Malformed request body |
| `SERVER_ERROR` | 500 | Internal server error |
| `RATE_LIMITED` | 429 | Too many requests |

## Rate Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| scanBarcode | 100 | per minute per user |
| calculateHealthScore | 200 | per minute per user |
| checkCompatibility | 200 | per minute per user |
| Firestore reads | 50,000 | per day per app |
| Firestore writes | 20,000 | per day per app |

---

For database schema, see [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md).
For architecture overview, see [ARCHITECTURE.md](ARCHITECTURE.md).
