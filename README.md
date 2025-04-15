# Flutter Gemma Chat App

A Flutter application that demonstrates how to integrate local LLMs using the flutter_gemma package.

## Setup Instructions

### 1. Install Dependencies

Run `flutter pub get` to install all the dependencies.

### 2. Get a Gemma Model

To use this app with a real Gemma model, you need to:

1. Download a pre-trained Gemma model from [Kaggle](https://kaggle.com/models)
   - Recommended: Gemma 2B or 2B-IT for mobile devices
   - Place the model file in the `assets/models` directory for debug mode
   - For production, use the download functionality to fetch the model from a server

### 3. Platform-Specific Setup

#### iOS
- The app is already configured with:
  - File sharing enabled in Info.plist
  - Static linking for pods in Podfile

#### Android
- The app is already configured with OpenGL support in AndroidManifest.xml

#### Web
- The app is already configured with Mediapipe dependencies in index.html

### 4. Using the App

1. Launch the app
2. The app will check if a model is installed
3. If not, you'll need to download it (this demo simulates the download process)
4. Once a model is loaded, you can start chatting with the local LLM

## Model Information

- For mobile devices, smaller models like Gemma 2B or Phi-2 are recommended
- For best performance, use quantized models designed for mobile deployment
- Models are stored locally after download and don't need to be re-downloaded on each app launch

## Supported Models

- Gemma 2B & 7B
- Gemma-2 2B
- Gemma-3 1B (Android and Web only)
- Phi-2, Phi-3, Phi-4 (Phi-4 only on Android and Web)
- DeepSeek (Android and Web only)
- Falcon-RW-1B
- StableLM-3B

## Notes

- This demo app includes a simulated LLM response when no model is available
- In a production environment, you would host the model files on a server and implement proper model download/management
- The flutter_gemma plugin provides methods for both asset loading (debug) and network downloading (production)

## Learn More

For more information, visit [flutter_gemma on pub.dev](https://pub.dev/packages/flutter_gemma).
