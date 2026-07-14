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
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/test_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/editable_deletable_text_list_item.dart';
import 'package:journeyers/widgets/utility/dashboard/dashboard_widgets/4_dashboard_sessions_list_item.dart';
import 'package:journeyers/widgets/utility/dashboard/dashboard_widgets/dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/lists/list_dashboard_const_strings.dart' show emptyLabelEditError, emptyParticipantsListError, listsDashboardTitle, listsSortByLabel, loadingButtonLabel, saveButtonLabel, listsDeleteTooltipLabel;
import 'package:journeyers/widgets/utility/lists/new_text_list_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_or_loading_page_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/4_list_of_lists_item.dart';
import 'package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart';

import 'externalized_code/externalized_testing_code.dart';

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

  // Edition
  const String editionSuffix = "-edited";

  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;
  
  setUp(() async {
    // Creating a temporary folder to store the files to save
    testTmpDir = await Directory.systemTemp.createTemp('group_problem_solving_integration_test_');
    PathProviderPlatform.instance = PathProviderPlatformRedirectForTesting(testTmpDir!.path);
    // To intercept the way the date is saved
    dateForTestingIndex = 0;
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
    group('Entered metadata is displayed on the dashboard: Mobile: \n', ()
    {
    // 'Session metadata entered (title, keywords, date) is found: '
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
      'Session metadata entered (title, keywords, date) is found: '
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
          
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── 1. ENTERING NEW GPS PROCESS DATA ───────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────
          await gpsEnterNewProcessDataOnMobile
                (
                  tester: tester, 
                  title: testGPSTitle1,
                  kwsList: kwsList,
                  ideasList: ["at least one idea needed"],
                  fileNameWithoutExtension: fileName1WithoutExtension
                );

          // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords          
            // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2)); 
          // todo: a dashboardSearchMetadata
          await dashboardSearchTitleAndKeywords(title: "${testGPSTitle1}${gpsTitleSuffix}", kws: kwsList);

          // Searching for the date
          dateForTestingIndex = 0;
          expect(find.textContaining(datesForTestingList[0]), findsOne);
        }
      }); 
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
            var sortByTitleFinder = find.textContaining(sortByTitle);
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
            var sortByDateFinder = find.textContaining(sortByDate);
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

            // Verifying the order
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

            // Verifying the order 
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
              // await tester.pump(const Duration(seconds: 4));
            
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

              // await tester.pump(const Duration(seconds: 2));
            }
          });     
    
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
            
            await gpsEnterNewProcessDataOnMobile
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

            // Verifying the Filter Chip present
            var filterChipFinder = find.descendant
            (
              of: find.byType(FilterChip), 
              matching: find.text(kwCompanionship)
            );
            expect(filterChipFinder, findsOne);


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

            // Verifying the Filter Chip absent
            filterChipFinder = find.descendant
            (
              of: find.byType(InputChip), 
              matching: find.text(kwCompanionship)
            );
            expect(filterChipFinder, findsNothing);      
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
              // const List<String> titlesList = [testGPSTitle3, testGPSTitle1, testGPSTitle2];
              titlesList: titlesList,
              kwsLists: [["kw3"], ["kw1"], ["kw2"]],
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

            // Verifying the Filter Chips present
            var filterChipFinder = find.byType(FilterChip);
            expect(filterChipFinder, findsNWidgets(3));

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

            // Verifying that only kw3 is present
            filterChipFinder = find.byType(FilterChip);
            expect(filterChipFinder, findsNWidgets(1));
            expect(find.text("kw3"), findsOne);

            // await tester.pump(const Duration(seconds: 2));
          }
        }      
      );      
    });
  
    group('Preview Tests: Mobile: \n', () 
    {
      // 'Session data entered is found on the preview'
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
        'Session data entered is found on the preview \n'
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
            // await tester.pump(const Duration(seconds: 3));

            // ── 1. ENTERING NEW GPS PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────

            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: testGPSTitle1,
              kwsList: kwsList,
              ideasList: ideasList1,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 5));
            
            // ── 2. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────────
            await tester.pump(const Duration(seconds: 2));
            await gpsTestPreview(tester: tester, title: testGPSTitle1, ideasList: ideasList1);

            // await tester.pump(const Duration(seconds: 2));

          }
        }
      );
    });

    // todo: to finish/clean: from dashboard/preview    
    group('Edition Tests: Preview: Mobile: \n', ()
    {
      
      // 'Group problem-solving data edition \n'
      testWidgets(
        'Group problem-solving data edition \n',
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
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            // ── 1. ENTERING NEW GPS PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────
            var titleEdition = "GPS title";
            var keywordsEdition = kwsList; 
            var idea3Added = "idea3-edited";
            
            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: titleEdition,
              kwsList: keywordsEdition,
              ideasList: ideasList1,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 2));

            // ── 2. CLICKING TO OPEN THE PREVIEW  ─────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────
            // Opening the preview
            var previewFinder = find.byTooltip(previewTooltipLabel);
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();

            // ── 3. CLICKING TO START THE EDIT MODE  ──────────────────────────────
            // ─────────────────────────────────────────────────────────────────────
            // Opening the edition overlay
            var editIconFinder = find.byIcon(Icons.edit);
            await tester.tap(editIconFinder);
            await tester.pumpAndSettle();

            // ── 4. EDITION: Verifying data present and editing  ─────────────────
            // ────────────────────────────────────────────────────────────────────

            // ── Verifying the title present ─────────────
            // ────────────────────────────────────────────
            expect(find.text(titleEdition), findsOne);

            // ── Verifying the keywords present ──────────
            // ────────────────────────────────────────────
              // Opening the keywords overlay
            var keywordsWidgetTitleFinder = find.text(keywordsDeclarationTitle);
            await tester.tap(keywordsWidgetTitleFinder);
            await tester.pumpAndSettle();
              // Verifying the keywords present
              for (var kw in keywordsEdition)
              {
                expect(find.text(kw), findsOne);
              }
              // Closing the keywords overlay
              var closeKeywordsDeclarationTooltipLabelFinder = find.byTooltip(closeKeywordsDeclarationTooltipLabel);
              await tester.tap(closeKeywordsDeclarationTooltipLabelFinder);
              await tester.pumpAndSettle();

            // ── Verifying the ideas present ─────────────
            // ────────────────────────────────────────────
            for (var idea in ideasList1)
            {
              expect(find.textContaining(idea), findsNWidgets(1));
            }            

            // ── Editing data ────────────────────────────
            // ────────────────────────────────────────────

            // const ideasList1 = ['idea1', 'idea2'];         
            // ── Editing idea1 : suffix addition ───────────────────────────────────
            // ─────────────────────────────────────────────────────
              // Searching idea1
            var idea1Finder = find.text(ideasList1[0]);
            await tester.ensureVisible(idea1Finder);
            await tester.pumpAndSettle();   
              // Tapping on the idea to open the edition overlay
            await tester.tap(idea1Finder);
            await tester.pumpAndSettle();

            var editableDeletableTextListItemFinder = find.byType(EditableDeletableTextListItem);
            var totalEditableDeletableTextListItemFinder = editableDeletableTextListItemFinder.evaluate().length;
            if (testingDebug) pu.printd('Testing Debug: totalEditableDeletableTextListItemFinder: $totalEditableDeletableTextListItemFinder');

              // Searching the editable/deletable field for idea1
            var idea1EditableDeletableFinder = find.byKey(const ValueKey('text0'));   // todo: to clean           
            await tester.tap(idea1EditableDeletableFinder);
            await tester.pumpAndSettle();

            // ── Adding idea1: modification  ─────────────────────
            // ────────────────────────────────────────────────────
            var tfIdea1Finder = find.byKey(const ValueKey('editable-deletable-tf-0'));
            await tester.enterText(tfIdea1Finder, "${ideasList1[0]}$editionSuffix");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));  
            if (testingDebug) pu.printd('Testing Debug: idea1 edited');

            // ── Editing idea2 : deletion ─────────────────────────
            // ─────────────────────────────────────────────────────
              // Searching idea2
              // Searching the editable/deletable checkbox for idea2
            var idea2EditableDeletableFinder = find.byKey(const ValueKey('editable-deletable-checkbox-1'));   // todo: to clean           
            await tester.ensureVisible(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
            await tester.tap(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
              // Deleting 
            var deleteFinder = find.textContaining('Delete');
            await tester.tap(deleteFinder);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 10));
            
            if (testingDebug) pu.printd('Testing Debug: idea2 deleted');
              // Waiting on Snackbar removal
            await tester.pump(const Duration(seconds: 5));

            // ── Adding idea3: addition  ─────────────────────────
            // ────────────────────────────────────────────────────
            var ideaOverlayTextFieldFinder = find.byKey(const ValueKey('ideaOverlayTextField'));
            await tester.enterText(ideaOverlayTextFieldFinder, idea3Added);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));             
            if (testingDebug) pu.printd('Testing Debug: idea3 added');  

            // ── Closing the ideas list  ───────────────────────
            // ───────────────────────────────────────────────────
            var closeFinder = find.byIcon(Icons.close);  
            await tester.tap(closeFinder);
            await tester.pumpAndSettle();

            // ── Submitting new data  ───────────────────────
            // ───────────────────────────────────────────────
              // Searching the file name text field
            var sessionFileNameOnMobilePlatformsFinder = find.byType(SessionFileNameOnMobilePlatforms);
            await tester.tap(sessionFileNameOnMobilePlatformsFinder);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

             await tester.pump(const Duration(seconds: 2));

            // ── 5. VERIFICATION  ─────────────────
            // ─────────────────────────────────────   
            // ── Verifying the edited/added data present ────────────
            await gpsTestPreview(tester: tester, title: titleEdition, ideasList: ["${ideasList1[0]}${editionSuffix}", idea3Added]);
               
          } // if platform

        });
    });

  group('Participants-related Tests: \n', () 
  {
    var name1 = "Bob";
    var name2 = "Alice";
    var name3 = "Ben";
    var name4 = "Jane";
    List<String> names1 = [name1, name2];
    List<String> names2 = [name2, name4];
    List<String> names3 = [name1, name3];
    var listLabel1 = "List1";
    var listLabel2 = "List2";
    var listLabel3 = "List3";
    var listLabelsSorted = [listLabel1, listLabel2, listLabel3];
    var keywords1 = [kwCompanionship];
    var keywords2 = [kwWorkplace];
    var titlesCompanionship = [listLabel1];
    var titlesWorkplace = [listLabel2, listLabel3];

    group('New Participants List Tests: \n', () 
    {
      group('New Participants List Saving: \n', () 
      {

        group('New Participants List Labels/Content: \n', () 
        {
          // 'Lists labels must be unique
          testWidgets('Lists labels must be unique', 
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

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names1,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);    

            // Waiting on the "list saved" snackbar
            await tester.pump(const Duration(seconds: 3));  
        
            // ── ADDING MORE PARTICIPANTS TO SAVE UNDER THE SAME LIST NAME ────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);
            
            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const ValueKey('participantNameField'));
            expect(newParticipantTextFieldFinder, findsOne);
            await tester.ensureVisible(newParticipantTextFieldFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(newParticipantTextFieldFinder);
            await tester.pumpAndSettle();

            // Adding the names
            for (var name in names2)
            {   
              // Adding the name
              await tester.enterText(newParticipantTextFieldFinder, name);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();
              // Necessary for the next name to be added
              await tester.tap(newParticipantTextFieldFinder);
              await tester.pumpAndSettle();
            }

            // Verifying the names present
            for (var name in names2)
            {
              expect(find.text(name), findsOne);    
            }      

            // Searching the 'Save' icon
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsOne);

            // Tapping on it
            await tester.tap(saveListIconFinder);
            await tester.pumpAndSettle();

            // Searching the text field to add the same list name
            var listNameSavingTextFieldFinder = find.byKey(const ValueKey('saveListField'));
            expect(listNameSavingTextFieldFinder, findsOne);

            // Adding the same list name
            await tester.ensureVisible(listNameSavingTextFieldFinder);
            await tester.tap(listNameSavingTextFieldFinder);
            await tester.enterText(listNameSavingTextFieldFinder, listLabel1);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Searching for the error message
            var listAlreadySavedErrorFinder = find.textContaining(listAlreadySavedErrorEndPart);
            expect(listAlreadySavedErrorFinder, findsOne);

            // Verifying transition to GPS process page absent
            expect(find.text(checkListTitle), findsNothing);
          });            
        
          // 'Lists labels must be non empty'
          testWidgets('Lists labels must be non empty', 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and ATTEMPTING TO SAVE THE LIST  ──────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);
            
            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const ValueKey('participantNameField'));
            expect(newParticipantTextFieldFinder, findsOne);
            await tester.ensureVisible(newParticipantTextFieldFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(newParticipantTextFieldFinder);
            await tester.pumpAndSettle();

            // Adding the names
            for (var name in names1)
            {   
              // Adding the name
              await tester.enterText(newParticipantTextFieldFinder, name);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();
              // Necessary for the next name to be added
              await tester.tap(newParticipantTextFieldFinder);
              await tester.pumpAndSettle();
            }

            // Verifying the names present
            for (var name in names1)
            {
              expect(find.text(name), findsOne);    
            }      

            // await tester.pump(const Duration(seconds: 5));

            
            // Searching the 'Save' icon
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsOne);

            // Tapping on it
            await tester.tap(saveListIconFinder);
            await tester.pumpAndSettle();

            // Searching the text field to add an empty list name
            var listNameSavingTextFieldFinder = find.byKey(const ValueKey('saveListField'));
            expect(listNameSavingTextFieldFinder, findsOne);

            // Adding an empty list name
            await tester.ensureVisible(listNameSavingTextFieldFinder);
            await tester.tap(listNameSavingTextFieldFinder);
            await tester.enterText(listNameSavingTextFieldFinder, "");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Searching for the error message
            var labelEmptyErrorFinder = find.textContaining(emptyLabelError);
            expect(labelEmptyErrorFinder, findsOne);

            // Verifying transition to GPS process page absent
            expect(find.text(checkListTitle), findsNothing);    
          });            
        
          // 'List content must be unique (without reversed order when adding 2nd list)'
          testWidgets('List content must be unique (without reversed order when adding 2nd list)', 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names1,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // Waiting on the "list saved" snackbar
            await tester.pump(const Duration(seconds: 3));

            // ── ADDING THE SAME PARTICIPANTS TO SAVE UNDER ANOTHER LIST NAME ────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);
            
            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const ValueKey('participantNameField'));
            expect(newParticipantTextFieldFinder, findsOne);
            await tester.ensureVisible(newParticipantTextFieldFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(newParticipantTextFieldFinder);
            await tester.pumpAndSettle();

            // Adding the same names
            for (var name in names1)
            {   
              // Adding the name
              await tester.enterText(newParticipantTextFieldFinder, name);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();
              // Necessary for the next name to be added
              await tester.tap(newParticipantTextFieldFinder);
              await tester.pumpAndSettle();
            }

            // Verifying the names present
            for (var name in names1)
            {
              expect(find.text(name), findsOne);    
            }      

            // await tester.pump(const Duration(seconds: 5));

            // Verifying the 'Save' icon absent
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsNothing);        
          });            
        
          // 'List content must be unique (with reversed order when adding 2nd list)'
          testWidgets('List content must be unique (with reversed order when adding 2nd list)', 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names1,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);

            // Waiting on the "list saved" snackbar
            await tester.pump(const Duration(seconds: 3));      
        
            // ── ADDING THE SAME PARTICIPANTS TO SAVE UNDER ANOTHER LIST NAME ────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);
            
            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const ValueKey('participantNameField'));
            expect(newParticipantTextFieldFinder, findsOne);
            await tester.ensureVisible(newParticipantTextFieldFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(newParticipantTextFieldFinder);
            await tester.pumpAndSettle();

            // Adding the same names, entered in a reversed order
            for (var name in names1.reversed)
            {   
              // Adding the name
              await tester.enterText(newParticipantTextFieldFinder, name);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();
              // Necessary for the next name to be added
              await tester.tap(newParticipantTextFieldFinder);
            }

            // Verifying the names present
            for (var name in names1)
            {
              expect(find.text(name), findsOne);    
            }      

            // await tester.pump(const Duration(seconds: 5));

            // Verifying the 'Save' icon absent
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsNothing);        
          });            
        
          // 'Names are displayed in the order added (names in alphabetical order)'
          testWidgets('Names are displayed in the order added (names in alphabetical order)', 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            var names = ['a', 'b', 'c'];
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // ── VERIFYING THE ORDER  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────
            var listItemsFinder = await gpsGetNewListTextItems(tester);

            var totalItems = listItemsFinder.evaluate().length;
            if (testingDebug) pu.printd('Testing Debug: totalItems: $totalItems');

            for (var itemIndex = 0; itemIndex < totalItems; itemIndex++)
            {
              expect(tester.widget<Text>(listItemsFinder.at(itemIndex)), names[itemIndex]);
            }
                
          });            
        
          // 'Names are displayed in the order added (names not in alphabetical order)'
          testWidgets('Names are displayed in the order added (names not in alphabetical order)', 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            var names = ['c', 'b', 'a'];
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // ── VERIFYING THE ORDER  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────
            var listItemsFinder = await gpsGetNewListTextItems(tester);

            var totalItems = listItemsFinder.evaluate().length;
            if (testingDebug) pu.printd('Testing Debug: totalItems: $totalItems');

            for (var itemIndex = 0; itemIndex < totalItems; itemIndex++)
            {
              expect(tester.widget<Text>(listItemsFinder.at(itemIndex)), names[itemIndex]);
            }
                
          });            
        
          // Todo: To find a better integration tests/widget tests organization
          // 'Keywords can be added/removed'
          testWidgets('Keywords can be added/removed', 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── REACHING THE NEW PARTICIPANTS LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            await gpsFromProcessPageToNewParticipantsListPage(tester);

            // ── ADDING KEYWORDS  ──────────────────────────────────
            // ──────────────────────────────────────────────────────
              // Searching the keywordsDeclarationTitle
            var keywordsDeclarationTitleFinder = find.text(keywordsDeclarationTitle);
            await tester.tap(keywordsDeclarationTitleFinder);
            await tester.pumpAndSettle();
              // Adding two keywords
            var keywords = ["kw1", "kw2"];
                // Searching the text field
            var keywordTfecFinder = find.byKey(const ValueKey('keywordField'));
            for (var kw in keywords)
            {
              await tester.enterText(keywordTfecFinder, kw);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();
              await tester.tap(keywordTfecFinder);
              await tester.pumpAndSettle();
            }

            // ── REMOVING A KEYWORD  ───────────────────────────────
            // ──────────────────────────────────────────────────────
            var kw1ClosingFinder = 
            find.descendant
            (
              of: find.ancestor
                      (
                        of: find.text("kw1"), 
                        matching: find.byType(InputChip)
                      ), 
              matching: find.byIcon(Icons.close)
            );
            
            await tester.tap(kw1ClosingFinder);
            await tester.pumpAndSettle();

            // ── VERIFYING KW2 REMAINING  ────────────────────
            // ────────────────────────────────────────────────
            expect(find.byType(InputChip), findsOne);
            expect(find.text("kw2"), findsOne);   

            // ── CLOSING THE OVERLAY  ────────────────────
            // ────────────────────────────────────────────
            var closeOverlayFinder = find.byTooltip(closeKeywordsDeclarationTooltipLabel);
            await tester.tap(closeOverlayFinder); 
            await tester.pumpAndSettle();   

            // ── ADDING A PARTICIPANT  ──────────────────
            // ───────────────────────────────────────────
            var participantNameFieldFinder = find.byKey(const ValueKey('participantNameField'));
            await tester.enterText(participantNameFieldFinder, "Bob");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // ── SAVING THE LIST  ──────────────────
            // ──────────────────────────────────────
            var saveListFinder = find.byTooltip('Save list');
            await tester.tap(saveListFinder);
            await tester.pumpAndSettle();
              // Entering the list name
            var saveListFieldFinder = find.byKey(const ValueKey('saveListField'));
            await tester.enterText(saveListFieldFinder, "list name");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 5));  

            // ── GOING TO THE LIST LOADING PAGE  ──
            // ─────────────────────────────────────
            await gpsFromProcessPageToListLoadingDashboard(tester);

            // ── VERIFYING THE KEYWORD PRESENT ──
            // ───────────────────────────────────
            expect(find.byType(Card), findsOne);
            expect(find.text("kw1"), findsNothing);
            expect(find.text("kw2"), findsOne);            

            // await tester.pump(const Duration(seconds: 5));                
          });            
        
        }); 
      
        group('New Participants List Saving: \n', () 
        {
          // "1. Participants can be added, keywords added, the data saved in a list, 
          // and the participants' names are loaded in the GPS process page"
          testWidgets("1. Participants can be added, keywords added, the data saved in a list, "
                      "and the participants' names are loaded in the GPS process page", 
            (WidgetTester tester) async 
            {
                // Setting mock values for SharedPreferences
                SharedPreferences.setMockInitialValues
                ({
                  // Setting value for the first-run modal to be absent,
                  'wasFirstRunModalAcknowledged': true,
                  // and to have the group problem-solving page, with the dashboard.
                  'wasGPSSessionDataSaved': true,
                });

                // Pumping the GPSPage
                await tester.pumpWidget(buildTestableGPSPage());
                await tester.pumpAndSettle();

                // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────
                await gpsFromGPSPageToProcessPage(tester);

                // ── CLICKING TO DISPLAY THE PARTICIPANTS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────────
                // Adding the names
                await gpsFromProcessPageAddParticipants(tester, names1, keywords1);   

                // Verifying the names present
                expect(find.text(name1), findsOne);    
                expect(find.text(name2), findsOne);  

                // Searching the 'Save' icon
                var saveListIconFinder = find.byIcon(Icons.save_outlined);
                expect(saveListIconFinder, findsOne);

                // Tapping on it
                await tester.tap(saveListIconFinder);
                await tester.pumpAndSettle();

                // Searching the text field to add the list name
                var listNameSavingTextFieldFinder = find.byKey(const ValueKey('saveListField'));
                expect(listNameSavingTextFieldFinder, findsOne);

                // Adding a list name
                await tester.ensureVisible(listNameSavingTextFieldFinder);
                await tester.tap(listNameSavingTextFieldFinder);
                await tester.enterText(listNameSavingTextFieldFinder, listLabel1);
                await tester.testTextInput.receiveAction(TextInputAction.done);
                await tester.pumpAndSettle();

                // Verifying the GPS process page present
                expect(find.text(checkListTitle), findsOne);

                // Verifying the names present
                expect(find.text(name1), findsOne);    
                expect(find.text(name2), findsOne);  
              });
        
          // A case that failed at manual testing
          // "2. Participants can be added, keywords added, the data saved in a list, 
          // and the participants' names are loaded in the GPS process page"
          testWidgets("2. Participants can be added, keywords added, the data saved in a list, "
                      "and the participants' names are loaded in the GPS process page", 
            (WidgetTester tester) async 
            {
                // Setting mock values for SharedPreferences
                SharedPreferences.setMockInitialValues
                ({
                  // Setting value for the first-run modal to be absent,
                  'wasFirstRunModalAcknowledged': true,
                  // and to have the group problem-solving page, with the dashboard.
                  'wasGPSSessionDataSaved': true,
                });

                // Pumping the GPSPage
                await tester.pumpWidget(buildTestableGPSPage());
                await tester.pumpAndSettle();

                // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────
                await gpsFromGPSPageToProcessPage(tester);

                // ── CLICKING TO DISPLAY THE PARTICIPANTS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────────
                // Adding the names
                var names = ["Bob", "Alice", "Benny", "Lily"];
                await gpsFromProcessPageAddParticipants(tester, names, [kwCompanionship]);   

                // Verifying the names present
                for (var name in names)
                {
                  expect(find.text(name), findsOne);  
                }                  

                // Searching the 'Save' icon
                var saveListIconFinder = find.byIcon(Icons.save_outlined);
                expect(saveListIconFinder, findsOne);

                // Tapping on it
                await tester.tap(saveListIconFinder);
                await tester.pumpAndSettle();

                // Searching the text field to add the list name
                var listNameSavingTextFieldFinder = find.byKey(const ValueKey('saveListField'));
                expect(listNameSavingTextFieldFinder, findsOne);

                // Adding a list name
                await tester.ensureVisible(listNameSavingTextFieldFinder);
                await tester.tap(listNameSavingTextFieldFinder);
                await tester.enterText(listNameSavingTextFieldFinder, "Our household");
                await tester.testTextInput.receiveAction(TextInputAction.done);
                await tester.pumpAndSettle();

                // Verifying the GPS process page present
                expect(find.text(checkListTitle), findsOne);

                // Verifying the names present
                for (var name in names)
                {
                  expect(find.text(name), findsOne);  
                }   
              });
        
          // Had a multi-list issue at manual testing time
          // "Multi-list: Participants can be added, keywords added, the data saved in a list, 
          //  and the participants' names are loaded in the GPS process page"
          testWidgets("Multi-list: Participants can be added, keywords added, the data saved in a list, "
                      " and the participants' names are loaded in the GPS process page", 
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

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING SEVERAL LISTS OF PARTICIPANTS   ──────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[]}},
                {listLabel2:{"names":names2,"keywords":[]}},
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);
            });

        });         
      });

      group('New Participants List Editing: \n', () 
      {
        // 'Participants names can be edited (while building a new list)'
        testWidgets('Participants names can be edited (while building a new list)', 
        (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING A PARTICIPANT ──────────────────────────────────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);

            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const ValueKey('participantNameField'));
            await tester.ensureVisible(newParticipantTextFieldFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(newParticipantTextFieldFinder);
            await tester.pumpAndSettle();
            
            // Adding the name
            await tester.enterText(newParticipantTextFieldFinder, name1);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Tapping the name for edition
            var name = find.text(name1);
            await tester.tap(name);
            await tester.pumpAndSettle();

            // Editing the name
            const tfKeyLabel = 'editable-deletable-tf-0';
            var editionTfFinder = find.byKey(const ValueKey(tfKeyLabel));
            await tester.ensureVisible(editionTfFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(editionTfFinder);
            await tester.pumpAndSettle();

            var editedName = '$name1-edited';
            await tester.enterText(editionTfFinder, editedName);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Verifying the text field absent
            expect(find.byKey(const ValueKey(tfKeyLabel)), findsNothing);
            
            // Verifying the edited name present
            expect(find.text(editedName), findsOne);

          });
        
        // 'Participants names can be deleted (while building a new list)'
        testWidgets('Participants names can be deleted (while building a new list)', 
        (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              'wasFirstRunModalAcknowledged': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING A PARTICIPANT ──────────────────────────────────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);

            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const ValueKey('participantNameField'));
            await tester.ensureVisible(newParticipantTextFieldFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(newParticipantTextFieldFinder);
            await tester.pumpAndSettle();
            
            // Adding the name
            await tester.enterText(newParticipantTextFieldFinder, name1);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Checking the checkbox
            const checkboxKeyLabel = 'editable-deletable-checkbox-0';
            var deletionCheckboxFinder = find.byKey(const ValueKey(checkboxKeyLabel));
            await tester.ensureVisible(deletionCheckboxFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(deletionCheckboxFinder);
            await tester.pumpAndSettle();

            // Tapping the deletion label
            var bulkDeletionFinder = find.textContaining('Delete');
            await tester.tap(bulkDeletionFinder);
            await tester.pumpAndSettle();
            
            // Verifying the edited name absent
            expect(find.text(name1), findsNothing);

          });
        
      });

    });  

    group('Participants Loading/Dashboard Tests: \n', () 
    {
      group('Participants Loading: \n', () 
      {        
        // 'Participants can be loaded from an existing list'
        testWidgets('Participants can be loaded from an existing list', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────────────────────
          List< Map<String,Map<String, dynamic>> > listDataMapsList =
          [
            {listLabel1:{"names":names1,"keywords":[]}},
          ];
          await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);
        
          // ── LOADING PARTICIPANTS   ─────────────────────────────────
          // ───────────────────────────────────────────────────────────

          // Searching the add emoji    
          var addEmojiFinder = find.text(addEmoji);

          // Verifying the add emoji present
          expect(addEmojiFinder, findsOne);

          // Tapping to reach the page with the loading/new group options
          await tester.tap(addEmojiFinder);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));

          // Verifying the options page present
          var optionsPageFinder = find.text(participantsListsSubTitle);
          expect(optionsPageFinder, findsOne);

          // Searching the loading button
          var loadingAListOptionFinder = find.text(loadingAListOptionLabel);
          await tester.ensureVisible(loadingAListOptionFinder);
          expect(loadingAListOptionFinder, findsOne);

          // Tapping on it
          await tester.tap(loadingAListOptionFinder);
          await tester.pumpAndSettle();

          // Verifying the lists dashboard title present
          var listDashboardTitleFinder = find.text(listsDashboardTitle);
          expect(listDashboardTitleFinder, findsOne);

          // Searching for a loading button
          var loadingButtonFinder = find.descendant
          (
            of: find.byType(ElevatedButton), 
            matching: find.text(loadingButtonLabel)
          );
          expect(listDashboardTitleFinder, findsOne);

          // await tester.pump(const Duration(seconds: 2));

          // Tapping on it
          await tester.tap(loadingButtonFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process present
          expect(find.text(checkListTitle), findsOne);

          // Verifying the names present
          for (var name in names1)
          {
            expect(find.text(name), findsOne);    
          }  
      });      
        
      });

      group('Participants Dashboard Tests: \n', () 
      {    

        group('Entered metadata is displayed on the list dashboard: Mobile: \n', ()
        {
          // 'Session metadata entered (participants, list name, keywords) is found: '
          // '(assuming an already selected path to the user session data folder)',
          testWidgets(
            'Session metadata entered (participants, list name, keywords) is found: '
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
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── CLICKING TO DISPLAY THE PARTICIPANTS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────
              // Adding the names
              await gpsFromProcessPageAddParticipants(tester, names1, keywords1);   

              // Verifying the names present
              expect(find.text(name1), findsOne);    
              expect(find.text(name2), findsOne);  

              // Searching the 'Save' icon
              var saveListIconFinder = find.byIcon(Icons.save_outlined);
              expect(saveListIconFinder, findsOne);

              // Tapping on it
              await tester.tap(saveListIconFinder);
              await tester.pumpAndSettle();

              // Searching the text field to add the list name
              var listNameSavingTextFieldFinder = find.byKey(const ValueKey('saveListField'));
              expect(listNameSavingTextFieldFinder, findsOne);

              // Adding a list name
              await tester.ensureVisible(listNameSavingTextFieldFinder);
              await tester.tap(listNameSavingTextFieldFinder);
              await tester.enterText(listNameSavingTextFieldFinder, listLabel1);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();

              // Verifying the GPS process page present
              expect(find.text(checkListTitle), findsOne);

              // Verifying the names present
              expect(find.text(name1), findsOne);    
              expect(find.text(name2), findsOne); 

              // ── SEARCHING THE METADATA ON THE DASHBOARD  ────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────
              // Going from the process page to the list dashboard page
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // Searching for the list name
              expect(find.text(listLabel1), findsOne);

              // Searching for the names
              for (var name in names1)
              {
                expect(find.text(name), findsOne);
              }

              // Searching for the keywords
              for (var kw in keywords1)
              {
                expect(find.text(kw), findsOne);
              }

              // await tester.pump(const Duration(seconds: 5));
            }
          );
        });   

        group('Sorting and Filtering Tests: \n', ()
        {
          // 'Sorting by list label \n'
          testWidgets(
            'Sorting by list label \n',
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING 3 LISTS OF PARTICIPANTS (non alphabetical order)  ──────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel3:{"names":names3,"keywords":[]}},
                {listLabel1:{"names":names1,"keywords":[]}},
                {listLabel2:{"names":names2,"keywords":[]}},                          
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);
              
              // ── SORTING BY LABEL ──────────────────────────────────
              // ────────────────────────────────────────────────────────
              // Triggering the sort
              var sortByTitleFinder = find.textContaining(listsSortByLabel);
              await tester.tap(sortByTitleFinder);
              await tester.pumpAndSettle();
              // await tester.pump(const Duration(seconds: 2));

              // Searching the list labels          
              var titlesFinder = await dashboardGetAllSessionsTitles(tester);
              var totalTitles = titlesFinder.evaluate().length;
              if (testingDebug) pu.printd('Testing Debug: totalTitles: $totalTitles');

              // Verifying the alphabetical order
              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), listLabelsSorted[index]);
              }

              // Re-triggering the sort
              await tester.tap(sortByTitleFinder);
              await tester.pumpAndSettle();
              // await tester.pump(const Duration(seconds: 2));

              // Re-searching the labels  
              titlesFinder = await dashboardGetAllSessionsTitles(tester); 

              // Verifying the alphabetical order 
              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), listLabelsSorted.reversed.toList()[index]);
              }       
            }
          );        
        
          // 'Filtering by keywords \n'
          testWidgets(
            'Filtering by keywords \n',
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING 3 LISTS OF PARTICIPANTS ──────────────────────────────────
              // ────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [            
                {listLabel1:{"names":names1,"keywords":keywords1}},
                {listLabel2:{"names":names2,"keywords":keywords2}},
                {listLabel3:{"names":names3,"keywords":keywords2}},                          
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);
            
              // ── FILTERING BY KEYWORDS ────────────────────────────
              // ─────────────────────────────────────────────────────
              // 1. Filtering by kwCompanionship
              var kwCompanionshipFinder = await dashboardGetKwFilterChip(tester, kwCompanionship);
              await tester.tap(kwCompanionshipFinder);
              await tester.pumpAndSettle();

              // Verifying the titles present
              var titlesFinder = await dashboardGetAllSessionsTitles(tester);
              var totalTitles = titlesFinder.evaluate().length;
              if (testingDebug) pu.printd('Testing Debug: totalTitles for $kwCompanionship: $totalTitles');

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesCompanionship.reversed.toList()[index]);
              }
              // Un-selecting the keyword
              await tester.tap(kwCompanionshipFinder);
              await tester.pumpAndSettle();

              // 2. Filtering by kwWorkplace
              var kwWorkplaceFinder = await dashboardGetKwFilterChip(tester, kwWorkplace);
              await tester.tap(kwWorkplaceFinder);
              await tester.pumpAndSettle();

              // Verifying the titles present
              titlesFinder = await dashboardGetAllSessionsTitles(tester);
              totalTitles = titlesFinder.evaluate().length;
              if (testingDebug) pu.printd('Testing Debug: totalTitles for $kwWorkplace: $totalTitles');

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesWorkplace.reversed.toList()[index]);
              }         

              // await tester.pump(const Duration(seconds: 2));

            });      
        
        });
    
        group('Deletion Tests: \n', ()
        {
          // 'Deletion: Single deletion with icon \n'
          testWidgets(
            'Deletion: Single deletion with icon \n',
            (WidgetTester tester) async {

              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING A LIST OF PARTICIPANTS   ──────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[]}},
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // ── TESTING THE DELETION ────────────────────────────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────────────            
              // Searching for the tooltip 
              var deleteIconFinder = find.byTooltip(listsDeleteTooltipLabel);

              // Tapping the icon
              await tester.tap(deleteIconFinder);
              await tester.pumpAndSettle();

              // Verifying the list item absent
              var sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: listLabel1);
              expect(sessionListItemFinder, findsNothing);
            }      
          );         
        
          // 'Deletion: Bulk deletion \n'
          testWidgets(
            'Deletion: Bulk deletion \n',
            (WidgetTester tester) async {

              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING 3 LISTS OF PARTICIPANTS   ──────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[]}},
                {listLabel2:{"names":names2,"keywords":[]}},
                {listLabel3:{"names":names3,"keywords":[]}},
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // ── SEARCHING FOR THE ITEMS with listName1 and listName2 TO CHECK ON THE DASHBOARD  ─
              // ────────────────────────────────────────────────────────────────────────────────────
              var checkbox1Finder = find.descendant
              (
                of: find.ancestor(of: find.text(listLabel1), matching: find.byType(ListOfListsItem)), 
                matching: find.byType(Checkbox)
              );
              await tester.ensureVisible(checkbox1Finder);
              await tester.tap(checkbox1Finder);
              await tester.pumpAndSettle();

            var checkbox2Finder = find.descendant
              (
                  of: find.ancestor(of: find.text(listLabel2), matching: find.byType(ListOfListsItem)), 
                  matching: find.byType(Checkbox)
              );
              await tester.ensureVisible(checkbox2Finder);
              await tester.tap(checkbox2Finder);
              await tester.pumpAndSettle();

              // ── BULK DELETION ────────────────────────────────────────────────────────────
              // ─────────────────────────────────────────────────────────────────────────────            
              // Searching the widget
              var bulkDeletionFinder = find.textContaining('Delete');
              expect(bulkDeletionFinder, findsOne);
              await tester.ensureVisible(bulkDeletionFinder);
              await tester.tap(bulkDeletionFinder);
              await tester.pumpAndSettle();

              // ── TESTING THE DELETION ────────────────────────────────────────────────────────────
              // ───────────────────────────────────────────────────────────────────────────────────────       
              // Checking the number of list items left 
              var sessionsListItemsFinder = find.byType(ListOfListsItem);
              expect(sessionsListItemsFinder, findsOne);
              // Verifying listName3 remains
              var textFinder = find.text(listLabel3);
              Text textWidget = tester.widget(textFinder);
              expect(textWidget.data, listLabel3);            
            }      
          );
        });    
      
        group('Edition Tests: \n', ()
        {
          // 'The list label can be edited (non empty label) \n'
          testWidgets(
            'The list label can be edited (non empty label) \n',
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[]}},            
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // ── EDITING THE LABEL   ────────────────────────
              // ───────────────────────────────────────────────
              // Searching for the label        
              var labelsFinder = await dashboardGetAllSessionsTitles(tester);
              var totalLabels = labelsFinder.evaluate().length;
              if (testingDebug) pu.printd('Testing Debug: totalLabels: $totalLabels');

              // Verifying the label present
              expect((tester.widget<Text>(labelsFinder.first).data), listLabel1);

              // Tapping to edit the label
              await tester.tap(labelsFinder);
              await tester.pumpAndSettle();

              // Searching the text field to edit the label
              var newLabelTextFieldFinder = find.byKey(const ValueKey('listNameEditField'));
              expect(newLabelTextFieldFinder, findsOne);
              await tester.ensureVisible(newLabelTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(newLabelTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the edited label
              await tester.enterText(newLabelTextFieldFinder, "${listLabel1}-edited");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();              

              // Verifying the edited label present
              expect(find.text("${listLabel1}-edited"), findsOne);                   

            });

          // 'The list label can be edited (empty label) \n'
          testWidgets(
            'The list label can be edited (empty label) \n',
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[]}},            
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // ── EDITING THE LABEL   ─────────────────
              // ────────────────────────────────────────
              // Searching for the label         
              var labelFinder = await dashboardGetAllSessionsTitles(tester);

              // Tapping to edit the label
              await tester.tap(labelFinder);
              await tester.pumpAndSettle();

              // Searching the text field to edit the label
              var listEditTextFieldFinder = find.byKey(const ValueKey('listNameEditField'));
              expect(listEditTextFieldFinder, findsOne);
              await tester.ensureVisible(listEditTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(listEditTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the empty label
              await tester.enterText(listEditTextFieldFinder, "");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle(); 

              // Clicking on the 'Save' button
              // await tester.pump(const Duration(seconds: 5));  
              var saveButtonFinder = find.text(saveButtonLabel); 
              await tester.tap(saveButtonFinder);
              await tester.pumpAndSettle();

              // Verifying error message present
              expect(find.text(emptyLabelEditError), findsOne);

            });
        
          // 'The participants can be edited (non empty participants list) \n'
          testWidgets(
            'The participants can be edited (non empty participants list) \n',
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[]}},            
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // ── EDITING THE PARTICIPANTS  ──────────────────
              // ───────────────────────────────────────────────
              // Searching for the participants containers        
              var participantsContainersFinder = await gpsGetParticipantsContainersOnListDashboard(tester);
              var totalNames = participantsContainersFinder.evaluate().length;
              if (testingDebug) pu.printd('Testing Debug: totalNames: $totalNames');

              // Searching for text within the container
              var aParticipant = 
                find.descendant(of: participantsContainersFinder, matching: find.byType(Text));

              // Tapping to edit the participants
              await tester.tap(aParticipant.first);
              await tester.pumpAndSettle();

              // Searching the text field to edit the participants
              var newParticipantsTextFieldFinder = find.byKey(const ValueKey('participantsEditField'));
              expect(newParticipantsTextFieldFinder, findsOne);
              await tester.ensureVisible(newParticipantsTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(newParticipantsTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the edited participant data (comma-separated values)
              await tester.enterText(newParticipantsTextFieldFinder, "Bob,Benny,Alicia");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();              

              // Verifying data in the participants container
              participantsContainersFinder = await gpsGetParticipantsContainersOnListDashboard(tester);
              var participantsFinder = find.descendant
                                      (
                                        of: participantsContainersFinder, 
                                        matching: find.byType(Text)
                                      );

              var totalParticipants = participantsFinder.evaluate().length;
              if (testingDebug) pu.printd('Testing Debug: totalParticipants: $totalParticipants');

              List<String> editedAndSortedParticipantsList = ["Alicia","Benny","Bob"];
              for (var index = 0; index < totalParticipants; index++)
              {
                expect((tester.widget<Text>(participantsFinder.at(index)).data), editedAndSortedParticipantsList[index]);
              }

            });
        
          // 'The participants can be edited (empty participants list) \n'
          testWidgets(
            'The participants can be edited (empty participants list) \n',
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[]}},            
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // ── EDITING THE PARTICIPANTS   ─────────────────
              // ───────────────────────────────────────────────
              // Searching for the participants containers        
              var participantsContainersFinder = await gpsGetParticipantsContainersOnListDashboard(tester);
              var totalNames = participantsContainersFinder.evaluate().length;
              if (testingDebug) pu.printd('Testing Debug: totalNames: $totalNames');

              // Searching for text within the container
              var aParticipant = 
                find.descendant(of: participantsContainersFinder, matching: find.byType(Text));

              // Tapping to edit the participants
              await tester.tap(aParticipant.first);
              await tester.pumpAndSettle();

              // Searching the text field to edit the participants
              var newParticipantsTextFieldFinder = find.byKey(const ValueKey('participantsEditField'));
              expect(newParticipantsTextFieldFinder, findsOne);
              await tester.ensureVisible(newParticipantsTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(newParticipantsTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the empty edited participant data
              await tester.enterText(newParticipantsTextFieldFinder, "");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle(); 

              // Clicking on the 'Save' button
              // await tester.pump(const Duration(seconds: 5));  
              var saveButtonFinder = find.text(saveButtonLabel); 
              await tester.tap(saveButtonFinder);
              await tester.pumpAndSettle();

              // Verifying error message present
              expect(find.text(emptyParticipantsListError), findsOne);
            });
        
          // 'The keywords can be edited \n'
          testWidgets(
            'The keywords can be edited \n',
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                'wasFirstRunModalAcknowledged': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────────────────
              List< Map<String,Map<String, dynamic>> > listDataMapsList =
              [
                {listLabel1:{"names":names1,"keywords":[kwCompanionship]}},            
              ];
              await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      

              // ── REACHING THE DASHBOARD/LISTS PAGE   ────────────────────────
              // ───────────────────────────────────────────────────────────────
              await gpsFromProcessPageToListLoadingDashboard(tester);

              // ── EDITING THE KEYWORDS   ─────────────────────
              // ───────────────────────────────────────────────
              // Searching for the keywords        
              var keywordsDataFinder = await dashboardGetKeywordsOnDashboard(tester);

              // Tapping to edit the label
              await tester.tap(keywordsDataFinder.first);
              await tester.pumpAndSettle();

              // Searching the text field to edit the keywords
              var newKeywordsTextFieldFinder = find.byKey(const ValueKey('keywordsEditField'));
              expect(newKeywordsTextFieldFinder, findsOne);
              await tester.ensureVisible(newKeywordsTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(newKeywordsTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the edited keywords data (comma-separated values)
              await tester.enterText(newKeywordsTextFieldFinder, "${kwWorkplace},${kwCompanionship}");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();              

              // Verifying data
              var newKeywordsDataFinder = await dashboardGetKeywordsOnDashboard(tester);
              var editedAndSortedKeywordsData ="Keywords: $kwCompanionship, $kwWorkplace";
              expect((tester.widget<Text>(newKeywordsDataFinder).data), editedAndSortedKeywordsData);
            });
        
        });
    });
  });


});

    group('Ideas-related Tests: \n', () 
{
  group('Ideas Overlay Tests: \n', () 
  {

    group('Ideas Overlay Opening Tests: \n', () 
    {
      // 'The overlay can be opened clicking on the ideas area title'
      testWidgets('The overlay can be opened clicking on the ideas area title', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── CLICKING ON THE IDEAS LIST TITLE  ───────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          var ideasListTitleFinder = find.text(ideasListTitle);
          await tester.tap(ideasListTitleFinder);
          await tester.pumpAndSettle();

          // ── OVERLAY  ───────────────────────────────────
          // ───────────────────────────────────────────────
          // Verifying the overlay present
          expect(find.byKey(const ValueKey('ideaOverlayTextField')), findsOne);
        });
      
      // 'The overlay can be opened clicking on the ideas'
      testWidgets('The overlay can be opened clicking on the ideas', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the text field used to add ideas
          var newIdeaTextFieldFinder = find.ancestor
          (
            of: find.text(newIdeaTextFieldHint), 
            matching: find.byType(TextField)
          );

          // Adding the idea
          await tester.enterText(newIdeaTextFieldFinder, "An idea");
          await tester.testTextInput.receiveAction(TextInputAction.done);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));  

          // ── OVERLAY  ───────────────────────────────────
          // ───────────────────────────────────────────────
          // Tapping on the idea
          var ideaFinder = find.byKey(const ValueKey('idea-0'));
          await tester.tap(ideaFinder);
          await tester.pumpAndSettle();

          // Verifying the overlay present
          expect(find.byKey(const ValueKey('ideaOverlayTextField')), findsOne);
        });
    });

    group('Ideas Overlay Editing Tests: \n', () 
    {
      var idea1 = "idea1";
      var idea2 = "idea2";
      var idea3 = "idea3";
      var idea4 = "idea4";

      // 'Ideas can be added in the overlay'
      testWidgets('Ideas can be added in the overlay', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the text field used to add ideas
          var newIdeaTextFieldFinder = find.byKey(const ValueKey('ideaOverlayTextField'));
          // Adding the idea
          await tester.ensureVisible(newIdeaTextFieldFinder);
          await tester.tap(newIdeaTextFieldFinder);
          await tester.pumpAndSettle(); 
          await tester.enterText(newIdeaTextFieldFinder, "An idea");
          await tester.testTextInput.receiveAction(TextInputAction.done);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));  

          // ── OVERLAY  ───────────────────────────────────
          // ───────────────────────────────────────────────
          // Searching the idea
          var ideaFinder = find.byKey(const ValueKey('idea-0'));
          await tester.ensureVisible(ideaFinder);
          await tester.pumpAndSettle();   
          // Verifying the idea present
          expect(ideaFinder, findsOne);

          // await tester.pump(const Duration(seconds: 5)); 
        });
    
      // 'Ideas can be edited in the overlay'
      testWidgets('Ideas can be edited in the overlay', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          await gpsFromOverlayAddIdea(tester, idea1);

          // ── EDITING THE IDEA  ────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the idea
          var ideaFinder = find.byKey(const ValueKey('editable-deletable-text-item-0'));
          await tester.ensureVisible(ideaFinder);
          await tester.pumpAndSettle();   
          // Verifying the idea present
          expect(ideaFinder, findsOne);
          // Tapping on the idea for edition
          await tester.tap(ideaFinder);
          await tester.pumpAndSettle();
          // Edition
          const tfKeyLabel = 'editable-deletable-tf-0';
          var editableDeletableTfFinder = find.byKey(const ValueKey(tfKeyLabel));
          await tester.ensureVisible(editableDeletableTfFinder);
          await tester.pumpAndSettle();
          await tester.tap(editableDeletableTfFinder);
          await tester.pumpAndSettle();

          var ideaEdited = "$idea1-edited";
          await tester.enterText(editableDeletableTfFinder, ideaEdited);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));

          // ── VERIFYING THAT THE EDITED VALUE IS ON THE GPS PROCESS PAGE  ─────────────────
          // ────────────────────────────────────────────────────────────────────────────────
          // Closing the overlay
          var overlayClosingTooltipFinder = find.byTooltip(overlayClosingTooltip);
          await tester.tap(overlayClosingTooltipFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process page present
          expect(find.text(checkListTitle), findsOne);

          // Verifing the edited idea on the GPS process page
          expect(find.text(ideaEdited), findsOne);

          // await tester.pump(const Duration(seconds: 2)); 
        });
    
      // 'Ideas can be deleted in the overlay'
      testWidgets('Ideas can be deleted in the overlay', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          await gpsFromOverlayAddIdea(tester, idea1);

          // ── DELETING THE IDEA  ────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the checkbox
          var checkboxFinder = find.byKey(const ValueKey('editable-deletable-checkbox-0'));
          await tester.ensureVisible(checkboxFinder);
          await tester.pumpAndSettle();   
          // Tapping on the checkbox for deletion
          await tester.tap(checkboxFinder);
          await tester.pumpAndSettle();
          
          // Clicking on the Delete message
          var deleteFinder = find.textContaining('Delete');
          await tester.ensureVisible(deleteFinder);
          await tester.tap(deleteFinder);
          await tester.pumpAndSettle();

          // Verifying the value removed from the overlay
          expect(find.text(idea1), findsNothing);

          // Closing the overlay
          var overlayClosingTooltipFinder = find.byTooltip(overlayClosingTooltip);
          await tester.tap(overlayClosingTooltipFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process page present
          expect(find.text(checkListTitle), findsOne);

          // Verifying the value removed from the GPS process page
          expect(find.text(idea1), findsNothing);

          // await tester.pump(const Duration(seconds: 2)); 
        });
    
      // '4 additions, 2 deletions'
      testWidgets('4 additions, 2 deletions', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            'wasFirstRunModalAcknowledged': true,
            // and to have the group problem-solving page, with the dashboard.
            'wasGPSSessionDataSaved': true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(tester);

          // ── ADDING IDEAS  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          await gpsFromOverlayAddIdea(tester, idea1);
          await gpsFromOverlayAddIdea(tester, idea2);
          await gpsFromOverlayAddIdea(tester, idea3);
          await gpsFromOverlayAddIdea(tester, idea4);

          // ── DELETING 2 IDEAs  ────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the checkboxes
          var checkboxFinder = find.byKey(const ValueKey('editable-deletable-checkbox-0'));
          await tester.ensureVisible(checkboxFinder);
          await tester.pumpAndSettle();   
          // Tapping on the checkbox for deletion
          await tester.tap(checkboxFinder);
          await tester.pumpAndSettle();

          checkboxFinder = find.byKey(const ValueKey('editable-deletable-checkbox-2'));
          await tester.ensureVisible(checkboxFinder);
          await tester.pumpAndSettle();   
          // Tapping on the checkbox for deletion
          await tester.tap(checkboxFinder);
          await tester.pumpAndSettle();
          
          // Clicking on the Delete message
          var deleteFinder = find.textContaining('Delete');
          await tester.ensureVisible(deleteFinder);
          await tester.tap(deleteFinder);
          await tester.pumpAndSettle();

          // Verifying the values removed from the overlay
          expect(find.text(idea1), findsNothing);
          expect(find.text(idea2), findsNWidgets(2));
          expect(find.text(idea3), findsNothing);
          expect(find.text(idea4), findsNWidgets(2));

          // Closing the overlay
          var overlayClosingTooltipFinder = find.byTooltip(overlayClosingTooltip);
          await tester.tap(overlayClosingTooltipFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process page present
          expect(find.text(checkListTitle), findsOne);

          // Verifying the values removed from the GPS process page
          expect(find.text(idea1), findsNothing);
          expect(find.text(idea2), findsOne);
          expect(find.text(idea3), findsNothing);
          expect(find.text(idea4), findsOne);

          // await tester.pump(const Duration(seconds: 2)); 
        });
    
    });
    
  });

  

  });

  group('Visual Tests: Mobile: \n', ()
  {
    // 'Sharing test \n'
    testWidgets(
      'Sharing test \n',
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
            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: testGPSTitle1,
              kwsList: [],
              ideasList: ["at least one idea needed"],
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // ── 2. CLICKING ON THE DASHBOARD TO PREVIEW ───────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            var previewFinder = find.byIcon(Icons.find_in_page_rounded);
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();

            // ── 3. CLICKING ON THE SHARING BUTTON IN THE PREVIEW ───────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            var shareFinder = find.byIcon(Icons.share);
            await tester.tap(shareFinder);
            await tester.pumpAndSettle();

            // ── 4. PAUSE FOR VISUAL INSPECTION ───────────────────────────
            // ─────────────────────────────────────────────────────────────
            await tester.pump(const Duration(seconds: 10));
        }
      });
  }); 

});

}