@echo off

echo ---------------------------------------------  
echo The Android phone screen needs to be unlocked.
echo ---------------------------------------------

cd ../..
flutter test ./integration_test/ -r github

