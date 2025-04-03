@echo off
echo ====================================
echo Flutter Project EMERGENCY FIX SCRIPT
echo ====================================
echo.
echo This script will attempt to fix all known issues with the project.
echo It may take several minutes to complete.
echo.
echo Press any key to continue or CTRL+C to cancel...
pause > nul

echo Step 1: Checking Java installation...
call check-java.bat

echo Step 2: Checking for JDK 11 or compatible version...
if not exist "C:\Program Files\Java\jdk-11" (
  if not exist "C:\Program Files\Java\jdk-17" (
    echo No compatible JDK found. Please install JDK 11...
    call download-jdk.bat
    echo After installing JDK 11, please run this script again.
    pause
    exit /b 1
  )
)

echo Step 3: Cleaning up cache and temporary files...
echo Cleaning Flutter...
flutter clean
echo Cleaning Pub cache...
flutter pub cache clean
echo Cleaning Gradle caches...
rd /s /q %USERPROFILE%\.gradle\caches\
rd /s /q %USERPROFILE%\.gradle\daemon\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.3.3-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.5-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-8.0-all\

echo Step 4: Fixing Android toolchain...
call flutter_jdk_fix.bat

echo Step 5: Getting all dependencies...
flutter pub upgrade --major-versions
flutter pub get

echo Step 6: Checking Flutter configuration...
flutter config --no-analytics
flutter doctor -v

echo All steps completed! Try running the app now with: flutter run
pause
