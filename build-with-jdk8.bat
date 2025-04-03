@echo off
echo ================================================
echo SPECIAL BUILD SCRIPT USING JDK 8 FOR COMPATIBILITY
echo ================================================
echo.

call force-jdk8.bat
if %ERRORLEVEL% NEQ 0 (
  echo Failed to find JDK 8. Please install it and try again.
  pause
  exit /b 1
)

echo Cleaning project and caches...
flutter clean
rd /s /q %USERPROFILE%\.gradle\caches\
rd /s /q %USERPROFILE%\.gradle\daemon\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-6.7.1-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.3.3-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.5-all\

echo Updating Gradle wrapper to version 6.7.1...
cd android
call gradlew wrapper --gradle-version 6.7.1 --distribution-type all
cd ..

echo Getting packages...
flutter pub get

echo Running Flutter build with JDK 8...
flutter run

echo Done!
pause
