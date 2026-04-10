@echo off

if not defined JOURNEYERS_DIR (
    echo --------------------------------------------------------- 
    echo JOURNEYERS_DIR must be set to the project root directory.
    echo --------------------------------------------------------- 
    exit /b 1
)

echo ---------------------------------------------  
echo All tests.
echo ---------------------------------------------


cd %JOURNEYERS_DIR%

:: Unit and widget tests
cd ./utils_running_and_testing/units_and_widgets_tests
call ./1_units_and_widgets_tests.bat

:: Integration tests
cd ./utils_running_and_testing/integration_tests
call ./5_Windows_integration_tests.bat

