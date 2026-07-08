// ignore: file_names
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/main.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart';

void main() {
  // The file name is tested without the extension to avoid triggering the dot removal
  const csvFileNameBlacklisted = "file1";
  Directory? testTmpDir;
  String? pathToTmpFolder;

  WidgetsFlutterBinding.ensureInitialized();

  setUp(() 
  {
    // Creates a temporary directory on any host OS
    testTmpDir = Directory.systemTemp.createTempSync('SessionFileNameOnMobilePlatforms_test');
    pathToTmpFolder = testTmpDir!.path;
  });

  tearDown(() {
  // Cleans up after each test
  if (testTmpDir!.existsSync()) testTmpDir!.deleteSync(recursive: true);
  });
  
  group('TextFieldChecked Tests (Mobile platforms):\n', () {       

    // Couldn't test with a POSIX path.
    // Kept to illustrate that the idea wasn't overlooked.
    // 'On mobile: The user cannot submit a CSV file name already used.'
    testWidgets('On mobile: The user cannot submit a CSV file name already used.', 
    (WidgetTester tester) async 
    {
      
      if (testingDebug) pu.printd("Testing Debug: testTmpDir path: ${testTmpDir!.path}");
      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
          // To avoid the first-run modal
          'wasFirstRunModalAcknowledged': true, 
          // To get the CA process page
          'wasSessionDataSaved': false,
          // Test dir as application folder path
          'applicationFolderPath': testTmpDir!.path
      });

      // Loading the widget
      await tester.pumpWidget
      (
        const MaterialApp(
          home: Scaffold(
            // du.getStoredFileNamesOnMobile(); is run in main.dart
            body: GPSapp()
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (testingDebug) pu.printd("Testing Debug: Platform: ${Platform.operatingSystem}");
      if (Platform.isAndroid || Platform.isIOS)
      {
        // Writing CSV files in the tmp folder 
        File csvFile1 = File('${pathToTmpFolder!}/file1.csv');
        await csvFile1.create();

        File csvFile2 = File('${pathToTmpFolder!}/file2.csv');
        await csvFile2.create();

        List<File> fileList = await 
        fu.getFilesWithExtensionInDirectory
        (directoryPath: pathToTmpFolder!, fileExtension: ".csv", searchIsRecursive: true);

        if (testingDebug) pu.printd("Testing Debug: Files found in ${pathToTmpFolder!}:\n $fileList");

        // Was calling du.getStoredFileNamesOnMobile(pathToTmpFolder!),
        // with a modified version of getStoredFileNamesOnMobile() and of the Kotlin code.
        // The path was an invalid URI for SAF, therefore throwing an exception.
        // The following PlatformException was thrown running a test:
        // PlatformException(INVALID_URI, Expected a SAF content:// tree URI, got:
        // /data/user/0/dev.journeyers/code_cache/SessionFileNameOnMobilePlatforms_testKCXGHA, null, null)

        // Making sure the text field visible
        var textFieldFinder = 
        find.descendant(
          of: find.byType(SessionFileNameOnMobilePlatforms), 
          matching: find.byType(TextField));
        await tester.ensureVisible(textFieldFinder);

        // Entering the text to search in the blacklist          
        await tester.enterText(textFieldFinder, csvFileNameBlacklisted);       
        await tester.pumpAndSettle();

        // Verifying error message is rendered
        // expect(find.text(TextFieldUtils.errorFileNameAlreadyUsed), findsOneWidget);
      }                  
    }
    );

    // 'On mobile: The user cannot submit a TXT file name already used.'
    testWidgets('On mobile: The user cannot submit a TXT file name already used.', 
    (WidgetTester tester) async 
    {
    });
    
  });
}