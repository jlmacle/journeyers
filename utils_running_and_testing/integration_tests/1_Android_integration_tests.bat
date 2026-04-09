@echo off

echo ---------------------------------------------  
echo Integration tests.
echo The Android phone screen needs to be unlocked.
echo ---------------------------------------------
echo JOURNEYERS_DIR must be set to the project root directory

cd %JOURNEYERS_DIR%
flutter test ./integration_test/ -r github

