@echo off
echo ================================================
echo FLUTTER-COMPATIBLE JDK 8 INSTALLER
echo ================================================
echo.
echo This script will download and set up AdoptOpenJDK 8
echo which is compatible with the Gradle version we're using.
echo.
echo Press any key to continue...
pause > nul

mkdir "%TEMP%\jdk-install" 2>nul
cd /d "%TEMP%\jdk-install"

echo Downloading AdoptOpenJDK 8...
curl -L "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_windows_hotspot_8u292b10.msi" -o jdk8.msi

echo Installing AdoptOpenJDK 8...
start /wait msiexec /i jdk8.msi /quiet

echo Setting JAVA_HOME and updating PATH...
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-8.0.292.10-hotspot" /M
echo JAVA_HOME has been set. You may need to restart your command prompt.

echo.
echo Java 8 has been installed. Check the version below:
"C:\Program Files\Eclipse Adoptium\jdk-8.0.292.10-hotspot\bin\java" -version

echo.
echo Next steps:
echo 1. Close all command prompts and open a new one
echo 2. Run 'build-with-jdk8.bat' to build your Flutter project
echo.
pause
