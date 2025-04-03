@echo off
echo Updating Gradle wrapper...
cd android
call gradlew wrapper --gradle-version 6.7.1 --distribution-type all
echo Done!
