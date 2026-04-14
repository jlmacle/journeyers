@echo off

if not defined JOURNEYERS_DIR (
    echo --------------------------------------------------------- 
    echo JOURNEYERS_DIR must be set to the project root directory.
    echo --------------------------------------------------------- 
    exit /b 1
)

echo ----------------------------------------------  
echo Integration tests.
echo The Android phone screen needs to be unlocked.
echo Please note:
echo The integration tests process removes the app.
echo ----------------------------------------------


cd %JOURNEYERS_DIR%
flutter test ./integration_test/ -r github

