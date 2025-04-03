@echo off
echo This script will open the AdoptOpenJDK website to download JDK 11
echo which is compatible with this Flutter project.
echo.
echo Press any key to open the download page...
pause > nul

start https://adoptium.net/temurin/releases/?version=11

echo.
echo After downloading and installing JDK 11:
echo 1. Run "check-java.bat" to verify your installation
echo 2. Run "clean-build.bat" to rebuild the project
echo.
pause
