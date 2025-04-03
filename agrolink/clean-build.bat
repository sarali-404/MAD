@echo off
echo Setting up Java environment...
call set-java.bat
if %ERRORLEVEL% NEQ 0 (
  echo Failed to set up Java environment. Exiting.
  exit /b 1
)

echo Cleaning Flutter project...
flutter clean

echo Removing Gradle caches...
rd /s /q %USERPROFILE%\.gradle\caches\
rd /s /q %USERPROFILE%\.gradle\daemon\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.3.3-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.5-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-8.0-all\

echo Updating Gradle wrapper...
call update-gradle.bat

echo Getting packages...
flutter pub get

echo Running Flutter doctor...
flutter doctor -v

echo Building again...
flutter run

echo Done!
