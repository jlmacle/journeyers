# To make the script executable: chmod u+x 4_widget_visual_testing_helper.sh
# Bash file launching the widgets, testing the custom widgets, in Chrome tabs.
cd ../..
echo "After launching the terminals, programm to wait for the web servers to be completely started before opening the browser tabs"
sleep 5

xterm -e "cd ./; flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field_visual_testing.dart -d web-server --web-port 8091" &
xterm -e "cd ./; flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_expansion_tile_visual_testing.dart -d web-server --web-port 8092" &
xterm -e "cd ./; flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_language_switch_visual_testing.dart -d web-server --web-port 8093" &
xterm -e "cd ./; flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_segmented_button_with_text_field_visual_testing.dart -d web-server --web-port 8094" &
xterm -e "cd ./; flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_padded_text_field_visual_testing.dart -d web-server --web-port 8095" &
xterm -e "cd ./; flutter run -t ./test/custom_widgets/display_and_content/custom_heading_visual_testing.dart -d web-server --web-port 8096" &
xterm -e "cd ./; flutter run -t ./test/custom_widgets/display_and_content/custom_focusable_text_visual_testing.dart -d web-server --web-port 8097" &
# Waiting for the web servers to start
sleep 70 
open "http://localhost:8091"
open "http://localhost:8092"
open "http://localhost:8093"
open "http://localhost:8094"
open "http://localhost:8095"
open "http://localhost:8096"
open "http://localhost:8097"