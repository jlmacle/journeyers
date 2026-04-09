# chmod u+x 4_macOS_all_tests.zsh

echo "---------------------------------------------"  
echo "All tests."
echo "---------------------------------------------"
echo "JOURNEYERS_DIR must be set to the project root directory"

# Unit and widget tests
cd $JOURNEYERS_DIR
cd ./utils_running_and_testing/units_and_widgets_tests
./3_units_and_widgets_tests.zsh 

# Integration tests
cd $JOURNEYERS_DIR
cd ./utils_running_and_testing/integration_tests
./4_macOS_integration_tests.zsh

