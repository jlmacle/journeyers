import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

import 'package:path/path.dart' as path;

import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analyses_dashboard_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';

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
    'Context analysis page tests\n', 
    () 
    {
      
      testWidgets
      (
        skip:true,
        // Testing the presence of the information modal for a newly installed app
        'A newly installed app should display the information modal,\n before starting the first context analysis.', 
        (tester) async 
        {
          // Resetting the information modal status to have the modal displayed
          _upu.resetInformationModalStatus();

          // Launching the widget
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

          // Waiting for preferences to load and the modal to appear
          await tester.pumpAndSettle();

          // Testing the presence of the information modal status
          final modalWidget = find.byKey(const Key('information_modal'));
          // await tester.pump(const Duration(seconds: 3));
          expect(modalWidget, findsOneWidget);

          // Dismissing the modal to avoid the modal appearing at the next "flutter run"
          await tester.tap(modalWidget);
        }
      );

      testWidgets
      ( 
        skip:true,
        // Testing the presence of the context form, without the dashboard, when no session data is stored
        'When no session data is stored, the context form should be displayed,\n without the dashboard.', 
        (tester) async 
        {  
          // Setting 'wasSessionDataSaved' to false
          await _upu.saveWasSessionDataSaved(false);
          
          // Launching the widget
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));
          await tester.pumpAndSettle();

          // Testing that the dashboard is not present
          final dashboardWidget = find.byKey(const Key('analyses_dashboard'));
          expect(dashboardWidget, findsNothing);

          // Testing that the context form is present (+ pause for visual inspection)
          final formWidget = find.byKey(const Key('form'));
          // await tester.pump(const Duration(seconds: 3));
          expect(formWidget, findsOne);
           
          // Was there stored data, to reset the preferences if needed?
          // Getting the information
          final sessionData = await _du.retrieveAllDashboardSessionData
          (typeOfContextData: DashboardUtils.contextAnalysesContext);

          if (sessionData.isEmpty)
            {await _upu.saveWasSessionDataSaved(false);}
          else
            {await _upu.saveWasSessionDataSaved(true);}
        }
      );

      testWidgets
      ( 
        // Testing the bulk deletion of session data
        'When checkboxes are checked, the session data is marked for bulk deletion.\n'
        'When the "Delete" text is clicked, the deleted sessions should be removed from the displayed session data.\n'
        'Also, the keywords displayed should be updated accordingly (TO FINISH).\n'
        'The session data stored should be consistent with the deletions.\n'
        'Files physical deletion needs to be visually confirmed.',
        (tester) async 
        { 
          // Starting fresh with new copies of the test files
          Directory sourceDir = Directory("./integration_test/test_files/source");
          Directory copiesDir = Directory("./integration_test/test_files/copies");

          if (!copiesDir.existsSync()) {;await copiesDir.create();}
          
          // Emptying and recreating the copies folder
          if (await copiesDir.exists()) 
          {
            final entriesInCopiesDir = await copiesDir.list().toList();
            if (entriesInCopiesDir.isNotEmpty) 
            {
              // Deleting everything inside the copies folder and recreating the directory
              await copiesDir.delete(recursive: true);
              await copiesDir.create();
            }
          }
          else {throw Exception('$copiesDir does not exist.');}

          // Copying the source files in the copies folder
          await for (var entity in sourceDir.list(recursive: true)) 
          {
            if (entity is File) 
            {
              final relativePath = path.relative(entity.path, from: sourceDir.path);
              final newPath = path.join(copiesDir.path, relativePath);
              
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
              pathToCSVFile: "./integration_test/test_files/copies/file.txt"
            );
            // data 2
            await _du.saveDashboardData
            (
              typeOfContextData: DashboardUtils.contextAnalysesContext,
              analysisTitle: "Untitled -",
              keywords: [],
              pathToCSVFile: "./integration_test/test_files/copies/file2.txt"
            );
            // data 3
            await _du.saveDashboardData
            (
              typeOfContextData: DashboardUtils.contextAnalysesContext,
              analysisTitle: "Untitled -",
              keywords: [],
              pathToCSVFile: "./integration_test/test_files/copies/file3.txt"
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