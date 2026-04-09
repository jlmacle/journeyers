# chmod u+x 2_iOS_all_tests.zsh

echo "---------------------------------------------"  
echo "All tests."
echo "---------------------------------------------"
echo "JOURNEYERS_DIR must be set to the project root directory"

# Integration tests
cd $JOURNEYERS_DIR
cd ./utils_running_and_testing/integration_tests
./2_iOS_integration_tests.zsh

