# chmod u+x 2_units_and_widgets_tests.sh

if [ -z "${JOURNEYERS_DIR}" ]; then
    echo "---------------------------------------------------------"
    echo "JOURNEYERS_DIR must be set to the project root directory."
    echo "---------------------------------------------------------"
    exit 1
fi

echo "---------------------------------------------"  
echo "Unit and widget tests."
echo "---------------------------------------------"

cd $JOURNEYERS_DIR
flutter test -r github && echo