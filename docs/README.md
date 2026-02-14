# ProdEye - Algerian Food Health Scanner

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Services-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

**ProdEye** is a mobile application designed to help users in Algeria scan food product barcodes and instantly receive detailed health, nutrition, and safety analysis personalized to their health condition, lifestyle, and diet.

The application bridges the gap between consumers and health information by providing real-time analysis of Algerian food products with personalized compatibility checks.

## 🎯 Purpose

ProdEye addresses key consumer challenges in Algeria:

- **Lack of health information** - Clear health ratings for food products
- **Personal compatibility** - Know if products are safe for your health condition
- **Localized database** - Focus on Algerian food products and companies
- **Easy comparison** - Compare food health quality instantly

## ✨ Features

### Core Features

| Feature | Description |
|---------|-------------|
| 🔍 **Barcode Scanner** | Quick product identification using camera |
| 📊 **Health Score** | WHO-based nutritional scoring (0-100) |
| ⚠️ **Compatibility Check** | Personalized safety alerts based on health profile |
| 🏢 **Company Explorer** | Discover Algerian food companies |
| ⭐ **Favorites** | Save preferred products and companies |
| 📜 **Scan History** | Track previously scanned products |

### Personalized Health Analysis

- **Health Conditions**: Diabetes, Hypertension, Heart Disease, Allergies
- **Lifestyle Types**: Normal, Athlete, Bodybuilder, Diet, Healthy
- **Diet Preferences**: Normal, Vegetarian, Vegan, Meat-based, Pescatarian

## 🏗️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language

### Backend & Cloud
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - Image and asset storage
- **Cloud Functions** - Serverless backend logic

### External Services
- Barcode scanning libraries
- Cloud vision APIs

## 📱 Supported Platforms

| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | 🚧 Coming Soon |

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0 or higher)
- Firebase CLI
- Android Studio / Xcode
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/prodeye.git
cd prodeye

# Install dependencies
flutter pub get

# Configure Firebase (see SETUP_GUIDE.md for details)
flutterfire configure

# Run the app
flutter run
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture and design patterns |
| [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) | Firestore data structure and relationships |
| [API_DOCUMENTATION.md](API_DOCUMENTATION.md) | API endpoints and data models |
| [UI_UX_GUIDE.md](UI_UX_GUIDE.md) | Design system and component guidelines |
| [HEALTH_SCORING.md](HEALTH_SCORING.md) | Health score algorithm documentation |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Complete development environment setup |

## 🎨 Brand Colors

| Color | Hex Code | Usage |
|-------|----------|-------|
| Primary Blue | `#165FA3` | Main brand, buttons, links |
| Success Green | `#0F7140` | Healthy products, success states |
| Warning Orange | `#EB8E17` | Moderate products, warnings |
| Danger Red | `#BA321F` | Unhealthy products, errors |

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- World Health Organization (WHO) for nutritional guidelines
- Algerian food manufacturers for product data
- Open-source community for Flutter and Firebase tools

## 📞 Support

For support, email support@prodeye.dz or join our [Discord community](https://discord.gg/prodeye).

---

**Made with ❤️ in Algeria**
