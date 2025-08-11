# Firebase Configuration Setup

This project uses Firebase for backend services. To set up Firebase configuration files:

## Setup Instructions

### Option 1: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run the configuration command:
   ```bash
   flutterfire configure
   ```

3. Follow the prompts to select your Firebase project and platforms.

### Option 2: Manual Setup

1. Copy the template file:
   ```bash
   cp lib/firebase_options.dart.template lib/firebase_options.dart
   ```

2. Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:
   - `YOUR_WEB_API_KEY`
   - `YOUR_WEB_APP_ID`
   - `YOUR_ANDROID_API_KEY`
   - `YOUR_ANDROID_APP_ID`
   - `YOUR_IOS_API_KEY`
   - `YOUR_IOS_APP_ID`
   - `YOUR_MESSAGING_SENDER_ID`
   - `YOUR_PROJECT_ID`
   - `YOUR_MEASUREMENT_ID`

3. For Android, also add your `google-services.json` file to `android/app/`

4. For iOS, add your `GoogleService-Info.plist` file to `ios/Runner/`

## Security Notes

- Never commit `firebase_options.dart`, `google-services.json`, or `GoogleService-Info.plist` to version control
- These files contain sensitive API keys and should be kept private
- Each developer should configure their own Firebase project or get these files from a secure source

## Firebase Project Configuration

Your Firebase project should have the following services enabled:
- Authentication
- Cloud Firestore
- Cloud Storage
- (Add other services as needed)

Make sure to configure proper security rules for your Firebase services in the Firebase Console.
