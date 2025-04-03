@echo off
echo Checking Java installation...

echo.
echo Current Java version:
java -version 2>&1

echo.
echo Available Java installations:
where java 2>nul || echo Java not found in PATH

echo.
echo Current JAVA_HOME:
echo %JAVA_HOME%

echo.
echo ========================================
echo Java/Gradle Compatibility Information
echo ========================================
echo Flutter Android builds require specific Java-Gradle compatibility:
echo.
echo JDK 8 (1.8): Use Gradle 2.0 to 5.0 (recommended: 4.10.2)
echo JDK 11:      Use Gradle 5.0 to 7.0 (recommended: 6.7.1)
echo JDK 17:      Use Gradle 7.3+ (recommended: 7.4)
echo JDK 21/22:   Use Gradle 8.4+ (not recommended for Flutter yet)
echo.
echo This project has been configured for JDK 8 with Gradle 4.10.2
echo.
echo RECOMMENDED SETUP:
echo 1. Install AdoptOpenJDK 8 using the 'install-adoptopenjdk8.bat' script
echo 2. Run the 'downgrade-java-gradle.bat' script to set up a compatible environment
echo.
pause
