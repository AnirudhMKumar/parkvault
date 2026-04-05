# 🅿️ ParkVault

> **Smart parking management, zero infrastructure.** Track vehicles, manage passes, handle valet — all offline, all beautiful.

---

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.11.4-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Offline-First](https://img.shields.io/badge/Offline--First-Yes-2ECC71)
![No Backend](https://img.shields.io/badge/No%20Backend-Required-F39C12)
![License](https://img.shields.io/badge/License-MIT-3498DB)

</div>

---

## 📖 What is ParkVault?

ParkVault is a modern, offline-first parking management application built with Flutter. It handles everything from vehicle entry/exit ticketing to valet parking workflows, pass subscriptions, FASTag simulation, and detailed analytics — **without needing a single server**.

All data lives on-device using `SharedPreferences` as a lightweight JSON store. Perfect for single-lot operators, small parking businesses, or anyone who wants a reliable system that works even when the internet doesn't.

---

## ✨ Features

| | |
|---|---|
| 🎫 **Auto Ticket Generation** | Vehicle entry/exit with unique ticket IDs, timestamps, and fee calculation |
| 🪪 **Pass Management** | Monthly, Weekly, VIP & Staff passes with validity tracking |
| 🧑‍💼 **Valet Parking** | 5-step workflow: `vehicle_in` → `parked` → `out_request` → `ready_to_out` → `delivered` |
| 📡 **FASTag Simulation** | Simulated electronic toll-style entry/exit logging |
| 📱 **QR Code Scanning** | Scan vehicle tickets for quick lookup and processing |
| 📊 **Reports & Charts** | Revenue breakdowns, occupancy trends, and vehicle type analytics |
| 🏢 **Multi-Location Support** | Configure multiple parking lots from a single app |
| 🔐 **Role-Based Access** | Admin, Operator, and Valet roles with granular permissions |
| 📴 **100% Offline** | No backend, no API calls, no internet required — ever |

---

## 📸 Screenshots

> _Screenshots coming soon!_
>
> We're capturing polished device mockups of the Dashboard, Entry/Exit screens, Valet workflow, Pass management, and Reports. Stay tuned.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) 3.11.4+ |
| **Language** | [Dart](https://dart.dev/) 3.0+ |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Local Storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **QR Scanning** | [mobile_scanner](https://pub.dev/packages/mobile_scanner) |
| **Charts** | [fl_chart](https://pub.dev/packages/fl_chart) |
| **QR Generation** | [qr_flutter](https://pub.dev/packages/qr_flutter) |
| **Icons** | [iconsax](https://pub.dev/packages/iconsax) |
| **Animations** | [lottie](https://pub.dev/packages/lottie) |

---

## 🏗 Architecture

ParkVault follows a clean **Provider + SharedPreferences** pattern:

```
┌─────────────────────────────────────────────────┐
│                   UI Layer                       │
│  (Screens → context.watch / context.read)        │
├─────────────────────────────────────────────────┤
│                Provider Layer                    │
│  AuthProvider · ParkingProvider · PassProvider   │
│  ValetProvider · SettingsProvider                │
├─────────────────────────────────────────────────┤
│                Service Layer                     │
│  AuthService · ParkingService · PassService      │
│  ValetService · ReportService · SettingsService  │
├─────────────────────────────────────────────────┤
│              Storage Layer                       │
│         LocalStorageService (SharedPreferences)  │
│         JSON-encoded lists → disk               │
└─────────────────────────────────────────────────┘
```

**Key design decisions:**

- Providers are wired in `main.dart` via `MultiProvider`
- Services are thin wrappers over `LocalStorageService`
- All models implement `fromJson`/`toJson` for serialization
- Vehicle numbers stored uppercase, ticket IDs auto-generated with configurable prefix

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.11.4 or higher
- **Dart SDK** 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- A connected Android device or emulator

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-org/parkvault.git
cd parkvault

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split per ABI (smaller files)
flutter build apk --split-per-abi
```

---

## 🔄 How It Works

### First-Run Flow

```
Splash Screen → Setup Screen (create admin) → Login Screen → Dashboard
```

On subsequent launches, the app auto-logs in the last user and jumps straight to the Dashboard.

### Entry Screen

1. Select vehicle type (Car, Bike, Truck, SUV, Taxi, Bus, Mini Bus)
2. Enter vehicle number (auto-uppercased)
3. System checks for active pass — if valid, fee = ₹0
4. Ticket generated with unique ID (e.g., `SP-0001`)
5. QR code displayed for the ticket

### Exit Screen

1. Scan QR or manually enter ticket ID
2. System calculates duration and fee based on vehicle rate
3. Active pass holders exit free
4. Payment recorded, ticket closed

### Pass Management

- Create passes with type, vehicle number, validity dates
- Types: `Monthly`, `Weekly`, `VIP`, `Staff`
- Active passes auto-apply zero fees during entry/exit
- Expiry tracking with visual indicators

### Valet Workflow

```
vehicle_in → parked → out_request → ready_to_out → delivered
```

Each transition is tracked with timestamps and OTP verification for security.

### Reports

- Revenue by day/week/month
- Vehicle type distribution (pie chart)
- Occupancy trends (line chart)
- Pass utilization stats
- Export-ready data views

### Settings

- Configure parking lot name, ticket prefix, vehicle rates
- Manage users and roles
- Add/remove parking locations
- Reset all data (with confirmation)

---

## 👥 User Roles

| Role | Entry/Exit | Passes | Valet | History | Reports | Settings |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Admin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Operator** | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Valet** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |

---

## 📐 Business Rules

| Rule | Detail |
|---|---|
| **Ticket IDs** | Auto-generated: `{prefix}-{sequence}` (default `SP-0001`) |
| **Vehicle Numbers** | Always stored uppercase |
| **Fee Calculation** | Active valid pass → fee = 0; otherwise → configured vehicle rate × duration |
| **OTP** | Random 6-digit string generated for valet task verification |
| **Pass Validity** | Checked against current date at entry/exit time |
| **Data Persistence** | All data survives app restarts via SharedPreferences |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point, MultiProvider setup
├── constants/
│   ├── colors.dart              # App color palette
│   ├── strings.dart             # String constants
│   └── storage_keys.dart        # SharedPreferences keys
├── models/                      # 7 data models (fromJson/toJson)
│   ├── user.dart
│   ├── vehicle.dart
│   ├── ticket.dart
│   ├── pass.dart
│   ├── valet_task.dart
│   ├── fastag_record.dart
│   └── parking_location.dart
├── services/                    # Thin wrappers over LocalStorageService
│   ├── local_storage_service.dart
│   ├── auth_service.dart
│   ├── parking_service.dart
│   ├── pass_service.dart
│   ├── valet_service.dart
│   ├── fastag_service.dart
│   ├── report_service.dart
│   └── settings_service.dart
├── providers/                   # 5 ChangeNotifiers
│   ├── auth_provider.dart
│   ├── parking_provider.dart
│   ├── pass_provider.dart
│   ├── valet_provider.dart
│   └── settings_provider.dart
├── screens/                     # 18 screens
│   ├── splash_screen.dart
│   ├── setup_screen.dart
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── entry_screen.dart
│   ├── exit_screen.dart
│   ├── pass_screen.dart
│   ├── valet_screen.dart
│   ├── reports_screen.dart
│   ├── settings_screen.dart
│   └── ...
└── utils/
    ├── validators.dart          # Input validation helpers
    └── date_utils.dart          # Date formatting utilities
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management |
| `shared_preferences` | ^2.2.2 | Local data persistence |
| `mobile_scanner` | ^4.0.0 | QR code scanning |
| `qr_flutter` | ^4.1.0 | QR code generation |
| `fl_chart` | ^0.66.0 | Charts and graphs |
| `iconsax` | ^0.0.8 | Modern icon set |
| `lottie` | ^3.1.0 | JSON animations |
| `intl` | ^0.19.0 | Date/time formatting |
| `uuid` | ^4.3.3 | Unique ID generation |

---

## 🗺 Roadmap

- [ ] PDF ticket export & printing
- [ ] Multi-language support (i18n)
- [ ] Dark mode toggle
- [ ] Cloud sync option (optional Firebase backend)
- [ ] License plate recognition (ML Kit)
- [ ] Real-time occupancy dashboard
- [ ] Web admin panel
- [ ] Automated pass renewal reminders

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ using Flutter**

*No servers. No APIs. Just parking, perfected.*

</div>
