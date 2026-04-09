@echo off
echo ---------------------------------------------  
echo All tests.
echo ---------------------------------------------
echo JOURNEYERS_DIR must be set to the project root directory

cd %JOURNEYERS_DIR%

:: Integration tests
cd ./utils_running_and_testing/integration_tests
./1_Android_integration_tests.bat