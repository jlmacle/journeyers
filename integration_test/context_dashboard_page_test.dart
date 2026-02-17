import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analyses_dashboard_page.dart';

import 'externalized_code/integration_test_utils.dart';

//**************** UTILITY CLASSES ****************//
UserPreferencesUtils _upu = UserPreferencesUtils();
DashboardUtils _du = DashboardUtils();
PrintUtils _pu = PrintUtils();

void main() async
{
  // This initializes the bridge between the app and the test runner
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late List<dynamic> currentSessionData;
  late List<dynamic> currentSessionDataCopy;
  late Directory? appSupportDir;
  String testFile1Title = "Test-Context analysis 1";
  List<String> testFile1Keywords = [];
  String testFile2Title = "Test-Context analysis 2";
  List<String> testFile2Keywords = ["kw1"];
  String testFile3Title = "Test-Context analysis 3";
  List<String> testFile3Keywords = ["kw1","kw2"];
  List<String> testDataTitles = [testFile1Title, testFile2Title, testFile3Title];

  group
  (
    'Dashboard page tests\n', 
    () 
    { 
      setUp(() async 
      {
        // PRE-TEST SESSION DATA COPY
        // Getting the current session data to make a copy
        currentSessionData = await _du.retrieveAllDashboardSessionData
        (typeOfContextData: DashboardUtils.contextAnalysesContext);
        // Storing a copy of the session data to restore session data to pre-test environment
        currentSessionDataCopy = List.from(currentSessionData);

        // ACCESSING THE APPLICATION SUPPORT DIRECTORY
        appSupportDir =  await getApplicationSupportDirectory();
        _pu.printd("");
        _pu.printd("appSupportDir: $appSupportDir");
        _pu.printd("");

        // TEST FILES CREATION
        // Creating the folder structure for the source files: integration_test/test_files/source/
        String relativePathToSourceDir = 'integration_test/test_files/source/';
        Directory absolutePathToSourceDir = Directory(path.join(appSupportDir!.path, relativePathToSourceDir));
        await absolutePathToSourceDir.create(recursive: true);  

        // Creating the folder structure for the copies: integration_test/test_files/copies/
        String relativePathToCopiesDir = 'integration_test/test_files/copies/';
        Directory absolutePathToCopiesDir = Directory(path.join(appSupportDir!.path, relativePathToCopiesDir));
        await absolutePathToCopiesDir.create(recursive: true);

        // Creating 3 files in the source folder
        String fileName1 = "file.txt";
        String fileName2 = "file2.txt";
        String fileName3 = "file3.txt";

        File file1 = File(path.join(absolutePathToSourceDir.path, fileName1));
        File file2 = File(path.join(absolutePathToSourceDir.path, fileName2));
        File file3 = File(path.join(absolutePathToSourceDir.path, fileName3));
        if (!file1.existsSync()) {file1.createSync();}
        if (!file2.existsSync()) {file2.createSync();}
        if (!file3.existsSync()) {file3.createSync();}
        
        // Emptying and recreating the copies folder
        if (await absolutePathToCopiesDir.exists()) 
        {
          final entriesInCopiesDir = await absolutePathToCopiesDir.list().toList();
          if (entriesInCopiesDir.isNotEmpty) 
          {
            // Deleting everything inside the copies folder and recreating the directory
            await absolutePathToCopiesDir.delete(recursive: true);
            await absolutePathToCopiesDir.create();
          }
        }
        else {throw Exception('$absolutePathToCopiesDir does not exist.');}

        // Copying the source files in the copies folder
        await for (var entity in absolutePathToSourceDir.list(recursive: true)) 
        {
          if (entity is File) 
          {
            final relativePath = path.relative(entity.path, from: absolutePathToSourceDir.path);
            final newPath = path.join(absolutePathToCopiesDir.path, relativePath);
            
            // Ensuring sub-folders exist in the destination folder if doing recursive copy
            await Directory(path.dirname(newPath)).create(recursive: true);
            await entity.copy(newPath);
          }
        }
          
        // Adding new data
        // data 1
        await _du.saveDashboardData
        (
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          analysisTitle: testFile1Title,
          keywords: testFile1Keywords,
          pathToCSVFile: path.join(absolutePathToCopiesDir.path,fileName1)
        );
        // data 2
        await _du.saveDashboardData
        (
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          analysisTitle: testFile2Title,
          keywords: testFile2Keywords,
          pathToCSVFile: path.join(absolutePathToCopiesDir.path,fileName2)
        );
        // data 3
        await _du.saveDashboardData
        (
          typeOfContextData: DashboardUtils.contextAnalysesContext,
          analysisTitle: testFile3Title,
          keywords: testFile3Keywords,
          pathToCSVFile: path.join(absolutePathToCopiesDir.path,fileName3)
        );

        // UPDATING THE CURRENT SESSION DATA
        currentSessionData = await _du.retrieveAllDashboardSessionData
        (typeOfContextData: DashboardUtils.contextAnalysesContext);

        // SETTING 'wasSessionDataSaved' TO TRUE, in case there was no session data to start with
        await _upu.saveWasSessionDataSaved(true);
        
      });

      tearDown(() async 
      {
        // PRE-TEST SESSION DATA RESTORATION
        try 
        {
          await _du.restoreCopiedSessionData
          (
            typeOfContextData: DashboardUtils.contextAnalysesContext, 
            savedData: currentSessionDataCopy
          );

          // PRE-TEST SESSION DATA PRESENT RESTORATION (set to true by the test)
          if (currentSessionDataCopy.isEmpty) {await _upu.saveWasSessionDataSaved(false);}


        } 
        catch (e, stackTrace) 
        {
          _pu.printd('Caught error: $e');
          _pu.printd('Stack trace: $stackTrace');
        }
      });

      testWidgets
      ( 
        // skip:true,
        // Testing the display of session data
        'Session data display:\n'
        'When a session data is diplayed, the session title, date, and keywords should be findable.',
        (tester) async 
        { 
         
          // Launching the widget
          await tester.pumpWidget
          (             
            const MaterialApp
            (              
              home:ContextAnalysesDashboardPage()            
            )
          );
          await tester.pumpAndSettle();
          // The dashboard should load the added data 

          // Getting the list of titles to search for duplicates of the test data titles
          List<String> sessionsTitlesList = await getSessionsTitlesList
                                      (tester: tester, sessionData: currentSessionData, keyRoot: 'session_title_');
          await tester.pumpAndSettle();
          _pu.printd("sessionsTitlesList: $sessionsTitlesList");
          
          assert(
            !isThereATestDataTitleDuplicated(listOfSessionTitles: sessionsTitlesList,listOfTestDataTitles: testDataTitles),
            'Duplicate test data titles were found in the session list!'
          );

          // Scrolling back up the screen (scrolled down while gathering the session titles)
          final listFinder = find.byKey(const Key('session_list'));
          final titleFinder = find.byKey(const Key('session_title_2'));
          await scrollListUpScreen(tester: tester, listFinder: listFinder, elementToReachFinder: titleFinder);

          // Testing for the presence of the title
          await tester.ensureVisible(titleFinder); 
          await tester.pump();
          final Text titleWidget = tester.widget(titleFinder);        
          String title = titleWidget.data!;
          expect(title, testFile3Title);

          // Testing for the presence of the date
            // Getting the current date
          var now = DateTime.now();
          var formatter = DateFormat('MM/dd/yy');
          var formattedDate = formatter.format(now);
            // Getting the date from the data
          final dateFinder = find.byKey(const Key('session_date_2'));
          final Text dateWidget = tester.widget(dateFinder);        
          String date = dateWidget.data!;
          expect(date, '($formattedDate)');

          // Testing for the presence of the keywords
          final keywordsFinder = find.byKey(const Key('session_keywords_2'));
          final Text keywordsWidget = tester.widget(keywordsFinder);        
          String keywords = keywordsWidget.data!;
          expect(keywords, "Keywords: ${testFile3Keywords.join(', ')}");

          // await tester.pump(const Duration(seconds: 5));
        }
      );

      
      testWidgets
      ( 
        // skip:true, 
        // Testing the bulk deletion of session data
        'Bulk deletion:\n'
        'When checkboxes are checked, the session data is marked for bulk deletion.\n'
        'When the "Delete" text is clicked, the deleted sessions should be removed from the displayed session data.\n'
        'The session data stored should be consistent with the deletions.\n'
        'Files physical deletion needs to be visually confirmed.',
        (tester) async 
        {
          // Launching the widget
          await tester.pumpWidget
          (             
            const MaterialApp
            (
              // Needed to avoid a 'No Material widget found.' exception
              home: Scaffold
              ( 
                body: ContextAnalysesDashboardPage()
              ),
            )
          );
          await tester.pumpAndSettle();
          // The dashboard should load the added data

          // Getting the list of all session titles before deletion
          _pu.printd("");
          _pu.printd("Getting the list of all session titles before deletion");
          List<String> sessionTitlesBeforeDeletion = await getSessionsTitlesList
                                                    (tester: tester, sessionData: currentSessionData, keyRoot: 'session_title_');

          // Scrolling back to the first checkbox
          final listFinder = find.byKey(const Key('session_list'));
          final firstCheckboxFinder = find.byKey(const ValueKey('checkbox_0'));
          await scrollListUpScreen(tester: tester, listFinder: listFinder, elementToReachFinder: firstCheckboxFinder);

          // Selecting the 3 added sessions for bulk deletion 
          await tester.tap(firstCheckboxFinder);

          final secondCheckboxFinder = find.byKey(const ValueKey('checkbox_1'));
          await tester.tap(secondCheckboxFinder);
          await tester.pump();

          final thirdCheckboxFinder = find.byKey(const ValueKey('checkbox_2'));
          await tester.tap(thirdCheckboxFinder);
          await tester.pump();

          final bulkDeleteButton = find.byKey(const Key('bulk_delete_button'));
          await tester.pumpAndSettle();

          // Searching for 'Delete (3)'
          expect(find.textContaining('Delete (3)'), findsOneWidget);

          // Clicking on the bulk delete button
          await tester.tap(bulkDeleteButton);
          await tester.pumpAndSettle();

          // Getting the refreshed session data after deletion
          var sessionDataAfterDeletion = await _du.retrieveAllDashboardSessionData
                                                  (typeOfContextData: DashboardUtils.contextAnalysesContext);
          // Getting the list of all session titles after deletion
          _pu.printd("");
          _pu.printd("Getting the list of all session titles after deletion");
          List<String> sessionTitlesAfterDeletion = await getSessionsTitlesList
                                                    (tester: tester, sessionData: sessionDataAfterDeletion, keyRoot: 'session_title_');

          // Comparing the two lists length
          expect(sessionTitlesBeforeDeletion.length - sessionTitlesAfterDeletion.length, 3);

          // Checking if the test titles remained in sessionTitlesAfterDeletion  
          // (could be previous test data, if session restoration data was failed)

          expect(
            sessionTitlesAfterDeletion.contains(testFile1Title)
            || sessionTitlesAfterDeletion.contains(testFile2Title)
            || sessionTitlesAfterDeletion.contains(testFile3Title)
            , false);

          // await tester.pump(const Duration(seconds: 5));
        }
      );
    }
  );
}
