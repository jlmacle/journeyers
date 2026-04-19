# chmod u+x 3_Linux_all_tests.sh

echo "---------------------------------------------"  
echo "All tests."
echo "---------------------------------------------"

if [ -z "${JOURNEYERS_DIR}" ]; then
    echo "---------------------------------------------------------"
    echo "JOURNEYERS_DIR must be set to the project root directory."
    echo "---------------------------------------------------------"
    exit 1
fi

# Unit and widget tests
cd $JOURNEYERS_DIR
cd ./utils_running_and_testing/units_and_widgets_tests
./1_Linux_units_and_widgets_tests.sh

# # Integration tests
# cd $JOURNEYERS_DIR
# cd ./utils_running_and_testing/integration_tests
# ./3_Linux_integration_tests.sh

