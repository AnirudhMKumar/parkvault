# ParkVault Installation & Handover Guide

Welcome! You have been granted the source code to **Smart Parking Pro (ParkVault)** — a fully offline-capable mobile application boasting an intelligent, cloud-hosted Computer Vision (AI) backend that auto-extracts vehicle license plates.

Because this project utilizes a separated architecture (Flutter for the frontend App, Python for the AI), you will need to set up two distinct components to make this project uniquely yours.

---

## Part 1: Setting up the AI Server (The Backend)
The AI server is completely serverless and runs explicitly on the internet. It was built using Python, FastAPI, PyTorch, and EasyOCR. You will re-host it on your own free cloud account.

### 1. Create a Hugging Face Account
1. Go to [HuggingFace.co](https://huggingface.co/) and sign up for a free account.
2. Once logged in, click your Profile Picture (top right) and select **New Space**.
3. Name your space (e.g. `parking-ai-engine`).
4. Select **Docker** as the Space SDK.
5. In the "Space Hardware" section, ensure the Free Compute tier is selected.
6. Click **Create Space**.

### 2. Upload the Code
You will now see a repository page.
1. Click the **Files** tab at the top.
2. Click **+ Add file** -> **Upload files**.
3. Find your localized `backend/` folder from this source code. Drag and drop **these three exact files** into your browser window:
   - `main.py`
   - `requirements.txt`
   - `Dockerfile`
4. Click **Commit changes to main**.

### 3. Retrieve Your New AI Link
1. Click the **App** tab. The server will display "Building". Wait 3-4 minutes as it compiles your virtual machine.
2. Once the status shows **Running**, click the three little dots (`...`) in the absolute top right corner of the application view.
3. Select **Embed this space**.
4. You will see a "Direct URL" link (it usually looks like `https://yourusername-parking-ai-engine.hf.space`).
5. **Copy this URL!** You will need it for the Mobile App.

---

## Part 2: Building the Mobile App (The Frontend)
The frontend is built via **Flutter**. When the camera activates in the app, it instantly fires the image over the network to the URL you just generated!

### 1. Install Flutter
1. If you haven't already, download and install the Flutter SDK: [Flutter Setup Guide](https://docs.flutter.dev/get-started/install).
2. Install Android Studio (for the Android emulator and SDK tools).
3. Connect your personal Android phone via USB, or launch an Emulator.

### 2. Link the App to Your New AI Cloud
1. Open the Flutter project (`sps_app/`) in your code editor (like VS Code or Android Studio).
2. Open the file located at: `lib/screens/entry_screen.dart`.
3. Scroll down (around line `60`) and look for the `_analyzeImage` function.
4. Replace the old existing Hugging Face URL with the brand new Direct URL you generated in Part 1 Step 3!

```dart
// Change this line...
final uri = Uri.parse('https://zenor20-parkvault-ai.hf.space/detect-plate');

// ...To match YOUR exact Space URL!
final uri = Uri.parse('https://YOUR-URL.hf.space/detect-plate');
```

### 3. Run the App
1. Open your terminal, navigate to the `sps_app` directory, and run the following command to download all dependencies:
   ```bash
   flutter pub get
   ```
2. Once finished, hit:
   ```bash
   flutter run
   ```

### 🎉 You are Done!
Your app will compile and install onto your device. 
When an operator logs in and snaps a photo of an incoming vehicle, the image shoots to your personal Hugging Face Cloud, extracts the text, and routes it directly into the mobile text field!

> **Note on Data Storage:** This application intentionally runs on `SharedPreferences` (Internal Phone Storage). If you delete the app from your phone, the data resets. It requires absolutely no Database maintenance!
