# chmod u+x 4_macOS_all_tests.zsh

if [ -z "${JOURNEYERS_DIR}" ]; then
    echo "---------------------------------------------------------"
    echo "JOURNEYERS_DIR must be set to the project root directory."
    echo "---------------------------------------------------------"
    exit 1
fi

echo "---------------------------------------------"  
echo "All tests."
echo "---------------------------------------------"

# Unit and widget tests
cd $JOURNEYERS_DIR
cd ./utils_running_and_testing/units_and_widgets_tests
./2_macOS_units_and_widgets_tests.zsh

# # Integration tests
# cd $JOURNEYERS_DIR
# cd ./utils_running_and_testing/integration_tests
# ./4_macOS_integration_tests.zsh

