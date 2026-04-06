<div align="center">
  
# 🅿️ ParkVault 🚙
  
**Next-Generation Offline-First Parking Management System**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Offline First](https://img.shields.io/badge/Architecture-Offline_First-2ea44f?style=for-the-badge)](#)
[![AI Powered](https://img.shields.io/badge/AI-Computer_Vision-8A2BE2?style=for-the-badge)](#)
[![State](https://img.shields.io/badge/State-Provider-orange?style=for-the-badge)](#)

*Manage unlimited vehicles, staff, and valet tasks locally, powered by a Cloud AI Engine for automated Plate Extraction.*

</div>

---

## 📖 Welcome to ParkVault

**ParkVault** is a production-ready, open-source Flutter application designed to solve complex parking lot logistics without relying on the cloud. 

If you are a **developer learning Flutter**, this repository serves as an excellent case study in:
- 📱 Building **Offline-First** applications using `SharedPreferences` for complex, nested data tracking.
- 🏗️ Utilizing **Provider** for clean, scalable state management without boilerplate.
- 🔑 Managing **Role-Based Access Control (RBAC)** completely on-device.
- 📸 Native hardware integration (Camera and Gallery via `image_picker`).

---

## ✨ Features at a Glance

| 🏎️ Vehicle Workflows | 👨‍💻 Management & Settings | 💼 Valet & Extras |
|:---|:---|:---|
| **Dynamic Ticketing:** Auto-ID generation (`SP-001`), timestamping, & cost projection. | **Multi-Role Login:** Admin, Operator, and Valet accounts securely verified on-device. | **Valet State Machine:** `In` → `Parked` → `Out Req` → `Ready` → `Delivered`. |
| **Pass Ecosystem:** Support for Monthly, Staff, and VIP passes that automatically waive calculation fees. | **Camera Capture:** Snap & save vehicle plates/conditions directly to local storage at entry! | **FASTag Simulation:** Virtual ledger to mimic high-speed electronic toll collection modes. |
| **Complex Pricing Trees:** Variable pricing by vehicle type (Bike, SUV, Minibus) × Duration tiers. | **Interactive Dashboards:** Real-time occupancy trackers and revenue visualizations (fl_chart). | **Dynamic Settings:** Read/Write configs for lot capacity, pricing algorithms & company codes. |

---

## 🧠 Educational Deep-Dive: How it Works

We built ParkVault to be robust yet simple to understand. Click the sections below to look under the hood!

<details>
<summary><b>1️⃣ 100% Offline Database Architecture</b></summary>
<br>

How do we query and store complex relationships (Users, Vehicles, Valet Tasks, Passes) without SQLite or Firebase? We built a strongly-typed generic wrapper around `SharedPreferences`.

Every `Service` uses our `LocalStorageService` to fetch JSON lists, hydrate them into Dart `Models`, and persist them back.

```dart
// Example: Persisting a Valet Task Offline
Future<ValetTaskModel> createTask({required String vehicleNumber}) async {
  // 1. Fetch current list from device disk
  final tasks = await _storage.getList(
    StorageKeys.valetTasks, 
    ValetTaskModel.fromJson,
  );
  
  // 2. Hydrate & Append
  final task = ValetTaskModel(
    taskId: 'VT${_uuid.v4()}', 
    vehicleNumber: vehicleNumber,
    status: 'vehicle_in'
  );
  tasks.add(task);
  
  // 3. Serialize and save back to disk instantly
  await _storage.setList(StorageKeys.valetTasks, tasks, (t) => t.toJson());
  return task;
}
```
</details>

<details>
<summary><b>2️⃣ Provider-Driven State Management</b></summary>
<br>

We utilize the `provider` package to decouple UI from Business Logic. The app is wrapped at the very top level inside a `MultiProvider`:

- `AuthProvider`: Manages the JWT/Session-equivalent local tokens.
- `SettingsProvider`: Notifies the app if global pricing or app rules change.
- `ParkingProvider` / `ValetProvider` / `PassProvider`: Domain-driven arrays broadcasting lists of vehicles to the UI safely.

By using `context.watch<ParkingProvider>()`, our dashboard pie-charts silently refresh the exact moment a car enters or leaves the premises!
</details>

<details>
<summary><b>3️⃣ Hardware: Local File Storage & Camera</b></summary>
<br>

To take vehicle pictures offline, we don't just use `image_picker`—we persist the images permanently to the device's application documents directory so they don't get wiped by the OS cache cleaner:

```dart
// Native hardware bridging!
final XFile? image = await _picker.pickImage(source: ImageSource.camera);

final appDir = await getApplicationDocumentsDirectory();
final savedImage = await File(image.path).copy('${appDir.path}/vehicle_$id.jpg');

// The UI later renders natively using Image.file()
```
</details>

---

<details>
<summary><b>4️⃣ AI Computer Vision Edge Server</b></summary>
<br>

The project features a decoupled **Python Backend API** hosted completely free on Hugging Face Spaces. When an operator snaps a photo of a vehicle, the Flutter app beams it directly over `http`.

The AI server utilizes **PyTorch** and **EasyOCR** to execute visual bounding boxes, concatenate fragmented license plate letters sequentially, and return a pristine Plate String seamlessly back to the mobile UI in milliseconds!
</details>

---

## 🚀 Quick Start Guide

### Prerequisites
You need [Flutter](https://docs.flutter.dev/get-started/install) installed (minimum `3.11.4`) and [Dart](https://dart.dev/get-dart) `3.0+`.

> **⚠️ Setting up the AI:** If you want to use the Computer Vision capabilities, you must host the provided `backend/` engine. Please read the full instructions in [handover_docs/SETUP_GUIDE.md](handover_docs/SETUP_GUIDE.md)!


### Zero to Running in 3 Steps
```bash
# 1. Clone the code locally
git clone https://github.com/AnirudhMKumar/parkvault.git
cd parkvault

# 2. Grab dependencies
flutter pub get

# 3. Launch the app (Emulator, Windows Desktop, or Physical Device!)
flutter run
```

> **💡 Pro Tip for First Run:** When you launch the app, you will be taken to the **Setup Screen**. The **Company Code** you create here acts as your master key. Operators and Valets *must* have this code to self-register via the app!

---

## 📸 Core Workflows

### 1. Registration & Login
- If the app is opened for the first time, an `Admin` is initialized.
- Afterwards, employees tap **"Register"**, enter the Admin's `Company Code`, and create secure local accounts.

### 2. Vehicle Entry
- Select a vehicle type.
- Enter Plate Number.
- **[Optional]** Capture the vehicle using the camera button (Saved offline natively).
- **[Automated]** If a 'Valid Pass' is detected matching that plate, the fee is set to 0 automatically.

### 3. Analytics & Settings
- Admins see total revenue parsed securely from the local JSON ledger.
- Custom adjustments can be made via the built-in **Settings Editor** (Change 2-Wheeler config, override base fee mapping!).

---

## 🛠 Tech Stack Overview

- **Framework:** Flutter (`3.11.4`)
- **State Logic:** `provider`
- **Persistence:** `shared_preferences`, `path_provider`
- **AI Core (Python):** `FastAPI`, `PyTorch`, `EasyOCR`
- **Sensors:** `image_picker`, `mobile_scanner` (for QR checking)
- **Data Viz:** `fl_chart`
- **Icon Generation:** `flutter_launcher_icons`

---

## 🤝 Want to contribute?

We love pull requests! If you're a developer and want to hone your Flutter skills, here are amazing features you could build:
- [ ] **PDF Exporting:** Add a button to generate printable receipts.
- [ ] **Dark Mode Toggle:** Implement a dynamic theme switcher based on `SettingsProvider`.
- [ ] **Cloud Syncing Optionality:** (Advanced) Create an abstract `FirebaseStorageService` to sync local data if the user toggles internet on.

Fork the repo, make a branch, and submit a PR! 

---

<div align="center">
<b>Developed with ❤️ to make parking smarter, greener, and entirely offline.</b>
<br><br>
<img src="https://img.shields.io/badge/Made%20for-Flutter%20Devs-02569B?style=flat-square&logo=flutter" />
</div>
