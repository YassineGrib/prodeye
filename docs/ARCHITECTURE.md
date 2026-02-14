# Architecture Documentation

## System Overview

ProdEye follows a modern serverless architecture built on Google Firebase, with a Flutter frontend providing a responsive cross-platform mobile experience.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Flutter Application                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │   │
│  │  │  UI Layer   │  │  BLoC/State │  │  Service Layer  │ │   │
│  │  │  (Widgets)  │  │   (Logic)   │  │  (API Calls)    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘ │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS / gRPC
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     FIREBASE PLATFORM                            │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │  Authentication  │  │  Cloud Firestore  │  │   Firebase Storage   │ │
│  │  (Auth)          │  │  (Database)       │  │   (Files/Images)     │ │
│  └──────────────┘  └──────────────┘  └──────────────────────┘ │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Cloud Functions                          │  │
│  │  ┌─────────────┐  ┌─────────────────┐  ┌─────────────┐   │  │
│  │  │ scanBarcode │  │calculateHealth  │  │checkCompat- │   │  │
│  │  │             │  │    Score        │  │  ibility    │   │  │
│  │  └─────────────┘  └─────────────────┘  └─────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Architecture Patterns

### 1. Clean Architecture

```
Presentation Layer (Flutter UI)
         │
         ▼
Domain Layer (BLoC/Provider)
         │
         ▼
Data Layer (Repositories)
         │
         ▼
Firebase Services
```

### 2. State Management

- **BLoC Pattern** - Business logic component separation
- **Provider** - Dependency injection and state propagation
- **StreamBuilder** - Reactive UI updates from Firestore

### 3. Repository Pattern

```dart
// Abstract repository interface
abstract class ProductRepository {
  Future<Product> getProductByBarcode(String barcode);
  Future<List<Product>> searchProducts(String query);
}

// Firebase implementation
class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;
  // Implementation...
}
```

## Firebase Services

### Authentication Service

**Purpose**: User identity management and security

| Feature | Implementation |
|---------|---------------|
| Email/Password | Firebase Auth |
| Google Sign-In | Firebase Auth + Google OAuth |
| Session Management | Firebase Auth tokens |
| Security Rules | Firestore Security Rules |

### Cloud Firestore

**Purpose**: Primary database for application data

**Characteristics**:
- NoSQL document database
- Real-time synchronization
- Offline persistence support
- Automatic scaling

**Collections**:
- `users` - User profiles and health data
- `products` - Food product information
- `companies` - Algerian food companies
- `scanHistory` - User scan records
- `favorites` - Saved items

### Firebase Storage

**Purpose**: File and image storage

**Stored Content**:
- Product images
- Company logos
- User profile pictures
- App assets

### Cloud Functions

**Purpose**: Serverless backend logic

| Function | Trigger | Purpose |
|----------|---------|---------|
| `scanBarcode` | HTTP Callable | Process barcode scan requests |
| `calculateHealthScore` | HTTP Callable | Compute product health rating |
| `checkCompatibility` | HTTP Callable | Check user-product compatibility |

## Data Flow

### Scan Flow

```
1. User opens camera (Flutter)
         │
         ▼
2. Barcode detected (ML Kit)
         │
         ▼
3. Call scanBarcode() function
         │
         ▼
4. Query Firestore for product
         │
         ▼
5. Call calculateHealthScore()
         │
         ▼
6. Call checkCompatibility()
         │
         ▼
7. Return results to Flutter UI
```

### User Profile Flow

```
1. User updates profile (Flutter)
         │
         ▼
2. Validate input (BLoC)
         │
         ▼
3. Write to Firestore
         │
         ▼
4. Security rules validate
         │
         ▼
5. Update local state
         │
         ▼
6. Sync to other devices
```

## Security Architecture

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are publicly readable
    match /products/{productId} {
      allow read: if true;
      allow write: if false; // Only via admin/backend
    }
  }
}
```

### Authentication Flow

```
┌─────────┐     ┌─────────────┐     ┌─────────────────┐
│  User   │────▶│  Firebase   │────▶│  ID Token       │
│  Login  │     │  Auth       │     │  (JWT)          │
└─────────┘     └─────────────┘     └─────────────────┘
                                              │
                                              ▼
                                     ┌─────────────────┐
                                     │  Firestore      │
                                     │  Secure Access  │
                                     └─────────────────┘
```

## Scalability Considerations

### Horizontal Scaling
- Firestore automatically scales with demand
- Cloud Functions scale per request
- CDN for Storage assets

### Performance Optimization
- Firestore caching and offline support
- Image optimization and lazy loading
- Pagination for large lists
- Debounced search queries

## Deployment Architecture

### Environments

| Environment | Firebase Project | Purpose |
|-------------|------------------|---------|
| Development | prodeye-dev | Local development |
| Staging | prodeye-staging | QA testing |
| Production | prodeye-prod | Live application |

### CI/CD Pipeline

```
Git Push → GitHub Actions → Build → Test → Deploy to Firebase
```

## Monitoring & Analytics

- **Firebase Analytics** - User behavior tracking
- **Crashlytics** - Error reporting and crash analysis
- **Performance Monitoring** - App performance metrics

## Future Architecture Considerations

1. **Edge Functions** - For lower latency
2. **Firestore Data Bundles** - For faster initial loads
3. **Cloud Run** - For complex processing
4. **Machine Learning** - Product recommendation engine

---

For detailed database structure, see [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md).
For API details, see [API_DOCUMENTATION.md](API_DOCUMENTATION.md).
