@echo off

if not defined JOURNEYERS_DIR (
    echo --------------------------------------------------------- 
    echo JOURNEYERS_DIR must be set to the project root directory.
    echo --------------------------------------------------------- 
    exit /b 1
)

@REM echo ----------------------------------------------  
@REM echo All tests.
@REM echo ----------------------------------------------


@REM cd %JOURNEYERS_DIR%

:: Integration tests
@REM cd ./utils_running_and_testing/integration_tests
@REM ./1_Android_integration_tests.bat