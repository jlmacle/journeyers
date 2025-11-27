:: Please note that Chrome must be started to have more than one tab launched.
:: Batch file launching the widgets, testing the custom widgets, in Chrome tabs.
@echo off
set BROWSER="C:\Program Files\Google\Chrome\Application\chrome.exe"
cd ../..
echo "After launching the terminals, programm to wait for the web servers to be completely started before opening the browser tabs"
timeout /t 5 >nul

start  flutter run -t ./test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart  -d web-server --web-port  8091
start  flutter run -t ./test/common_widgets/display_and_content/custom_snackbar_start_message_helper_visual_testing.dart  -d web-server --web-port  8092
start  flutter run -t test/common_widgets/interaction_and_inputs/custom_cascading_checkbox_visual_testing.dart  -d web-server --web-port  8093
start  flutter run -t ./test/common_widgets/interaction_and_inputs/custom_language_switcher_visual_testing.dart  -d web-server --web-port  8094
start  flutter run -t test/common_widgets/interaction_and_inputs/custom_segmented_button_with_optional_text_field_visual_testing.dart  -d web-server --web-port  8095
start  flutter run -t ./test/common_widgets/lists_and_scrolling/custom_expansion_tile_visual_testing.dart  -d web-server --web-port  8096

:: Waiting for the web servers to start
timeout /t 70 >nul 
%BROWSER% http://localhost:8091
%BROWSER% http://localhost:8092
%BROWSER% http://localhost:8093
%BROWSER% http://localhost:8094
%BROWSER% http://localhost:8095
%BROWSER% http://localhost:8096
