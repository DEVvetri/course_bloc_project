
## 🧭 Overview

E-COM DEMO is a scalable, production-ready mobile application built using **Flutter**, designed with a modular architecture and real-time data synchronization. The app integrates modern backend services and local storage mechanisms to provide seamless user experiences even in offline scenarios.

The system leverages **Firebase services** for authentication, and cloud storage, while using **Hive** for efficient local persistence. The architecture is optimized for performance, maintainability, and scalability.

---

## 🚀 Features

### 🔐 Authentication
- Firebase Authentication (Email/Password, Token-based sessions)
- Secure session handling
- Logout and session cleanup
- monorepo - melos
### 🛒 Cart Management
- Add / update / remove products
- Quantity management
- Offline-first cart using Hive
- Sync with Firebase 

### 🔄 Data Synchronization
- Hybrid data handling (Local + Remote)
- Conflict resolution strategies
- Real-time updates with Firebase

### 📦 Product Module
- Product listing and details
- State management for product updates
- Modular and reusable components

### ⚙️ Settings & User Controls
- Logout handling
- Cart clearing (local + remote)
- User-specific configurations

---

## 🏗️ Project Structure
lib/
│
├── modules/
│ ├── products/
│ ├── cart/
│
├── core/
│ ├── theme/
│ ├── constants/
│ ├── utils/
│ └── widgets/
│ └── data/
│ └── domain/
│ └── presentation/
│
│
└── main.dart


### 🔍 Structure Highlights
- **Modular architecture** → Each feature is isolated  
- **Bloc pattern** → Clean state management  
- **Service layer separation** → Firebase, Hive, 
- **Core layer** → Centralized theme, constants, reusable widgets  

---

## 🛠️ Tech Stack

### 📱 Frontend
- Flutter (Dart)
- Bloc (State Management)

### 💾 Local Storage
- Hive (Lightweight NoSQL DB)

---

## ⚙️ Architecture

- **Offline-first approach**
- **Hybrid sync model (Local Hive + Remote Firebase)**
- **Event-driven state management (Bloc)**
- **Separation of concerns (UI / Business / Data layers)**

---