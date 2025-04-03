@echo off
echo =============================================
echo FLUTTER GRADLE-JAVA EXTREME COMPATIBILITY FIX
echo =============================================
echo.
echo This script will:
echo 1. Install AdoptOpenJDK 8
echo 2. Configure Gradle 4.10.2 (known to work with JDK 8)
echo 3. Update build files for compatibility
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause > nul

echo Downloading and installing AdoptOpenJDK 8...
mkdir "%TEMP%\jdk-install" 2>nul
cd /d "%TEMP%\jdk-install"

echo Downloading AdoptOpenJDK 8...
curl -L "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_windows_hotspot_8u292b10.msi" -o jdk8.msi

echo Installing AdoptOpenJDK 8...
start /wait msiexec /i jdk8.msi /quiet

echo Setting up JDK 8 environment variable for this session...
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-8.0.292.10-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo Creating Java version file for verification...
java -version > java_version.txt 2>&1
type java_version.txt

cd /d "G:\run app 4 current - waiting\Farmingapp\Farmingapp"

echo Updating Gradle wrapper to version 4.10.2...
echo distributionBase=GRADLE_USER_HOME > android\gradle\wrapper\gradle-wrapper.properties
echo distributionPath=wrapper/dists >> android\gradle\wrapper\gradle-wrapper.properties
echo zipStoreBase=GRADLE_USER_HOME >> android\gradle\wrapper\gradle-wrapper.properties
echo zipStorePath=wrapper/dists >> android\gradle\wrapper\gradle-wrapper.properties
echo distributionUrl=https\://services.gradle.org/distributions/gradle-4.10.2-all.zip >> android\gradle\wrapper\gradle-wrapper.properties

echo Updating build.gradle to use compatible plugin versions...
echo buildscript { > android\build.gradle
echo     ext.kotlin_version = '1.3.50' >> android\build.gradle
echo     repositories { >> android\build.gradle
echo         google() >> android\build.gradle
echo         jcenter() >> android\build.gradle
echo     } >> android\build.gradle
echo     dependencies { >> android\build.gradle
echo         classpath 'com.android.tools.build:gradle:3.3.0' >> android\build.gradle
echo         classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version" >> android\build.gradle
echo         classpath 'com.google.gms:google-services:4.2.0' >> android\build.gradle
echo     } >> android\build.gradle
echo } >> android\build.gradle
echo. >> android\build.gradle
echo allprojects { >> android\build.gradle
echo     repositories { >> android\build.gradle
echo         google() >> android\build.gradle
echo         jcenter() >> android\build.gradle
echo     } >> android\build.gradle
echo } >> android\build.gradle
echo. >> android\build.gradle
echo rootProject.buildDir = '../build' >> android\build.gradle
echo subprojects { >> android\build.gradle
echo     project.buildDir = "${rootProject.buildDir}/${project.name}" >> android\build.gradle
echo } >> android\build.gradle
echo subprojects { >> android\build.gradle
echo     project.evaluationDependsOn(':app') >> android\build.gradle
echo } >> android\build.gradle
echo. >> android\build.gradle
echo task clean(type: Delete) { >> android\build.gradle
echo     delete rootProject.buildDir >> android\build.gradle
echo } >> android\build.gradle

echo Updating app/build.gradle for compatibility...
type nul > android\app\build.gradle
echo def localProperties = new Properties() >> android\app\build.gradle
echo def localPropertiesFile = rootProject.file('local.properties') >> android\app\build.gradle
echo if (localPropertiesFile.exists()) { >> android\app\build.gradle
echo     localPropertiesFile.withReader('UTF-8') { reader -^> >> android\app\build.gradle
echo         localProperties.load(reader) >> android\app\build.gradle
echo     } >> android\app\build.gradle
echo } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo def flutterRoot = localProperties.getProperty('flutter.sdk') >> android\app\build.gradle
echo if (flutterRoot == null) { >> android\app\build.gradle
echo     throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.") >> android\app\build.gradle
echo } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo def flutterVersionCode = localProperties.getProperty('flutter.versionCode') >> android\app\build.gradle
echo if (flutterVersionCode == null) { >> android\app\build.gradle
echo     flutterVersionCode = '1' >> android\app\build.gradle
echo } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo def flutterVersionName = localProperties.getProperty('flutter.versionName') >> android\app\build.gradle
echo if (flutterVersionName == null) { >> android\app\build.gradle
echo     flutterVersionName = '1.0' >> android\app\build.gradle
echo } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo apply plugin: 'com.android.application' >> android\app\build.gradle
echo apply plugin: 'kotlin-android' >> android\app\build.gradle
echo apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle" >> android\app\build.gradle
echo apply plugin: 'com.google.gms.google-services' >> android\app\build.gradle
echo. >> android\app\build.gradle
echo android { >> android\app\build.gradle
echo     compileSdkVersion 28 >> android\app\build.gradle
echo. >> android\app\build.gradle
echo     compileOptions { >> android\app\build.gradle
echo         sourceCompatibility JavaVersion.VERSION_1_8 >> android\app\build.gradle
echo         targetCompatibility JavaVersion.VERSION_1_8 >> android\app\build.gradle
echo     } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo     kotlinOptions { >> android\app\build.gradle
echo         jvmTarget = '1.8' >> android\app\build.gradle
echo     } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo     sourceSets { >> android\app\build.gradle
echo         main.java.srcDirs += 'src/main/kotlin' >> android\app\build.gradle
echo     } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo     lintOptions { >> android\app\build.gradle
echo         disable 'InvalidPackage' >> android\app\build.gradle
echo     } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo     defaultConfig { >> android\app\build.gradle
echo         applicationId "com.example.farmingapp" >> android\app\build.gradle
echo         minSdkVersion 21 >> android\app\build.gradle
echo         targetSdkVersion 28 >> android\app\build.gradle
echo         versionCode flutterVersionCode.toInteger() >> android\app\build.gradle
echo         versionName flutterVersionName >> android\app\build.gradle
echo         multiDexEnabled true >> android\app\build.gradle
echo     } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo     buildTypes { >> android\app\build.gradle
echo         release { >> android\app\build.gradle
echo             signingConfig signingConfigs.debug >> android\app\build.gradle
echo         } >> android\app\build.gradle
echo     } >> android\app\build.gradle
echo } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo flutter { >> android\app\build.gradle
echo     source '../..' >> android\app\build.gradle
echo } >> android\app\build.gradle
echo. >> android\app\build.gradle
echo dependencies { >> android\app\build.gradle
echo     implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version" >> android\app\build.gradle
echo     // Firebase dependencies with fixed versions >> android\app\build.gradle
echo     implementation 'com.google.firebase:firebase-core:17.0.0' >> android\app\build.gradle
echo     implementation 'com.google.firebase:firebase-analytics:17.0.0' >> android\app\build.gradle
echo     implementation 'com.google.firebase:firebase-auth:19.0.0' >> android\app\build.gradle
echo     implementation 'com.google.firebase:firebase-firestore:20.0.0' >> android\app\build.gradle
echo     // MultiDex >> android\app\build.gradle
echo     implementation 'androidx.multidex:multidex:2.0.0' >> android\app\build.gradle
echo } >> android\app\build.gradle

echo Updating gradle.properties for compatibility...
echo org.gradle.jvmargs=-Xmx1536M > android\gradle.properties
echo android.useAndroidX=true >> android\gradle.properties
echo android.enableJetifier=true >> android\gradle.properties

echo Cleaning old Gradle caches and files...
rd /s /q %USERPROFILE%\.gradle\caches\
rd /s /q %USERPROFILE%\.gradle\daemon\
rd /s /q %USERPROFILE%\.gradle\wrapper\dists\gradle-*

echo Forcing Flutter to use JDK 8...
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-8.0.292.10-hotspot" /M

echo Cleaning Flutter project...
flutter clean

echo Getting packages...
flutter pub get

echo Done! Please open a NEW command prompt and try running:
echo flutter run
echo.
echo If it still fails, run the following commands:
echo 1. set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-8.0.292.10-hotspot"
echo 2. set "PATH=%JAVA_HOME%\bin;%PATH%"
echo 3. flutter run
echo.
pause
