# HandConnect ✋🎨

HandConnect is a cutting-edge Flutter application that allows users to paint and draw on their screens using real-time hand gesture tracking. By leveraging high-performance on-device machine learning (TensorFlow Lite), HandConnect maps your finger movements directly to canvas strokes, creating a magical, touch-free drawing experience.

![HandConnect UI Concept](https://img.shields.io/badge/UI-Glassmorphic-neonCyan)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Web%20%7C%20Mobile-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)

## ✨ Features

- **Real-Time Hand Tracking**: Uses a device's camera to precisely track hand landmarks in real-time.
- **Gesture-Based Controls**: 
  - Extend your index finger to draw.
  - Retract your finger to pause drawing and move your hand freely.
- **Touch Fallback**: Seamlessly supports traditional mouse and touch inputs for high-precision drawing.
- **Smart Shape Recognition**: Automatically recognizes and perfectly snaps basic geometric shapes (Lines, Circles, Rectangles).
- **Stunning Aesthetics**: Built with a modern, dark-themed "Glassmorphic" UI with glowing neon strokes.
- **Export to Gallery**: Save your glowing creations directly to your device's storage/gallery with a single click.

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: Make sure you have the latest Flutter SDK installed on your machine.
- **Camera Access**: Ensure your device has a working webcam or front-facing camera.

### Installation

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/vishwakarthick1789/HandConnect.git
   cd HandConnect
   ```

2. Fetch the Flutter dependencies:
   ```bash
   flutter pub get
   ```

## 🎮 How to Run this

### Windows (Automated Script)
For the easiest setup on Windows, simply double-click the included batch script:
- **`start.bat`**: This script will automatically fetch any missing packages and launch the app natively on your desktop.

### Manual Run (All Platforms)
To run the app manually from your terminal, execute:
```bash
flutter run
```
*(Note: If prompted, grant the application permission to access your camera).*

## 📖 Usage Guide

### 1. Starting a Session
Launch the app and click the **"Start Drawing"** glass card on the Home Screen. The app will initialize your camera and begin tracking.

### 2. Drawing Mechanics
- **Using the Camera**: Hold your hand up to the camera. Point your index finger out to begin drawing on the virtual canvas. Close your finger (like a loose fist or bringing the finger down) to pause the stroke and move the cursor without drawing.
- **Using Touch/Mouse**: You can also simply click and drag across the screen to draw.

### 3. Smart Shapes
If you draw a rough circle, a rectangle, or a straight line, HandConnect will auto-detect the shape once you finish the stroke and perfectly snap it into place!

### 4. Toolbar Controls
- **Color Picker**: Use the floating glass toolbar at the bottom to switch between glowing neon colors.
- **Clear Canvas**: Tap the trash can icon (`🗑️`) on the bottom left to wipe the canvas clean.
- **Save Drawing**: Tap the save icon (`💾`) on the bottom right. 
  - On Windows, this saves the image directly to your `Downloads` folder.
  - On Mobile, it saves straight to your Photos/Gallery.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Machine Learning**: TensorFlow Lite (`tflite_flutter`) for localized, high-speed hand landmark detection.
- **UI Architecture**: Custom painters with mask filters for neon glows, integrated over live camera previews.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/vishwakarthick1789/HandConnect/issues).

---
*Built to make digital creation feel like a magic.*
