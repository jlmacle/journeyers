@echo off

if not defined JOURNEYERS_DIR (
    echo --------------------------------------------------------- 
    echo JOURNEYERS_DIR must be set to the project root directory.
    echo --------------------------------------------------------- 
    exit /b 1
)

@REM echo ---------------------------------------------  
@REM echo Integration tests.
@REM echo ---------------------------------------------


@REM cd %JOURNEYERS_DIR%
@REM flutter test ./integration_test/_all_tests.dart  -r github -d windows

