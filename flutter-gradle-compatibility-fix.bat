@echo off
echo ================================================
echo   FLUTTER-GRADLE-JDK COMPATIBILITY FIX SCRIPT
echo ================================================
echo.

echo Checking Flutter's Java version...
call check-flutter-java.bat

echo.
echo IMPORTANT: Based on the Flutter compatibility requirements, 
echo we need to use an older version of Gradle (5.6.4) with Java 8.
echo.

echo Is Java 8 installed on your system?
echo 1. Yes, I have Java 8 installed
echo 2. No, I need to install Java 8
echo.
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="2" (
    echo Installing Java 8...
    call install-adoptopenjdk8.bat
)

echo Setting up Java 8 for this session...
call force-jdk8.bat
if %ERRORLEVEL% NEQ 0 (
    echo Could not set up Java 8. Please run the install-adoptopenjdk8.bat script.
    pause
    exit /b 1
)

echo.
echo Updating Gradle wrapper to version 5.6.4...
echo distributionBase=GRADLE_USER_HOME > android\gradle\wrapper\gradle-wrapper.properties
echo distributionPath=wrapper/dists >> android\gradle\wrapper\gradle-wrapper.properties
echo zipStoreBase=GRADLE_USER_HOME >> android\gradle\wrapper\gradle-wrapper.properties
echo zipStorePath=wrapper/dists >> android\gradle\wrapper\gradle-wrapper.properties
echo distributionUrl=https\://services.gradle.org/distributions/gradle-5.6.4-all.zip >> android\gradle\wrapper\gradle-wrapper.properties

echo.
echo Updating build.gradle files for compatibility...
echo Updating android\build.gradle to use older plugin versions...
type nul > android\build.gradle.new
echo buildscript { >> android\build.gradle.new
echo     ext.kotlin_version = '1.3.50' >> android\build.gradle.new
echo     repositories { >> android\build.gradle.new
echo         google() >> android\build.gradle.new
echo         mavenCentral() >> android\build.gradle.new
echo     } >> android\build.gradle.new
echo     dependencies { >> android\build.gradle.new
echo         classpath 'com.android.tools.build:gradle:3.5.4' >> android\build.gradle.new
echo         classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version" >> android\build.gradle.new
echo         classpath 'com.google.gms:google-services:4.3.3' >> android\build.gradle.new
echo     } >> android\build.gradle.new
echo } >> android\build.gradle.new
echo. >> android\build.gradle.new
echo allprojects { >> android\build.gradle.new
echo     repositories { >> android\build.gradle.new
echo         google() >> android\build.gradle.new
echo         mavenCentral() >> android\build.gradle.new
echo     } >> android\build.gradle.new
echo } >> android\build.gradle.new
echo. >> android\build.gradle.new
echo apply from: "$rootDir/compatibility.gradle" >> android\build.gradle.new
echo. >> android\build.gradle.new
echo rootProject.buildDir = "../build" >> android\build.gradle.new
echo subprojects { >> android\build.gradle.new
echo     project.buildDir = "${rootProject.buildDir}/${project.name}" >> android\build.gradle.new
echo } >> android\build.gradle.new
echo subprojects { >> android\build.gradle.new
echo     project.evaluationDependsOn(":app") >> android\build.gradle.new
echo } >> android\build.gradle.new
echo. >> android\build.gradle.new
echo task clean(type: Delete) { >> android\build.gradle.new
echo     delete rootProject.buildDir >> android\build.gradle.new
echo } >> android\build.gradle.new

move /y android\build.gradle.new android\build.gradle

echo.
echo Cleaning Flutter build cache...
flutter clean

echo.
echo Cleaning Gradle caches...
rd /s /q %USERPROFILE%\.gradle\caches\
rd /s /q %USERPROFILE%\.gradle\daemon\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-6.7.1-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.3.3-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-7.5-all\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-8.0-all\

echo.
echo Getting Flutter packages...
flutter pub get

echo.
echo Running Flutter doctor...
flutter doctor -v

echo.
echo All setup is complete! Try building your app now with:
echo flutter run
echo.
pause
