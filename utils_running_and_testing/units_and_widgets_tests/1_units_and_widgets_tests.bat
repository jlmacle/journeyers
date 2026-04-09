@echo off

echo ---------------------------------------------  
echo Unit and widget tests.
echo ---------------------------------------------
echo JOURNEYERS_DIR must be set to the project root directory

cd %JOURNEYERS_DIR%
flutter test -r github

