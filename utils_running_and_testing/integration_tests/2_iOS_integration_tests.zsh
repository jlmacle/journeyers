# chmod u+x 2_iOS_integration_tests.zsh

if [ -z "${JOURNEYERS_DIR}" ]; then
    echo "---------------------------------------------------------"
    echo "JOURNEYERS_DIR must be set to the project root directory."
    echo "---------------------------------------------------------"
    exit 1
fi

# echo "----------------------------------------------" 
# echo "Integration tests."
# echo "Please note:"
# echo "The integration tests process removes the app."
# echo "----------------------------------------------"

# cd $JOURNEYERS_DIR
# flutter test ./integration_test/_all_tests.dart  -r github

