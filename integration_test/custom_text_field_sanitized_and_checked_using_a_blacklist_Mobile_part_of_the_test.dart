// ignore: file_names
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/main.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart";

void main() {
  // The file name is tested without the extension to avoid triggering the dot removal
  const csvFileNameBlacklisted = "file1";
  Directory? testTmpDir;
  String? pathToTmpFolder;

  WidgetsFlutterBinding.ensureInitialized();

  setUp(() 
  {
    // Creates a temporary directory on any host OS
    testTmpDir = Directory.systemTemp.createTempSync("SessionFileNameOnMobilePlatforms_test");
    pathToTmpFolder = testTmpDir!.path;
  });

  tearDown(() {
  // Cleans up after each test
  if (testTmpDir!.existsSync()) testTmpDir!.deleteSync(recursive: true);
  });
  
  group("TextFieldChecked Tests (Mobile platforms):\n", () {       

    

    // "On mobile: The user cannot submit a TXT file name already used."
    testWidgets("On mobile: The user cannot submit a TXT file name already used.", 
    (WidgetTester tester) async 
    {
    });
    
  });
}