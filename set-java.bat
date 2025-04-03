@echo off
echo Setting temporary Java environment...

if exist "C:\Program Files\Java\jdk-11" (
  set "JAVA_HOME=C:\Program Files\Java\jdk-11"
  echo Set JAVA_HOME to JDK 11
) else if exist "C:\Program Files\Java\jdk-17" (
  set "JAVA_HOME=C:\Program Files\Java\jdk-17"
  echo Set JAVA_HOME to JDK 17
) else if exist "C:\Program Files\Java\jdk1.8.0_281" (
  set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_281"
  echo Set JAVA_HOME to JDK 8
) else (
  echo No compatible JDK found. Please install JDK 11.
  echo Running download script...
  call download-jdk.bat
  exit /b 1
)

set "PATH=%JAVA_HOME%\bin;%PATH%"
echo Temporarily added Java to PATH

echo Current Java version:
java -version
echo.

echo If you want to make this permanent, set JAVA_HOME in your system environment variables.
echo.
