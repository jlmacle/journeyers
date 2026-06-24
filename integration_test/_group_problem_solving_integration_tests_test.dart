import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_sessions_list_item.dart';

// TODO: to clean
import '../test/helper_functions/externalized_testing_code.dart';
import 'externalized_code/integration_test_utils.dart';

// Used to define a folder value for getApplicationSupportPath (PathProvider) 
class PathProviderPlatformRedirectForTesting extends PathProviderPlatform {
  PathProviderPlatformRedirectForTesting(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

// ─── Helper function ──────────────────────────────────────────────────────────────────

/// Wraps the widget under test inside the mandatory Material / Directionality /
/// Localizations ancestors that several Flutter widgets require.
///
/// Providing [AppLocalizations] delegates ensures that any `AppLocalizations.of(context)`
/// call inside GPSPage (e.g. the first-run AlertDialog) resolves correctly instead
/// of returning null and falling back to the raw fallback string.
Widget buildTestableGPSPage() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: GPSPage(),
  );
}

// ─── Test suite ───────────────────────────────────────────────────────────────

Future<void> main() async {
  // Required by the integration_test package.
  // https://docs.flutter.dev/testing/integration-tests#project-setup
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // On mobile: keeping the app in portrait mode for usability
  if (Platform.isAndroid || Platform.isIOS)
  {
    await SystemChrome.setPreferredOrientations
    ([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown   
    ]);
  }

  // ── Constants ─────────────────────────────────────────────────────────────

  // Titles
  const String testGPSTitleRoot = 'Integration-test GPS session title';
  const String testGPSTitle1 = '$testGPSTitleRoot (1)';
  const String testGPSTitle2 = '$testGPSTitleRoot (2)';
  const String testGPSTitle3 = '$testGPSTitleRoot (3)';
  const List<String> titlesList = [testGPSTitle3, testGPSTitle1, testGPSTitle2];
  const List<String> titlesMaintenance = ["Maintenance topic 1", "Maintenance topic 2", "Maintenance topic 3"];
  const List<String> titlesCompanionship = ["Companionship and Logistics topic", "Companionship and Studies topic"];
  const List<String> titlesWorkplace = ["Workplace and Communication topic"];
  List<String> titlesListKwsSorting = 
                      [
                        titlesMaintenance[0], titlesCompanionship[0], titlesWorkplace[0],
                        titlesCompanionship[1], titlesMaintenance[1], titlesMaintenance[2]
                      ];
  const List<String> titlesListSorted = [testGPSTitle1, testGPSTitle2, testGPSTitle3];

  // Keywords
  const String kwCompanionship = 'Companionship';
  const String kwWorkplace = 'Workplace';
  const String kwStudies = 'Studies';  
  const String kwCommunication = 'Communication';
  const String kwMaintenance = 'Maintenance';
  const String kwLogistics = 'Logistics';
  const List<String> kwsList = [kwCompanionship, kwWorkplace];
  const List<List<String>> kwsListsKwsSorting = 
                    [
                      [kwMaintenance], [kwCompanionship, kwLogistics], [kwWorkplace, kwCommunication],
                      [kwCompanionship, kwStudies], [kwMaintenance], [kwMaintenance],
                    ];

  // Ideas
  const ideasList1 = ['idea1', 'idea2'];

  // File names
  const String fileName1WithoutExtension = 'file1';
  const String fileName2WithoutExtension = 'file2';
  const String fileName3WithoutExtension = 'file3';
  const List<String> fileNamesWithoutExtensionList = [fileName1WithoutExtension, fileName2WithoutExtension, fileName3WithoutExtension];

  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;
  
  setUp(() async {
    // Creating a temporary folder to store the files to save
    testTmpDir = await Directory.systemTemp.createTemp('group_problem_solving_integration_test_');
    PathProviderPlatform.instance = PathProviderPlatformRedirectForTesting(testTmpDir!.path);
    // To use the alternative saving/reading file paths or to intercept the way the date is saved
    runningTests = true;
    dateIndex = 0;
  });

  // This function will be called after each test is run. The body may be asynchronous; if so, it must return a Future.
  tearDown(() async {
    if (testTmpDir!.existsSync()) {
      // Deleting the temporary folder created to store the saved files
      await testTmpDir!.delete(recursive: true);
    }
  });

  // ── Test cases ─────────────────────────────────────────────────────────────

  group('Group Problem-Solving Integration Tests: Mobile: \n', () 
  {
    group('Preview Tests: Mobile: \n', () 
    {
      // 'Session data entered is found on the preview'
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
        'Session data entered is found on the preview'
        '(assuming an already selected path to the user session data folder)',
        (WidgetTester tester) async {

          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // To have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
            // Temporary test dir as application folder path
            'applicationFolderPath': testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            //
            // pumpWidget renders the first frame.
            // pumpAndSettle drives the event loop until there are no more pending frames,
            // letting the async getPreferences() call complete 
            // and setState(() { _preferencesLoading = false; }) rebuild the tree.
            //
            
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 3));

            // ── 1. ENTERING NEW GPS PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────

            await gpsEnterNewProcessData
            (
              tester: tester, 
              title: testGPSTitle1,
              kwsList: kwsList,
              ideasList: ideasList1,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 5));

            // ── 2. SEARCHING FOR THE SESSION DATA ON THE DASHBOARD  ────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────
            // Searching for the title and keywords
            
            // To avoid intermittent test failures
            await tester.pump(const Duration(seconds: 2));
            await dashboardSearchTitleAndKeywords(title: testGPSTitle1, kws: kwsList, titleSuffix: gpsTitleSuffix);

            // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────────
            await tester.pump(const Duration(seconds: 2));
            await gpsTestPreview(tester: tester, title: testGPSTitle1, ideasList: ideasList1);

            // await tester.pump(const Duration(seconds: 2));

          }
        }
      );
    });

    group('Deletion Tests: Mobile: \n', ()
    {
      // 'Deletion: Single deletion with icon \n'
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
        'Deletion: Single deletion with icon \n'
        '(assuming an already selected path to the user session data folder)',
        (WidgetTester tester) async {

          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
            // Temporary test dir as application folder path
            'applicationFolderPath': testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            //
            // pumpWidget renders the first frame.
            // pumpAndSettle drives the event loop until there are no more pending frames,
            // letting the async getPreferences() call complete 
            // and setState(() { _preferencesLoading = false; }) rebuild the tree.
            //
            
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW GPS PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterNewProcessData
            (
              tester: tester, 
              title: testGPSTitle1,
              kwsList: kwsList,
              ideasList: ideasList1,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────
            // Searching for the finder with the title
            Finder sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester,title: testGPSTitle1, titleSuffix: gpsTitleSuffix);
            expect(sessionListItemFinder, findsOne);

            // ── 3. TESTING THE DELETION ────────────────────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────────
            
            // Searching for the tooltip 
            var deleteIconFinder = find.byTooltip(deleteTooltipLabel);

            // Tapping the icon
            await tester.tap(deleteIconFinder);
            await tester.pumpAndSettle();

            // Verifying the sessions list item absent
            sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: testGPSTitle1, titleSuffix: gpsTitleSuffix);
            expect(sessionListItemFinder, findsNothing);
      
            // await tester.pump(const Duration(seconds: 2));
          }
        }      
      );

      // 'Deletion: Bulk deletion \n'
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
        'Deletion: Bulk deletion \n'
        '(assuming an already selected path to the user session data folder)',
        (WidgetTester tester) async {

          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
            // Temporary test dir as application folder path
            'applicationFolderPath': testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            //
            // pumpWidget renders the first frame.
            // pumpAndSettle drives the event loop until there are no more pending frames,
            // letting the async getPreferences() call complete 
            // and setState(() { _preferencesLoading = false; }) rebuild the tree.
            //
            
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW GPS PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterSeveralTimesNewProcessData
            (
              tester: tester,
              titlesList: titlesList,
              kwsLists: [[], [], []],
              ideasList: [ideasList1, ideasList1, ideasList1],
              fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
            );

            // ── 2. SEARCHING FOR THE TILES with title 1 and title 2 TO CHECK ON THE DASHBOARD  ─
            // Searching and tapping the checkboxes for title 1 and title 2
            var checkbox1Finder = find.descendant
            (
              of: find.ancestor(of: find.text("$testGPSTitle1$gpsTitleSuffix"), matching: find.byType(SessionsListItem)), 
              matching: find.byType(Checkbox)
            );
            // Needed more than ensureVisible
            await scrollListUpScrollableByFirstDescendant(tester: tester, listFinder: find.byType(CustomScrollView), elementToReachFinder: checkbox1Finder);
            await tester.tap(checkbox1Finder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

           var checkbox2Finder = find.descendant
            (
                of: find.ancestor(of: find.text("$testGPSTitle2$gpsTitleSuffix"), matching: find.byType(SessionsListItem)), 
                matching: find.byType(Checkbox)
            );
            await tester.ensureVisible(checkbox2Finder);
            await tester.tap(checkbox2Finder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            // ── 3. BULK DELETION ─────────────────────────────────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────────────────
            // Searching the widget
            var bulkDeletionFinder = find.textContaining('Delete');
            expect(bulkDeletionFinder, findsOne);
            await tester.ensureVisible(bulkDeletionFinder);
            await tester.tap(bulkDeletionFinder);
            await tester.pumpAndSettle();

            // ── 4. TESTING THE DELETION ────────────────────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────────       
            // Checking the number of list items left 
            var sessionsListItemsFinder = find.byType(SessionsListItem);
            expect(sessionsListItemsFinder, findsOne);

            // Verifying title 3 remains
            var title3WithSuffix = "$testGPSTitle3$gpsTitleSuffix";
            var textFinder = find.text(title3WithSuffix);
            Text textWidget = tester.widget(textFinder);
            expect(textWidget.data, title3WithSuffix);

            // await tester.pump(const Duration(seconds: 2));
          }
        }      
      );      
    });

    group('Sorting and filtering: Mobile: \n', ()
    {
      // 'Sorting by title \n'
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
        'Sorting by title \n'
        '(assuming an already selected path to the user session data folder)',
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
            // Temporary test dir as application folder path
            'applicationFolderPath': testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            //
            // pumpWidget renders the first frame.
            // pumpAndSettle drives the event loop until there are no more pending frames,
            // letting the async getPreferences() call complete 
            // and setState(() { _preferencesLoading = false; }) rebuild the tree.
            //
            
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW GPS PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterSeveralTimesNewProcessData
            (
              tester: tester,
              titlesList: titlesList,
              kwsLists: [[], [], []],
              ideasList: [ideasList1, ideasList1, ideasList1],
              fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
            );
            // await tester.pump(const Duration(seconds: 2));
          
            // ── 2. SORTING BY TITLE ──────────────────────────────────
            // ────────────────────────────────────────────────────────
            // Triggering the sort
            var sortByTitleFinder = find.textContaining(sortByTitleLabel);
            await tester.tap(sortByTitleFinder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            // Searching the titles          
            var titlesFinder = await dashboardGetAllSessionsTitles(tester);        

            var totalTitles = titlesFinder.evaluate().length;
            if (testingDebug) pu.printd('Testing Debug: totalTitles: $totalTitles');

            // Verifying the alphabetical order
            for (var index = 0; index < totalTitles; index++)
            {
              expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesListSorted[index]}$gpsTitleSuffix");
            }

            // Re-triggering the sort
            await tester.tap(sortByTitleFinder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            // Re-searching the titles  
            titlesFinder = await dashboardGetAllSessionsTitles(tester); 

            // Verifying the alphabetical order 
            for (var index = 0; index < totalTitles; index++)
            {
              expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesListSorted.reversed.toList()[index]}$gpsTitleSuffix");
            }
          }          
        }
      );
      
      // 'Sorting by date \n'
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
        'Sorting by date \n'
        '(assuming an already selected path to the user session data folder)',
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
            // Temporary test dir as application folder path
            'applicationFolderPath': testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            //
            // pumpWidget renders the first frame.
            // pumpAndSettle drives the event loop until there are no more pending frames,
            // letting the async getPreferences() call complete 
            // and setState(() { _preferencesLoading = false; }) rebuild the tree.
            //
            
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW GPS PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterSeveralTimesNewProcessData
            (
              tester: tester,
              titlesList: titlesList,
              kwsLists: [[], [], []],
              ideasList: [ideasList1, ideasList1, ideasList1],
              fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
            );
            // await tester.pump(const Duration(seconds: 2));
          
            // ── 2. SORTING BY DATE ──────────────────────────────────
            // ────────────────────────────────────────────────────────
            // Triggering the sort
            var sortByDateFinder = find.textContaining(sortByDateLabel);
            await tester.tap(sortByDateFinder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            // Searching the dates          
            var datesFinder = find.byWidgetPredicate
            (
              (widget) 
              {
                if (widget.key is ValueKey<String>) {
                  return (widget.key as ValueKey<String>).value.contains('session-date-');
                }
                return false;
              }
            );          

            var totalDates = datesFinder.evaluate().length;
            if (testingDebug) pu.printd('Testing Debug: totalDates: $totalDates');

            // Verifying the alphabetical order
            for (var index = 0; index < totalDates; index++)
            {
              expect((tester.widget<Text>(datesFinder.at(index)).data), "(${constJanuaryDatesListSorted[index]})");
            }

            // Re-triggering the sort
            await tester.tap(sortByDateFinder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            datesFinder = find.byWidgetPredicate
            (
              (widget) 
              {
                if (widget.key is ValueKey<String>) {
                  return (widget.key as ValueKey<String>).value.contains('session-date-');
                }
                return false;
              }
            );          

            // Verifying the alphabetical order 
            for (var index = 0; index < totalDates; index++)
            {
              expect((tester.widget<Text>(datesFinder.at(index)).data), "(${constJanuaryDatesListSorted.reversed.toList()[index]})");
            }
          }
        });
    
      // 'Filtering by keywords \n'
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
          'Filtering by keywords \n'
          '(assuming an already selected path to the user session data folder)',
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
              // Temporary test dir as application folder path
              'applicationFolderPath': testTmpDir!.path
            });

            if (Platform.isAndroid || Platform.isIOS)
            {
              // Pumping the GPSPage
              //
              // pumpWidget renders the first frame.
              // pumpAndSettle drives the event loop until there are no more pending frames,
              // letting the async getPreferences() call complete 
              // and setState(() { _preferencesLoading = false; }) rebuild the tree.
              //
              
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── 1. ENTERING NEW GPS PROCESS DATA (6 times) ──────────────────────────────────
              // ───────────────────────────────────────────────────────────────────────────────
              
              await gpsEnterSeveralTimesNewProcessData
              (
                tester: tester,
                titlesList: titlesListKwsSorting,
                kwsLists: kwsListsKwsSorting,
                ideasList: [ideasList1, ideasList1, ideasList1, ideasList1, ideasList1, ideasList1],
                fileNamesWithoutExtensionList: List.generate(6, (i)=> 'file${i+1}')
              );
              await tester.pump(const Duration(seconds: 4));
            
              // ── 2. FILTERING BY KEYWORDS ────────────────────────────
              // ────────────────────────────────────────────────────────

              // 1. Filtering by kwMaintenance
              var kwMaintenanceFinder = await dashboardGetKwFilterChip(tester, kwMaintenance);
              await tester.tap(kwMaintenanceFinder);
              await tester.pumpAndSettle();

              // Verifying the titles present
              var titlesFinder = await dashboardGetAllSessionsTitles(tester);
              var totalTitles = titlesFinder.evaluate().length;

              if (testingDebug) pu.printd('Testing Debug: totalTitles for $kwMaintenance: $totalTitles');

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesMaintenance.reversed.toList()[index]}$gpsTitleSuffix");
              }
              // Un-selecting the keyword
              await tester.tap(kwMaintenanceFinder);
              await tester.pumpAndSettle();

              // 2. Filtering by kwCompanionship
              var kwCompanionshipFinder = await dashboardGetKwFilterChip(tester, kwCompanionship);
              await tester.tap(kwCompanionshipFinder);
              await tester.pumpAndSettle();

              // Verifying the titles present
              titlesFinder = await dashboardGetAllSessionsTitles(tester);
              totalTitles = titlesFinder.evaluate().length;

              if (testingDebug) pu.printd('Testing Debug: totalTitles for $kwCompanionship: $totalTitles');

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesCompanionship.reversed.toList()[index]}$gpsTitleSuffix");
              }

              // Un-selecting the keyword
              await tester.tap(kwCompanionshipFinder);
              await tester.pumpAndSettle();

              // 3. Filtering by kwWorkplace
              var kwWorkplaceFinder = await dashboardGetKwFilterChip(tester, kwWorkplace);
              await tester.tap(kwWorkplaceFinder);
              await tester.pumpAndSettle();

              // Verifying the titles present
              titlesFinder = await dashboardGetAllSessionsTitles(tester);
              totalTitles = titlesFinder.evaluate().length;

              if (testingDebug) pu.printd('Testing Debug: totalTitles for $kwWorkplace: $totalTitles');

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesWorkplace.reversed.toList()[index]}$gpsTitleSuffix");
              }
              

              await tester.pump(const Duration(seconds: 2));
            }
          });     
    
    });

});
}