@echo off

if not defined JOURNEYERS_DIR (
    echo --------------------------------------------------------- 
    echo JOURNEYERS_DIR must be set to the project root directory.
    echo --------------------------------------------------------- 
    exit /b 1
)

echo ----------------------------------------------  
echo All tests.
echo ----------------------------------------------


cd %JOURNEYERS_DIR%

:: Integration tests
cd ./utils_running_and_testing/integration_tests
./1_Android_integration_tests.bat