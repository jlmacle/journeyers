@echo off

if not defined JOURNEYERS_DIR (
    echo --------------------------------------------------------- 
    echo JOURNEYERS_DIR must be set to the project root directory.
    echo --------------------------------------------------------- 
    exit /b 1
)
echo ---------------------------------------------  
echo Unit and widget tests.
echo ---------------------------------------------


cd %JOURNEYERS_DIR%
flutter test -r github && echo. 


