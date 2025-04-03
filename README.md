# Farming App

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Development Setup

### Java Development Kit (JDK) Requirements

This project requires JDK 11 or JDK 17 for compatibility with Flutter and Gradle.

#### Install JDK:
1. Download JDK 11 from [Oracle](https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html) or [AdoptOpenJDK](https://adoptium.net/)
   OR
   Download JDK 17 from [Oracle](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) or [AdoptOpenJDK](https://adoptium.net/)

2. Set JAVA_HOME environment variable:
   - Right-click on "This PC" or "My Computer" → Properties → Advanced system settings → Environment Variables
   - Add or update the JAVA_HOME variable to point to your JDK installation folder
   - Add `%JAVA_HOME%\bin` to your PATH variable

3. Verify installation by running `check-java.bat` or using the command `java -version`

#### Building the app:
After setting up JDK, run these commands:
```
flutter clean
flutter pub get
flutter run
```

If you encounter build issues, try running the `clean-build.bat` script.

## Troubleshooting Build Issues

If you encounter Gradle or JDK version compatibility issues:

1. Make sure you have JDK 11 or JDK 17 installed (not JDK 21 or 22)

2. Update your `gradle.properties` file to point to JDK 11 or JDK 17:
   ```
   org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
   ```

3. Run the included `update-gradle.bat` script to update the Gradle wrapper

4. Run the included `clean-build.bat` script which will:
   - Clean the Flutter project
   - Clear Gradle caches
   - Update the Gradle wrapper
   - Get Flutter packages
   - Rebuild the project

### Common Errors and Solutions

1. **Unsupported class file major version 65/66**:
   This means you're using a too-new JDK. Install JDK 11 or JDK 17 and configure gradle.properties.

2. **Could not open cp_settings generic class cache**:
   Run the clean-build script to clean Gradle caches and update the wrapper.

3. **Failed to transform core-for-system-modules.jar**:
   Make sure you're using a compatible JDK version (JDK 11 or JDK 17).

4. **Value given for org.gradle.java.home Gradle property is invalid**:
   - Make sure JDK 11 or 17 is installed
   - Set JAVA_HOME environment variable correctly
   - Run `check-java.bat` to verify your Java installation
