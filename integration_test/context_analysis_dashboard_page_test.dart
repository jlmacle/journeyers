import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:integration_test/integration_test.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/project_specific/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/widgets/utility/sessions_dashboard_page.dart';

import 'externalized_code/integration_test_utils.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async {
    // This points to a system-valid temporary folder with write access
    return Directory.systemTemp.path;
  }
}

void main() async
{
  // Mock class declaration before running tests
  PathProviderPlatform.instance = MockPathProviderPlatform();

  // Initializes the bridge between the app and the test runner
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Session data and its copy
  List<dynamic>? currentSessionData;
  List<dynamic>? currentSessionDataCopy;

  // Directory with permission to write
  Directory? appSupportDir;
  // Source directory for the test files
  Directory? absolutePathToSourceDir;
  // Copy directory for the test files
  Directory? absolutePathToCopiesDir;

  // Metadata and file names for the test files
  String testFile1Title = "Test-Context analysis 1";
  List<String> testFile1Keywords = [];
  String fileName1 = "file1.txt";

  String testFile2Title = "Test-Context analysis 2";
  List<String> testFile2Keywords = ["kw1"];
  String fileName2 = "file2.txt";

  String testFile3Title = "Test-Context analysis 3";
  List<String> testFile3Keywords = ["kw1","kw2"];
  List<String> testDataTitles = [testFile1Title, testFile2Title, testFile3Title];
  String fileName3 = "file3.txt";
      
        

  group
  (
    'Context analysis dashboard page tests\n', 
    () 
    { 
      // Runs once before all tests
      setUpAll(() async 
      {
        // PRE-TEST SESSION TMP METADATA COPY: an empty list.
        // On Windows, for example, 
        // "C:\Users\user-name\AppData\Local\Temp\dashboard_session_data_context_analyses.json" is re-built
        // in the same Temp directory during each test.
        // If the data is not restored to empty list, the test metadata keeps being added to the file at each test.
        // Getting the pre-test session tmp metadata to make a copy
        currentSessionData = await du.retrieveAllDashboardMetadata
        (typeOfContextData: DashboardUtils.contextAnalysesContext);
        // Storing a copy of the session metadata to restore session metadata to pre-test environment
        currentSessionDataCopy = List.from(currentSessionData!);
        
        // ACCESSING THE APPLICATION SUPPORT DIRECTORY
        // getApplicationSupportDirectory is used by getSessionFile to retrieve the user metadata.
        // During the test, getApplicationSupportDirectory points to the tmp directory, 
        // and for this reason, getSessionFile creates a new metadata file if needed.
        // There is no need to backup user metadata.
        appSupportDir =  await getApplicationSupportDirectory();
        pu.printd("");
        pu.printd("appSupportDir: $appSupportDir");
        pu.printd("");

        // TEST FILES CREATION
        // Creating the folder structure for the source files: integration_test/test_files/source/
        String relativePathToSourceDir = 'integration_test/test_files/source/';
        absolutePathToSourceDir = Directory(path.join(appSupportDir!.path, relativePathToSourceDir));
        await absolutePathToSourceDir!.create(recursive: true);  

        // Creating the folder structure for the copies: integration_test/test_files/copies/
        String relativePathToCopiesDir = 'integration_test/test_files/copies/';
        absolutePathToCopiesDir = Directory(path.join(appSupportDir!.path, relativePathToCopiesDir));
        await absolutePathToCopiesDir!.create(recursive: true);       

        File file1 = File(path.join(absolutePathToSourceDir!.path, fileName1));
        File file2 = File(path.join(absolutePathToSourceDir!.path, fileName2));
        File file3 = File(path.join(absolutePathToSourceDir!.path, fileName3));
        if (!file1.existsSync()) {file1.createSync();}
        if (!file2.existsSync()) {file2.createSync();}
        if (!file3.existsSync()) {file3.createSync();} 

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // To avoid the information modal's appearance
          'isInformationModalAcknowledged': true,
          // To have the context analysis page, with the dashboard.
          // Data and metadata added during setup().
          'wasSessionDataSaved': true
        });               
      });

      // Runs before the tests
      setUp(
        () async 
        {
          // Emptying and recreating the copies folder
          if (await absolutePathToCopiesDir!.exists()) 
          {
            final entriesInCopiesDir = await absolutePathToCopiesDir!.list().toList();
            if (entriesInCopiesDir.isNotEmpty) 
            {
              // Deleting everything inside the copies folder and recreating the directory
              await absolutePathToCopiesDir!.delete(recursive: true);
              await absolutePathToCopiesDir!.create();
            }
          }
          else {throw Exception('$absolutePathToCopiesDir does not exist.');}

          // Copying the source files in the copies folder
          await for (var entity in absolutePathToSourceDir!.list(recursive: true)) 
          {
            if (entity is File) 
            {
              final relativePath = path.relative(entity.path, from: absolutePathToSourceDir!.path);
              final newPath = path.join(absolutePathToCopiesDir!.path, relativePath);
              
              // Ensuring sub-folders exist in the destination folder if doing recursive copy
              await Directory(path.dirname(newPath)).create(recursive: true);
              await entity.copy(newPath);
            }
          }
          
          // Creating metadata for file 1
          DateTime dateFile1 = DateTime.now();
          // .add_jm() to add this hour:minutes format: 5:08 PM
          // .add_jm() used at session list building time
          var formatter = DateFormat('MMMM dd, yyyy').add_jm();
          var formattedDate = formatter.format(dateFile1);

          await du.saveDashboardMetadata
          (
            typeOfContextData: DashboardUtils.contextAnalysesContext,
            title: testFile1Title,
            keywords: testFile1Keywords,
            formattedDate: formattedDate,
            pathToFile: path.join(absolutePathToCopiesDir!.path,fileName1)
          );

          // Creating metadata for file 2
          var dateFile2 = dateFile1.add(const Duration(seconds: 90));
          formattedDate = formatter.format(dateFile2);

          await du.saveDashboardMetadata
          (
            typeOfContextData: DashboardUtils.contextAnalysesContext,
            title: testFile2Title,
            keywords: testFile2Keywords,
            formattedDate: formattedDate,
            pathToFile: path.join(absolutePathToCopiesDir!.path,fileName2)
          );

          // Creating metadata for file 3
          var dateFile3 = dateFile2.add(const Duration(seconds: 90));
          formattedDate = formatter.format(dateFile3);

          await du.saveDashboardMetadata
          (
            typeOfContextData: DashboardUtils.contextAnalysesContext,
            title: testFile3Title,
            keywords: testFile3Keywords,
            formattedDate: formattedDate,
            pathToFile: path.join(absolutePathToCopiesDir!.path,fileName3)
          );

          // Retrieving the current session metadata (incl. the test files metadata)
          currentSessionData = await du.retrieveAllDashboardMetadata
          (typeOfContextData: DashboardUtils.contextAnalysesContext);
        }
      );

      tearDown(() async 
      {
        // PRE-TEST SESSION METADATA RESTORATION
        try 
        {
          // Restores []
          await du.saveAllSessionsMetadata
          (
            typeOfContextData: DashboardUtils.contextAnalysesContext, 
            allSessionsMetadata: currentSessionDataCopy!
          );
         
        } 
        catch (e, stackTrace) 
        {
          pu.printd('Caught an error while restoring pre-test session data: $e');
          pu.printd('Stack trace: $stackTrace');
        }
      });

      // 'Session data display:\n'
      // 'When a session data is displayed, the session title, date, and keywords should be findable.',
      testWidgets
      ( 
        // skip:true,
        'Session data display:\n'
        'When a session data is displayed, the session title, date, and keywords should be findable.',
        (tester) async 
        { 
          const testingDebugDelay = 0;
         
          // Launching the widget
          await tester.pumpWidget
          (             
            MaterialApp
            (              
              home:SessionsDashboardPage
              (
                dashboardContext: DashboardUtils.contextAnalysesContext,
                previewWidget: null,
                parentCallbackFunctionWhenAllSessionFilesAreDeleted: (){},
                dashboardSortingByKeywordsKey: null,
              )            
            )
          );
          await tester.pumpAndSettle();

          // Getting the list of titles to search for duplicates of the test metadata titles
          List<String> sessionsTitlesList = await getSessionsTitlesList
                                      (tester: tester, sessionData: currentSessionData!.cast<Map<String, dynamic>>(), keyRoot: 'session-title-');
          await tester.pumpAndSettle();
          if (testingDebug) pu.printd("Testing Debug: sessionsTitlesList: $sessionsTitlesList");
          // Pausing for debug
          if (testingDebug) pu.printd("Testing Debug: After getSessionsTitlesList: waiting: $testingDebugDelay s");
          if (testingDebug) await tester.pump(const Duration(seconds: testingDebugDelay));
          
          assert(
            !isThereATestDataTitleDuplicated(listOfSessionTitles: sessionsTitlesList,listOfTestDataTitles: testDataTitles),
            'Duplicate test data titles were found in the session list!'
          );

          // Getting the index for file 1, used for the test
          int file1Index = getSessionDataIndexFromTitle(sessionData: currentSessionData!.cast<Map<String, dynamic>>(), title: testFile1Title)!;
          // Pausing for debug
          if (testingDebug) pu.printd("Testing Debug: After getSessionDataIndexFromTitle: waiting: $testingDebugDelay s");
          if (testingDebug) await tester.pump(const Duration(seconds: testingDebugDelay));

          // Scrolling back up the screen (in case scrolled down while gathering the session titles)
          final listFinder = find.byKey(const Key('sessions-list-scrollview'));
          final titleFinder = find.byKey(Key('session-title-$file1Index'));
          if (testingDebug) pu.printd("Testing Debug: List count: ${listFinder.evaluate().length}");
          if (testingDebug) pu.printd("Testing Debug: Title count: ${titleFinder.evaluate().length}");

          await scrollListUpScrollableByFirstDescendant(tester: tester, listFinder: listFinder, elementToReachFinder: titleFinder);

          // Testing for the presence of the title
          await tester.ensureVisible(titleFinder); 
          await tester.pump();
          final Text titleWidget = tester.widget(titleFinder);        
          String title = titleWidget.data!;
          expect(title, testFile1Title);

          // Testing for the presence of the date
          // Getting the current date
          var now = DateTime.now();
          // Date without the hours and minutes
          var formatter = DateFormat('MMMM dd, yyyy');
          var todaySDateMinusHoursAndMinutes = formatter.format(now);
          // Getting the date from the data (with hours and minutes)
          final dateFinder = find.byKey(Key('session-date-$file1Index'));
          final Text dateWidget = tester.widget(dateFinder);        
          String retrievedDateWithParentheses = dateWidget.data!;
          String retrievedDateWithoutParentheses = 
                retrievedDateWithParentheses.replaceAll(RegExp(r'[()]'), '');
          // Removing hours and minutes before testing
          DateFormat inputFormat = DateFormat("MMMM dd, yyyy").add_jm();
          DateFormat outputFormat = DateFormat("MMMM dd, yyyy");
          DateTime retrievedDateTimeWithoutParentheses = inputFormat.parse(retrievedDateWithoutParentheses);
          String retrievedDateTimeWithoutParenthesesMinusHoursAndMinutes = outputFormat.format(retrievedDateTimeWithoutParentheses);

          expect('($retrievedDateTimeWithoutParenthesesMinusHoursAndMinutes)', '($todaySDateMinusHoursAndMinutes)');

          // Testing for the presence of the keywords
          final keywordsFinder = find.byKey(Key('session-keywords-$file1Index'));
          final Text keywordsWidget = tester.widget(keywordsFinder);        
          String keywords = keywordsWidget.data!;
          expect(keywords, "Keywords: ${testFile1Keywords.join(', ')}");
        }
      );
    }
  );
}