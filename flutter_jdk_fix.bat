@echo off
echo Fixing Flutter JDK environment...

echo Removing potentially incompatible Flutter build caches...
rd /s /q %USERPROFILE%\AppData\Local\Pub\Cache\.pub-cache
rd /s /q %USERPROFILE%\.pub-cache

echo Setting up Java environment...
call set-java.bat
if %ERRORLEVEL% NEQ 0 (
  echo Failed to set up Java environment. Exiting.
  exit /b 1
)

echo Reconfiguring Flutter Android toolchain...
flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"
flutter config --android-sdk=%LOCALAPPDATA%\Android\sdk
flutter doctor --android-licenses

echo Cleaning project and upgrading dependencies...
flutter clean
flutter pub upgrade
flutter pub get

echo Checking Flutter doctor...
flutter doctor -v

echo Done. Your Flutter environment has been reconfigured.
echo You should now be able to build the project with: flutter run
pause
