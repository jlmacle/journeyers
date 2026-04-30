# chmod u+x 2_iOS_all_tests.zsh

if [ -z "${JOURNEYERS_DIR}" ]; then
    echo "---------------------------------------------------------"
    echo "JOURNEYERS_DIR must be set to the project root directory."
    echo "---------------------------------------------------------"
    exit 1
fi

echo "---------------------------------------------"  
echo "All tests."
echo "---------------------------------------------"

# Integration tests
cd $JOURNEYERS_DIR
cd ./utils_running_and_testing/integration_tests
./2_iOS_integration_tests.zsh

