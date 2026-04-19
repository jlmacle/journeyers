@echo off

if not defined JOURNEYERS_DIR (
    echo --------------------------------------------------------- 
    echo JOURNEYERS_DIR must be set to the project root directory.
    echo --------------------------------------------------------- 
    exit /b 1
)

@REM echo ----------------------------------------------  
@REM echo Integration tests.
@REM echo The Android phone screen needs to be unlocked.
@REM echo Please note:
@REM echo The integration tests process removes the app.
@REM echo ----------------------------------------------


@REM cd %JOURNEYERS_DIR%
@REM flutter test ./integration_test/ -r github

