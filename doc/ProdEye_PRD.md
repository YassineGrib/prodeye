# ProdEye – Product Health Scanner
# Product Requirements Document (PRD)

Version: 1.0  
Date: February 2026  
Country: Algeria 🇩🇿  
Language: English (Arabic later)  

---

# 1. Product Overview

## 1.1 Product Name

ProdEye

---

## 1.2 Product Description

ProdEye is a mobile application designed to help users in Algeria scan food product barcodes and instantly receive detailed health, nutrition, and safety analysis personalized to their health condition, lifestyle, and diet.

The application allows users to:

- Scan food products
- Know if a product is healthy or unhealthy
- Know if a product is suitable for their personal health condition
- Discover healthier alternatives
- Explore Algerian food companies
- Save favorite products and companies

ProdEye focuses specifically on Algerian food products and companies.

---

## 1.3 Problem Statement

Consumers in Algeria currently face several problems:

- Lack of clear health information about food products
- Difficulty knowing whether products are safe for their personal health condition
- No localized database focused on Algerian products
- No easy way to compare food health quality

ProdEye solves these problems.

---

## 1.4 Target Users

Primary Users:

- General consumers
- Athletes
- People with chronic diseases
- Health-conscious users

Secondary Users:

- Diet followers
- Vegetarians
- Fitness users

---

# 2. Objectives

## 2.1 Business Objectives

- Become the #1 food health scanner in Algeria
- Build the largest Algerian food database
- Build trust with users

---

## 2.2 User Objectives

Users should be able to:

- Scan products quickly
- Know if products are safe
- Know if products are compatible with their health
- Save favorites
- Discover companies

---

# 3. Core Features

---

# 3.1 Authentication

## Features

User can:

- Register
- Login
- Logout

Authentication methods:

- Email
- Google (Future)

---

# 3.2 User Profile

User profile stores:

## Personal Information

- Name
- Age
- Gender
- Height
- Weight

---

## Health Conditions

Multi-select:

Examples:

- Diabetes
- High blood pressure
- Heart disease
- Kidney disease
- Lactose intolerance
- Gluten intolerance
- Allergies

---

## Lifestyle

Options:

- Normal
- Athlete
- Bodybuilder
- Diet
- Healthy lifestyle

---

## Diet Type

Options:

- Normal
- Vegetarian
- Vegan
- Meat-based
- Pescatarian

---

# 3.3 Barcode Scan Feature

Core feature of the application.

User can:

- Open camera
- Scan barcode

System will:

- Identify product
- Load product data
- Analyze product

---

# 3.4 Product Analysis

The system will calculate:

Health Score

Example:

Score: 8 / 10

Color system:

Green = Healthy  
Yellow = Moderate  
Red = Unhealthy  

---

## Personalized Compatibility

Example:

Compatible with user: YES / NO

Based on:

- User diseases
- Allergies
- Lifestyle

---

## Nutrition Information

Display:

- Calories
- Sugar
- Fat
- Salt
- Protein

---

## Warning System

Example:

Contains:

- Lactose
- Gluten

---

# 3.5 Product Details Page

Displays:

- Product name
- Product image
- Brand
- Barcode
- Health score
- Nutrition info
- Compatibility result

Actions:

- Add to favorites

---

# 3.6 Favorites Feature

User can save:

- Products
- Companies

---

# 3.7 Companies Module

Displays Algerian companies.

Each company includes:

- Name
- Logo
- Description
- Location

---

## Company Rating System

Ratings include:

Health rating  
Taste rating  
Quality rating  
Price rating  

---

## Company Details Page

Displays:

- Company info
- Products list
- Ratings

User can:

- Add to favorites

---

# 3.8 Home Page

Dashboard includes:

- Search bar
- Quick scan button
- Recommended products
- Popular products
- Healthy alternatives

---

# 3.9 Search Feature

User can search:

- Products
- Companies

---

# 3.10 Scan History

User can view:

- Previously scanned products

---

# 4. User Flow

---

## First Time User Flow

Splash

↓

Welcome

↓

Register

↓

Health Setup

↓

Home

---

## Scan Flow

Home

↓

Scan

↓

Product Result

↓

Save Favorite (optional)

---

# 5. Technical Requirements

---

# 5.1 Platform

Mobile application:

Android (First)

iOS (Future)

---

# 5.2 Technology Stack

Frontend:

Flutter

Backend:

Laravel API

Database:

MySQL

---

# 5.3 External Services

Barcode Scanner Library

Cloud Storage

Authentication Service

---

# 6. Database Overview

Main tables:

Users

Products

Companies

Favorites

Scan History

Health Conditions

Ratings

---

# 7. UI / UX Requirements

Design must be:

Modern

Clean

Professional

Simple

---

Support:

Arabic (Primary future)

English

---

# 8. Localization

Country:

Algeria

Currency:

DZD

Language:

Arabic (Future)

English (MVP)

---

# 9. Security Requirements

Secure authentication

Encrypted passwords

Secure API

---

# 10. Performance Requirements

Scan result time:

Less than 2 seconds

App launch:

Less than 3 seconds

---

# 11. Future Features

AI Recommendations

Community ratings

Add product manually

Admin dashboard

Offline mode

---

# 12. Success Metrics

KPIs:

Number of users

Daily scans

User retention

Favorites count

---

# 13. MVP Scope

MVP must include:

Authentication

Profile

Scan

Product analysis

Favorites

Companies

---

# 14. Out of Scope (Future)

Social features

Messaging

Community forums

---

# 15. Conclusion

ProdEye is a localized health scanner application designed to improve consumer awareness and safety in Algeria.

The application provides personalized food health analysis using barcode scanning and user health profiles.

---

END OF DOCUMENT
