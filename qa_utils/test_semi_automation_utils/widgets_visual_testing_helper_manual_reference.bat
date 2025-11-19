REM Batch file launching the widgets, testing the custom widgets, in Chrome tabs.
cd ../..
@echo off
set BROWSER="C:\Program Files\Google\Chrome\Application\chrome.exe"

echo Programm to wait for the web servers to start before opening browser tabs
timeout /t 7 >nul
start flutter run -t .\test\common_widgets\display_and_content\custom_dismissable_rectangular_area_visual_testing.dart -d web-server --web-port 8080
start flutter run -t .\test\common_widgets\display_and_content\custom_material_banner_visual_testing.dart -d web-server --web-port 8081
 
timeout /t 20 >nul

%BROWSER% "http://localhost:8080"
%BROWSER% "http://localhost:8081"




