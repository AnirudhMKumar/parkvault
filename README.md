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

## ✨ Key Features

| | |
|---|---|
| 🎫 **Auto Ticket Generation** | Vehicle entry/exit with unique ticket IDs, timestamps, and fee calculation. |
| 📸 **Vehicle Capture** | Built-in camera feature to securely log vehicle pictures upon entry! |
| 🪪 **Pass Management** | Monthly, Weekly, VIP & Staff passes with validity tracking. |
| 🧑‍💼 **Valet Parking** | 5-step workflow: `vehicle_in` → `parked` → `out_request` → `ready_to_out` → `delivered`. |
| 📡 **FASTag Simulation** | Simulated electronic toll-style entry/exit logging. |
| 📱 **QR Code Scanning** | Scan vehicle tickets for quick lookup and processing. |
| 📊 **Reports & Charts** | Revenue breakdowns, occupancy trends, and vehicle type analytics. |
| 🏢 **Multi-Location Support** | Configure multiple parking lots from a single app. |
| 🔐 **Self-Registration & Roles** | Built-in user, operator & valet onboarding securely linked to a company code. |
| 📴 **100% Offline** | No backend, no API calls, no internet required — ever. |
| 🎨 **Premium Aesthetic** | Stunning dark navy design with smooth, glowing effects globally. |

---

## 📸 Screenshots

> _Screenshots coming soon!_
>
> We're capturing polished device mockups of the Dashboard, Entry/Exit screens, Valet workflow, Pass management, and Reports.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) 3.11.4+ |
| **Language** | [Dart](https://dart.dev/) 3.0+ |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Local Storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **QR Library** | [mobile_scanner](https://pub.dev/packages/mobile_scanner) & qr_flutter |
| **Photo / Camera** | [image_picker](https://pub.dev/packages/image_picker) |
| **Launcher Icon** | [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) |
| **Charts** | [fl_chart](https://pub.dev/packages/fl_chart) |
| **Icons & Style** | iconsax & lottie |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.11.4 or higher
- **Dart SDK** 3.0 or higher
- iOS Simulator, connected Android device or Windows Desktop.

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/AnirudhMKumar/parkvault.git
cd parkvault

# 2. Install dependencies
flutter pub get

# 3. Generate the launcher icons
flutter pub run flutter_launcher_icons

# 4. Run the app
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## 🔄 How It Works

### First-Run & Accounts

```
Splash Screen → Setup Screen (create admin & set master configurations) → Login & Self Registration
```
Anyone with the master **Company Code** can register themselves as an Operator or a Valet via the app.

### Entry Screen 

1. Select vehicle type (Car, Bike, Truck, SUV, Taxi, etc).
2. Enter vehicle number. 
3. (Optional) Capture a vehicle photo using the device camera.
4. System checks for active passes — applies ₹0 automatically based on real-time pass validity rules!
5. Auto-computes tickets based on customizable per-vehicle fees or hourly global defaults.

### Exit Screen

1. Scan QR or manually enter ticket ID.
2. System calculates duration and complex fees dynamically.
3. Payment is securely recorded offline.

### Reports & Valets

- Beautiful graphs showing daily revenue, fastag stats, and entries!
- Dedicated valet screens simulating key flow management efficiently!

---

## 📐 Business Rules

| Rule | Detail |
|---|---|
| **Ticket IDs** | Auto-generated: `{prefix}-{sequence}` (default `SP-0001`) |
| **Vehicle Numbers** | Always stored uppercase |
| **Fee Calculation** | Pass holders = 0; else applies base vehicle fees + extra hour logic! |
| **OTP** | Random 6-digit string generated for valet task verification |
| **Data Persistence** | SharedPreferences automatically loads upon boot. |

---

## 📦 File Layout Highlights

```
lib/
├── main.dart                    # App Entry
├── models/                      # 7 decoupled serialized models
├── services/                    # Local storage wrappers & persistence logic
├── providers/                   # Core ChangeNotifiers driving state
├── screens/                     # Views & Logic integration
└── utils/                       # Date Formatters & Form validators
```

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ using Flutter**

*No servers. No APIs. Just parking, perfected.*

</div>
