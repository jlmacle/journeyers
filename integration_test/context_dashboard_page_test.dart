import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analyses_dashboard_page.dart';

//**************** UTILITY CLASSES ****************//
UserPreferencesUtils _upu = UserPreferencesUtils();
DashboardUtils _du = DashboardUtils();
PrintUtils _pu = PrintUtils();

void main() async
{
  // This initializes the bridge between the app and the test runner
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group
  (
    'Dashboard page tests\n', 
    () 
    {      
      
      testWidgets
      ( 
        // Testing the bulk deletion of session data
        'When checkboxes are checked, the session data is marked for bulk deletion.\n'
        'When the "Delete" text is clicked, the deleted sessions should be removed from the displayed session data.\n'
        'The session data stored should be consistent with the deletions.\n'
        'Files physical deletion needs to be visually confirmed.',
        (tester) async 
        { 
          // Accessing the support directory
          Directory? appSupportDir;
          appSupportDir =  await getApplicationSupportDirectory();
          _pu.printd("");
          _pu.printd("appSupportDir: $appSupportDir");
          _pu.printd("");

          // Creating the folder structure for the source files: integration_test/test_files/source/
          String relativePathToSourceDir = 'integration_test/test_files/source/';
          Directory absolutePathToSourceDir = Directory(path.join(appSupportDir.path, relativePathToSourceDir));
          await absolutePathToSourceDir.create(recursive: true);  

          // Creating the folder structure for the copies: integration_test/test_files/copies/
          String relativePathToCopiesDir = 'integration_test/test_files/copies/';
          Directory absolutePathToCopiesDir = Directory(path.join(appSupportDir.path, relativePathToCopiesDir));
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

          // Getting the session data
          List<dynamic> sessionData = await _du.retrieveAllDashboardSessionData
          (typeOfContextData: DashboardUtils.contextAnalysesContext);

          // Storing a copy of the session data to restore session data to pre-test environment
          List<dynamic> sessionDataCopy = sessionData.toList();

          try
          {
            // Adding new data
            // data 1
            await _du.saveDashboardData
            (
              typeOfContextData: DashboardUtils.contextAnalysesContext,
              analysisTitle: "Untitled -",
              keywords: [],
              pathToCSVFile: path.join(absolutePathToCopiesDir.path,fileName1)
            );
            // data 2
            await _du.saveDashboardData
            (
              typeOfContextData: DashboardUtils.contextAnalysesContext,
              analysisTitle: "Untitled -",
              keywords: [],
              pathToCSVFile: path.join(absolutePathToCopiesDir.path,fileName2)
            );
            // data 3
            await _du.saveDashboardData
            (
              typeOfContextData: DashboardUtils.contextAnalysesContext,
              analysisTitle: "Untitled -",
              keywords: [],
              pathToCSVFile: path.join(absolutePathToCopiesDir.path,fileName3)
            );

            // Setting 'wasSessionDataSaved' to true
            await _upu.saveWasSessionDataSaved(true);

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

            // Selecting the 3 added sessions for bulk deletion 
            final firstCheckboxFinder = find.byKey(const ValueKey('checkbox_0'));
            await tester.tap(firstCheckboxFinder);

            final secondCheckboxFinder = find.byKey(const ValueKey('checkbox_1'));
            await tester.tap(secondCheckboxFinder);

            final thirdCheckboxFinder = find.byKey(const ValueKey('checkbox_2'));
            await tester.tap(thirdCheckboxFinder);

            final bulkDeleteButton = find.byKey(const Key('bulk_delete_button'));
            await tester.pumpAndSettle();

            // Searching for 'Delete (3)'
            expect(find.textContaining('Delete (3)'), findsOneWidget);

            // Clicking on the bulk delete button
            await tester.tap(bulkDeleteButton);

            // await tester.pump(const Duration(seconds: 3));

            // Restoring the previous session data
            _du.restoreCopiedSessionData
            (
              typeOfContextData: DashboardUtils.contextAnalysesContext, 
              savedData: sessionDataCopy
            );
          }
          catch (e)
          {
            _pu.printd("An exception occured: $e");
            _pu.printd("Restoring session data");
            _du.restoreCopiedSessionData
            (
              typeOfContextData: DashboardUtils.contextAnalysesContext, 
              savedData: sessionDataCopy
            );
          }
        }
      );
    }
  );
}
