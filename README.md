# 📱 HRMS Mobile Application (Android & iOS)

A complete cross-platform **Flutter** mobile application for **Android** and **iPhone (iOS)**, built to connect directly to the **live Render PostgreSQL Database** (`hrms_saas_db_ugxf`) via the deployed HRMS Backend API.

---

## 🚀 Live System Architecture

Both the **Web Application** and this **Mobile App (Android & iPhone)** share the **same Render PostgreSQL Database**:

```
        [ Web Portal ]                 [ Android Phone ]        [ Apple iPhone ]
              |                                 \                      /
              |                                  \                    /
              v                                   v                  v
  +-------------------------------------------------------------------------+
  |              HRMS REST API Service (Node.js / Express)                  |
  |               https://hrms-backend-5xo8.onrender.com                    |
  +-------------------------------------------------------------------------+
                                      |
                                      v
  +-------------------------------------------------------------------------+
  |               Live Render PostgreSQL Database                           |
  |      (Organizations, Roles, 12 Existing Employees, Attendance, Leaves) |
  +-------------------------------------------------------------------------+
```

---

## 👥 Role-Based Access Control

### 1. Employee View
- **Secure Authentication**: Corporate email + password authentication against Render DB.
- **Attendance Punch-In & Punch-Out**:
  - Live GPS location coordinates tagging.
  - Device info auto-detection (e.g. `Apple iPhone`, `Samsung Galaxy (Android)`).
  - Geofence calculation against office premises.
  - Real-time work duration timer.
- **Leave Management**:
  - View real-time leave balances (Casual, Sick, Paid, Privilege).
  - Apply for full-day or half-day leaves with approver selection.
  - Review request status (Pending, Approved, Rejected) and cancel pending requests.
- **Profile & Directory**:
  - Profile completion percentage bar.
  - Employment details, department, designation, and reporting manager.

### 2. HR & Admin View
- **Overview Dashboard**:
  - Live counts of all 12 employees.
  - Today's active present count, on-leave employees, and pending requests.
- **Employee Directory**:
  - Complete list of all 12 employees currently in the Render DB.
  - Instant search by employee name, code, designation, or email.
- **Company Announcements**:
  - View and broadcast organizational notices across web and mobile.

---

## 📂 Project Structure

```
E:\hrms_app\v1\
├── pubspec.yaml                 # Dependencies (http, provider, geolocator, device_info_plus, etc.)
├── android/                     # Native Android project (Permissions, Gradle, MainActivity)
├── ios/                         # Native iOS project (Runner, Info.plist, permissions)
└── lib/
    ├── main.dart                # App entry point with MultiProvider setup
    ├── constants/
    │   ├── api_constants.dart   # Live Render backend API endpoints
    │   └── app_theme.dart       # Modern Material 3 theme & color palette
    ├── models/
    │   ├── user_model.dart      # User session & role model (Admin vs Employee)
    │   ├── attendance_model.dart# Daily attendance, punches & KPIs
    │   ├── leave_model.dart     # Leave balances, types & requests
    │   └── employee_model.dart  # Employee record model
    ├── services/
    │   ├── api_service.dart     # HTTP client for all Render backend endpoints
    │   ├── storage_service.dart # SharedPreferences session storage
    │   └── location_service.dart# GPS & device detection
    ├── providers/
    │   ├── auth_provider.dart   # Authentication & session lifecycle
    │   └── attendance_provider.dart # Punch-in/out logic & state
    ├── screens/
    │   ├── splash_screen.dart   # Session verification & routing
    │   ├── auth/
    │   │   └── login_screen.dart # Login with email/password
    │   ├── employee/
    │   │   ├── employee_main_screen.dart # Bottom navigation
    │   │   ├── employee_home_screen.dart # Home dashboard & quick punch
    │   │   ├── attendance_screen.dart    # Detailed punch & monthly logs
    │   │   ├── leave_screen.dart         # Leave balances & apply modal
    │   │   └── profile_screen.dart       # User profile & sign-out
    │   └── admin/
    │       ├── admin_main_screen.dart    # HR Bottom navigation
    │       ├── admin_home_screen.dart    # HR Dashboard overview
    │       ├── admin_employee_list_screen.dart # Directory of all 12 employees
    │       └── admin_announcements_screen.dart # Company announcements
    └── widgets/
        ├── custom_button.dart   # Reusable elevated/outlined button
        ├── custom_text_field.dart # Form text input with validation
        └── stat_card.dart       # KPI metric cards
```

---

## 📲 How to Run the App

### Prerequisites
- Install **Flutter SDK** (v3.0.0 or higher): [flutter.dev](https://flutter.dev)
- For Android: **Android Studio** with Android SDK.
- For iOS: **Xcode** (on macOS).

### 1. Install Dependencies
Open terminal inside `E:\hrms_app\v1` and run:
```bash
cd E:\hrms_app\v1
flutter pub get
```

### 2. Run on Android
Connect your Android phone via USB (with USB Debugging enabled) or start an Android Emulator, then run:
```bash
flutter run -d android
```

To build a standalone Android APK:
```bash
flutter build apk --release
```
The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`.

### 3. Run on iPhone (iOS)
Open a macOS machine or Xcode, and run:
```bash
flutter run -d ios
```

---

## 🔑 Login Credentials

You can log in with any of your **12 existing employee accounts** or **admin accounts** already present in your Render PostgreSQL database.
