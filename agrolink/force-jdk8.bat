@echo off
echo Attempting to use JDK 8 for compatibility...

REM Check common JDK 8 installation paths
set "JDK_FOUND=0"

if exist "C:\Program Files\Java\jdk1.8.0_291" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_291"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_281" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_281"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_261" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_261"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_251" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_251"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_241" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_241"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_231" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_231"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_221" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_221"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_211" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_211"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_202" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_202"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_192" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_192"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_181" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_181"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_171" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_171"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_161" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_161"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_151" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_151"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_144" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_144"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_131" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_131"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_121" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_121"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_111" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_111"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_101" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_101"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_91" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_91"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_77" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_77"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_74" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_74"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_73" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_73"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_72" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_72"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_71" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_71"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_66" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_66"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_65" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_65"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_60" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_60"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_51" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_51"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_45" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_45"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_40" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_40"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_31" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_31"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_25" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_25"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_20" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_20"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_11" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_11"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0_05" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0_05"
    set "JDK_FOUND=1"
) else if exist "C:\Program Files\Java\jdk1.8.0" (
    set "JAVA_HOME=C:\Program Files\Java\jdk1.8.0"
    set "JDK_FOUND=1"
)

if "%JDK_FOUND%"=="0" (
    echo No JDK 8 installation found.
    echo Please download and install JDK 8...
    start https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html
    echo After installing JDK 8, please run this script again.
    exit /b 1
)

echo Found JDK 8: %JAVA_HOME%
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo Current Java version:
java -version
echo.
exit /b 0
