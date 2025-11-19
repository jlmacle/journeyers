cd ../..
@echo off
set BROWSER="C:\Program Files\Google\Chrome\Application\chrome.exe"
echo Programm to wait for the web servers to start before opening browser tabs
timeout /t 5 >nul

start flutter run -t .\test\common_widgets\display_and_content\custom_dismissable_rectangular_area_visual_testing.dart -d web-server --web-port 8091
start flutter run -t .\test\common_widgets\display_and_content\custom_material_banner_visual_testing.dart -d web-server --web-port 8092
start flutter run -t .\test\common_widgets\display_and_content\custom_snackbar_start_message_visual_testing.dart -d web-server --web-port 8093
start flutter run -t .\test\common_widgets\interaction_and_inputs\custom_language_switcher_visual_testing.dart -d web-server --web-port 8094
start flutter run -t .\test\common_widgets\lists_and_scrolling\custom_expansion_tile_visual_testing.dart -d web-server --web-port 8095

timeout /t 35 >nul
%BROWSER% "http://localhost:8091
%BROWSER% "http://localhost:8092
%BROWSER% "http://localhost:8093
%BROWSER% "http://localhost:8094
%BROWSER% "http://localhost:8095
