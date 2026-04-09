# chmod u+x 3_units_and_widgets_tests.zsh

echo "---------------------------------------------"  
echo "Unit and widget tests."
echo "---------------------------------------------"
echo "JOURNEYERS_DIR must be set to the project root directory"

cd $JOURNEYERS_DIR
flutter test -r github