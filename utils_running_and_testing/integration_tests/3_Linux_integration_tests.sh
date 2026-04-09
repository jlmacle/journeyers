# chmod u+x 3_Linux_integration_tests.sh

echo "---------------------------------------------" 
echo "Integration tests."
echo "---------------------------------------------"
echo "JOURNEYERS_DIR must be set to the project root directory"

cd $JOURNEYERS_DIR
flutter test ./integration_test/_all_tests.dart  -r github -d linux

