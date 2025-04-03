@echo off
echo Checking Flutter's Java version...
flutter doctor -v > flutter_info.txt
echo.
echo ==== Flutter Java Information ====
findstr /C:"Java version" flutter_info.txt
echo.
echo ==== Compatible Gradle Versions ====
echo Java 8 (1.8): Gradle 2.0 to 6.9
echo Java 11: Gradle 5.0 to 7.x
echo Java 17: Gradle 7.3+ to 8.x
echo Java 21: Gradle 8.4+
echo.
echo Your system Java version is:
java -version
echo.
pause
