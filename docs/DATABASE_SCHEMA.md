# Database Schema

## Overview

ProdEye uses **Cloud Firestore** as its primary database. This document describes the complete data structure, relationships, and data flow.

## Entity Relationship Diagram

```mermaid
erDiagram
    USERS ||--o{ SCAN_HISTORY : has
    USERS ||--o{ FAVORITES : has
    USERS ||--o{ USER_HEALTH_CONDITIONS : contains
    PRODUCTS ||--o{ PRODUCT_NUTRITION : contains
    PRODUCTS ||--o{ PRODUCT_ALLERGENS : contains
    PRODUCTS ||--o{ PRODUCT_ADDITIVES : contains
    COMPANIES ||--o{ PRODUCTS : produces
    COMPANIES ||--o{ COMPANY_RATINGS : has
    USERS ||--o{ COMPANY_RATINGS : submits
    
    USERS {
        string userId PK
        string email
        string name
        timestamp createdAt
        timestamp updatedAt
        map profile
    }
    
    USER_HEALTH_CONDITIONS {
        string conditionId PK
        string userId FK
        string conditionType
        array allergens
        string lifestyle
        string dietType
    }
    
    PRODUCTS {
        string productId PK
        string barcode
        string name
        string brand
        string companyId FK
        string category
        string imageUrl
        timestamp createdAt
    }
    
    PRODUCT_NUTRITION {
        string productId PK
        float calories
        float sugar_g
        float fat_g
        float satfat_g
        float salt_g
        float protein_g
        float fiber_g
        float serving_size_g
    }
    
    PRODUCT_ALLERGENS {
        string productId PK
        array contains
        array mayContain
    }
    
    PRODUCT_ADDITIVES {
        string productId PK
        array eNumbers
        int count
    }
    
    COMPANIES {
        string companyId PK
        string name
        string description
        string logoUrl
        string location
        float overallRating
        timestamp createdAt
    }
    
    COMPANY_RATINGS {
        string ratingId PK
        string companyId FK
        string userId FK
        int healthRating
        int tasteRating
        int qualityRating
        int priceRating
        timestamp createdAt
    }
    
    SCAN_HISTORY {
        string scanId PK
        string userId FK
        string productId FK
        float healthScore
        boolean isCompatible
        timestamp scannedAt
    }
    
    FAVORITES {
        string favoriteId PK
        string userId FK
        string itemId
        string itemType
        string productId
        string companyId
        timestamp addedAt
    }
```

## Data Flow Diagram

```mermaid
flowchart TD
    subgraph Client["Client (Flutter)"]
        UI["User Interface"]
        State["State Management"]
    end
    
    subgraph Firebase["Firebase Platform"]
        subgraph Auth["Authentication"]
            FB_AUTH["Firebase Auth"]
        end
        
        subgraph Firestore["Cloud Firestore"]
            COL_USERS["users/ collection"]
            COL_PRODUCTS["products/ collection"]
            COL_COMPANIES["companies/ collection"]
            COL_SCANS["scanHistory/ collection"]
            COL_FAV["favorites/ collection"]
        end
        
        subgraph Functions["Cloud Functions"]
            FN_SCAN["scanBarcode()"]
            FN_SCORE["calculateHealthScore()"]
            FN_COMPAT["checkCompatibility()"]
        end
        
        subgraph Storage["Firebase Storage"]
            BUCKET_IMAGES["product-images/"]
            BUCKET_LOGOS["company-logos/"]
        end
    end
    
    UI --> State
    State --> FB_AUTH
    State --> COL_USERS
    State --> COL_PRODUCTS
    State --> COL_COMPANIES
    State --> COL_SCANS
    State --> COL_FAV
    
    UI --> FN_SCAN
    FN_SCAN --> COL_PRODUCTS
    FN_SCAN --> FN_SCORE
    FN_SCAN --> FN_COMPAT
    FN_SCORE --> COL_PRODUCTS
    FN_COMPAT --> COL_USERS
    FN_COMPAT --> COL_PRODUCTS
    
    COL_PRODUCTS --> BUCKET_IMAGES
    COL_COMPANIES --> BUCKET_LOGOS
```

## Collections

### 1. Users Collection

**Path**: `users/{userId}`

Stores user profile information and health preferences.

| Field | Type | Description |
|-------|------|-------------|
| `userId` | String | Firebase Auth UID (PK) |
| `email` | String | User email address |
| `name` | String | Display name |
| `profile` | Map | User demographics |
| `healthProfile` | Map | Health conditions and preferences |
| `createdAt` | Timestamp | Account creation date |
| `updatedAt` | Timestamp | Last update timestamp |

**Profile Map Structure**:
```javascript
{
  "age": 30,
  "gender": "male", // or "female"
  "height": 175,    // cm
  "weight": 75,     // kg
  "activityLevel": 1.55 // PAL multiplier
}
```

**Health Profile Map**:
```javascript
{
  "conditions": ["diabetes", "hypertension"],
  "allergens": ["lactose", "gluten"],
  "lifestyle": "healthy",
  "dietType": "normal"
}
```

### 2. Products Collection

**Path**: `products/{productId}`

Central repository of all food products in the database.

| Field | Type | Description |
|-------|------|-------------|
| `productId` | String | Unique identifier (PK) |
| `barcode` | String | EAN/UPC barcode |
| `name` | String | Product name |
| `brand` | String | Brand name |
| `companyId` | String | Reference to manufacturer (FK) |
| `category` | String | Food category |
| `imageUrl` | String | Firebase Storage URL |
| `nutrition` | Map | Nutritional information |
| `allergens` | Map | Allergen information |
| `additives` | Map | Additive information |
| `createdAt` | Timestamp | Entry creation date |
| `updatedAt` | Timestamp | Last update date |

**Nutrition Map**:
```javascript
{
  "servingSize": 100,    // grams
  "calories": 250,       // kcal
  "sugar": 15.0,         // grams
  "fat": 8.0,            // grams
  "saturatedFat": 3.0,   // grams
  "salt": 1.2,           // grams
  "protein": 5.0,        // grams
  "fiber": 2.0           // grams (optional)
}
```

**Allergens Map**:
```javascript
{
  "contains": ["lactose", "gluten"],
  "mayContain": ["nuts", "soy"]
}
```

**Additives Map**:
```javascript
{
  "eNumbers": ["E100", "E440"],
  "count": 2
}
```

### 3. Companies Collection

**Path**: `companies/{companyId}`

Algerian food manufacturers and brands.

| Field | Type | Description |
|-------|------|-------------|
| `companyId` | String | Unique identifier (PK) |
| `name` | String | Company name |
| `description` | String | Company description |
| `logoUrl` | String | Logo image URL |
| `location` | String | City/Region in Algeria |
| `website` | String | Website URL |
| `ratingStats` | Map | Aggregate rating data |
| `productCount` | Number | Number of products |
| `createdAt` | Timestamp | Entry creation date |

**Rating Stats Map**:
```javascript
{
  "healthRating": 4.2,
  "tasteRating": 3.8,
  "qualityRating": 4.0,
  "priceRating": 3.5,
  "totalRatings": 156
}
```

### 4. Scan History Collection

**Path**: `scanHistory/{userId}/scans/{scanId}`

Subcollection storing each user's scan activity.

| Field | Type | Description |
|-------|------|-------------|
| `scanId` | String | Unique scan identifier (PK) |
| `userId` | String | User reference (FK) |
| `productId` | String | Product scanned (FK) |
| `barcode` | String | Scanned barcode |
| `healthScore` | Number | Calculated score (0-100) |
| `compatibility` | Map | Compatibility results |
| `scannedAt` | Timestamp | Scan timestamp |

**Compatibility Map**:
```javascript
{
  "isCompatible": false,
  "warnings": [
    "Contains lactose - not suitable for lactose intolerance",
    "High sugar content - not suitable for diabetes"
  ]
}
```

### 5. Favorites Collection

**Path**: `favorites/{userId}/items/{favoriteId}`

User-saved products and companies.

| Field | Type | Description |
|-------|------|-------------|
| `favoriteId` | String | Unique identifier (PK) |
| `userId` | String | User reference (FK) |
| `itemType` | String | "product" or "company" |
| `itemId` | String | ProductId or CompanyId |
| `productData` | Map | Cached product info (if type=product) |
| `companyData` | Map | Cached company info (if type=company) |
| `addedAt` | Timestamp | When favorited |

## Indexes

### Required Composite Indexes

| Collection | Fields | Purpose |
|------------|--------|---------|
| `scanHistory/{userId}/scans` | `scannedAt` (desc) | Recent scans first |
| `products` | `category`, `name` | Category filtering |
| `companies` | `overallRating` (desc) | Top-rated companies |

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents - users can only access their own
    match /users/{userId} {
      allow read, write: if request.auth != null 
                        && request.auth.uid == userId;
    }
    
    // Products - publicly readable, admin writable
    match /products/{productId} {
      allow read: if true;
      allow write: if false; // Only via Cloud Functions
    }
    
    // Companies - publicly readable
    match /companies/{companyId} {
      allow read: if true;
      allow write: if false;
    }
    
    // Scan history - user can only access own scans
    match /scanHistory/{userId}/scans/{scanId} {
      allow read, write: if request.auth != null 
                        && request.auth.uid == userId;
    }
    
    // Favorites - user can only access own favorites
    match /favorites/{userId}/items/{favoriteId} {
      allow read, write: if request.auth != null 
                        && request.auth.uid == userId;
    }
  }
}
```

## Data Relationships

### One-to-Many Relationships

| Parent | Child | Relationship |
|--------|-------|--------------|
| User | Scan History | One user has many scans |
| User | Favorites | One user has many favorites |
| Company | Products | One company has many products |

### Many-to-Many Relationships

| Entity 1 | Entity 2 | Junction Collection |
|----------|----------|-------------------|
| Users | Products | scanHistory + favorites |
| Users | Companies | favorites |

## Data Retention

| Collection | Retention Policy |
|------------|-----------------|
| `scanHistory` | Keep 90 days, archive older |
| `favorites` | Permanent until user deletes |
| `users` | Permanent, anonymize on deletion |

---

For architecture overview, see [ARCHITECTURE.md](ARCHITECTURE.md).
For API details, see [API_DOCUMENTATION.md](API_DOCUMENTATION.md).
