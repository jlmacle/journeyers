# To make the script executable: chmod u+x 6_widget_visual_testing_helper.zsh
# Zsh file launching the widgets, testing the custom widgets, in Chrome tabs.
cd ../..
echo "After launching the terminals, programm to wait for the web servers to be completely started before opening the browser tabs"
sleep 5

osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/display_and_content/custom_header_visual_testing.dart -d web-server --web-port 8091"'
osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/interaction_and_inputs/custom_snackbar_start_message_helper_visual_testing.dart -d web-server --web-port 8092"'
osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d web-server --web-port 8093"'
osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/interaction_and_inputs/custom_dismissable_rectangular_area_visual_testing.dart -d web-server --web-port 8094"'
osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/interaction_and_inputs/custom_padded_text_field_visual_testing.dart -d web-server --web-port 8095"'
osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/interaction_and_inputs/custom_language_switcher_visual_testing.dart -d web-server --web-port 8096"'
osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d web-server --web-port 8097"'
osascript -e 'tell application "Terminal" to do script "cd ./; flutter run -t ./test/common_widgets/interaction_and_inputs/custom_segmented_button_with_text_field_visual_testing.dart -d web-server --web-port 8098"'

# Waiting for the web servers to start
sleep 70 
open -a "Google Chrome" "http://localhost:8091"
open -a "Google Chrome" "http://localhost:8092"
open -a "Google Chrome" "http://localhost:8093"
open -a "Google Chrome" "http://localhost:8094"
open -a "Google Chrome" "http://localhost:8095"
open -a "Google Chrome" "http://localhost:8096"
open -a "Google Chrome" "http://localhost:8097"
open -a "Google Chrome" "http://localhost:8098"
