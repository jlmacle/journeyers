import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:integration_test/integration_test.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/context_analysis/context_analysis_page.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/utils/generic/dev/test_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/4_dashboard_sessions_list_item.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart";

import "externalized_code/externalized_testing_code.dart";


// ─── Helper function ──────────────────────────────────────────────────────────────────

/// Wraps the widget under test inside the mandatory Material / Directionality /
/// Localizations ancestors that several Flutter widgets require.
///
/// Providing [AppLocalizations] delegates ensures that any `AppLocalizations.of(context)`
/// call inside CAPage (e.g. the first-run AlertDialog) resolves correctly instead
/// of returning null and falling back to the raw fallback string.
Widget buildTestableCAPage() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CAPage(),
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
  const String testAnalysisTitleRoot = "Integration-test CA session title";
  const String testAnalysisTitle1 = "$testAnalysisTitleRoot (1)";
  const String testAnalysisTitle2 = "$testAnalysisTitleRoot (2)";
  const String testAnalysisTitle3 = "$testAnalysisTitleRoot (3)";
  const List<String> titlesList = [testAnalysisTitle3, testAnalysisTitle1, testAnalysisTitle2];
  const List<String> titlesMaintenance = ["Maintenance topic 1", "Maintenance topic 2", "Maintenance topic 3"];
  const List<String> titlesCompanionship = ["Companionship and Logistics topic", "Companionship and Studies topic"];
  const List<String> titlesWorkplace = ["Workplace and Communication topic"];
  List<String> titlesListKwsSorting = 
                      [
                        titlesMaintenance[0], titlesCompanionship[0], titlesWorkplace[0],
                        titlesCompanionship[1], titlesMaintenance[1], titlesMaintenance[2]
                      ];
  const List<String> titlesListSorted = [testAnalysisTitle1, testAnalysisTitle2, testAnalysisTitle3];

  // Keywords
  const String kwCompanionship = "Companionship";
  const String kwWorkplace = "Workplace";
  const String kwStudies = "Studies";  
  const String kwCommunication = "Communication";
  const String kwMaintenance = "Maintenance";
  const String kwLogistics = "Logistics";
  const List<String> kwsList2Keywords = [kwCompanionship, kwWorkplace];
  const List<List<String>> kwsListsKwsSorting = 
                    [
                      [kwMaintenance], [kwCompanionship, kwLogistics], [kwWorkplace, kwCommunication],
                      [kwCompanionship, kwStudies], [kwMaintenance], [kwMaintenance],
                    ];

  // File names
  const String fileName1WithoutExtension = "file1";
  const String fileName2WithoutExtension = "file2";
  const String fileName3WithoutExtension = "file3";
  const List<String> fileNamesWithoutExtensionList = [fileName1WithoutExtension, fileName2WithoutExtension, fileName3WithoutExtension];

  // Edition
  const String editionSuffix = "-edited";

  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;
  
  setUp(() async {
    // Creating a temporary folder to store the files to save
    testTmpDir = await Directory.systemTemp.createTemp("context_analysis_integration_test_");
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

  group("Context Analysis Integration Tests: Mobile: \n", () 
  {
    group("Entered metadata is displayed on the dashboard: Mobile: \n", ()
    {
    // "Session metadata entered (title, keywords, date) is found: "
    // "(assuming an already selected path to the user session data folder)",
    testWidgets(
      "Session metadata entered (title, keywords, date) is found: "
      "(assuming an already selected path to the user session data folder)",
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          "wasFirstRunModalAcknowledged": true,
          // and to have the context analysis page, with the dashboard.
          "wasCASessionDataSaved": true,
          // Temporary test dir as application folder path
          "applicationFolderPath": testTmpDir!.path
        });

        if (Platform.isAndroid || Platform.isIOS)
        {
          // Pumping the CAPage
          //
          // pumpWidget renders the first frame.
          // pumpAndSettle drives the event loop until there are no more pending frames,
          // letting the async getPreferences() call complete 
          // and setState(() { _preferencesLoading = false; }) rebuild the tree.
          await tester.pumpWidget(buildTestableCAPage());
          await tester.pumpAndSettle();

          // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────

            // formToFill: false to skip the form filling
            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              formToFill: false,
              title: testAnalysisTitle1,
              kwsList: kwsList2Keywords,
              fileNameWithoutExtension: fileName1WithoutExtension
            );


          // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords
          
          // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2)); 
          await dashboardSearchTitleAndKeywords(title: testAnalysisTitle1, kws: kwsList2Keywords);

          await tester.pump(const Duration(seconds: 5));

          // Searching for the date
          dateForTestingIndex = 0;
          expect(find.textContaining(datesForTestingList[0]), findsOne);
        }
    });
 
    });

    group("Sorting and filtering Tests: Mobile: \n", ()
    {
      // "Sorting by title \n"
      // "(assuming an already selected path to the user session data folder)",
      testWidgets(
        "Sorting by title \n"
        "(assuming an already selected path to the user session data folder)",
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis page, with the dashboard.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the CAPage
            //
            // pumpWidget renders the first frame.
            // pumpAndSettle drives the event loop until there are no more pending frames,
            // letting the async getPreferences() call complete 
            // and setState(() { _preferencesLoading = false; }) rebuild the tree.
            //
            
            await tester.pumpWidget(buildTestableCAPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW CA PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await caEnterSeveralTimesNewProcessData
            (
              formToFill: false,
              tester: tester,
              titlesList: titlesList,
              kwsLists: [[], [], []],
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
            if (testingDebug) pu.printd("Testing Debug: totalTitles: $totalTitles");

            // Verifying the alphabetical order
            for (var index = 0; index < totalTitles; index++)
            {
              expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesListSorted[index]);
            }

            // Re-triggering the sort
            await tester.tap(sortByTitleFinder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            // Re-searching the titles  
            titlesFinder = await dashboardGetAllSessionsTitles(tester); 

            // Verifying the reversed alphabetical order 
            for (var index = 0; index < totalTitles; index++)
            {
              expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesListSorted.reversed.toList()[index]);
            }
          }          
        }
      );
         
      // "Sorting by date \n"
      // "(assuming an already selected path to the user session data folder)",
      testWidgets(
        "Sorting by date \n"
        "(assuming an already selected path to the user session data folder)",
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis page, with the dashboard.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the CAPage
            //
            // pumpWidget renders the first frame.
            // pumpAndSettle drives the event loop until there are no more pending frames,
            // letting the async getPreferences() call complete 
            // and setState(() { _preferencesLoading = false; }) rebuild the tree.
            //
            
            await tester.pumpWidget(buildTestableCAPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW CA PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await caEnterSeveralTimesNewProcessData
            (
              formToFill: false,
              tester: tester,
              titlesList: titlesList,
              kwsLists: [[], [], []],
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
                  return (widget.key as ValueKey<String>).value.contains("session-date-");
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
                  return (widget.key as ValueKey<String>).value.contains("session-date-");
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

      // "Filtering by keywords \n"
      // "(assuming an already selected path to the user session data folder)",
      testWidgets(
          "Filtering by keywords \n"
          "(assuming an already selected path to the user session data folder)",
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the context analysis page, with the dashboard.
              "wasCASessionDataSaved": true,
              // Temporary test dir as application folder path
              "applicationFolderPath": testTmpDir!.path
            });

            if (Platform.isAndroid || Platform.isIOS)
            {
              // Pumping the CAPage
              //
              // pumpWidget renders the first frame.
              // pumpAndSettle drives the event loop until there are no more pending frames,
              // letting the async getPreferences() call complete 
              // and setState(() { _preferencesLoading = false; }) rebuild the tree.
              //
              
              await tester.pumpWidget(buildTestableCAPage());
              await tester.pumpAndSettle();

              // ── 1. ENTERING NEW CA PROCESS DATA (6 times) ──────────────────────────────────
              // ───────────────────────────────────────────────────────────────────────────────
              
              await caEnterSeveralTimesNewProcessData
              (
                formToFill: false,
                tester: tester,
                titlesList: titlesListKwsSorting,
                kwsLists: kwsListsKwsSorting,
                fileNamesWithoutExtensionList: List.generate(6, (i)=> "file${i+1}")
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

              if (testingDebug) pu.printd("Testing Debug: totalTitles for $kwMaintenance: $totalTitles");

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesMaintenance.reversed.toList()[index]);
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

              if (testingDebug) pu.printd("Testing Debug: totalTitles for $kwCompanionship: $totalTitles");

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesCompanionship.reversed.toList()[index]);
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

              if (testingDebug) pu.printd("Testing Debug: totalTitles for $kwWorkplace: $totalTitles");

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesWorkplace.reversed.toList()[index]);
              }
              

              // await tester.pump(const Duration(seconds: 2));
            }
          });     
    });
  
    group("Deletion Tests: Mobile: \n", ()
  {
  // "Deletion: Single deletion with icon \n"
  // "(assuming an already selected path to the user session data folder)",
  testWidgets(
    "Deletion: Single deletion with icon \n"
    "(assuming an already selected path to the user session data folder)",
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        "wasFirstRunModalAcknowledged": true,
        // and to have the context analysis page, with the dashboard.
        "wasCASessionDataSaved": true,
        // Temporary test dir as application folder path
        "applicationFolderPath": testTmpDir!.path
      });

      if (Platform.isAndroid || Platform.isIOS)
      {
        // Pumping the CAPage
        //
        // pumpWidget renders the first frame.
        // pumpAndSettle drives the event loop until there are no more pending frames,
        // letting the async getPreferences() call complete 
        // and setState(() { _preferencesLoading = false; }) rebuild the tree.
        //
        
        await tester.pumpWidget(buildTestableCAPage());
        await tester.pumpAndSettle();

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        await caEnterNewProcessDataOnMobile
        (
          formToFill: false,
          tester: tester, 
          title: testAnalysisTitle2,
          kwsList: [kwCompanionship],              
          fileNameWithoutExtension: fileName1WithoutExtension
        );

        // ── 2. SEARCHING FOR THE SESSION DATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the finder with the title
        Finder sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: testAnalysisTitle2);
        expect(sessionListItemFinder, findsOne);

        // await tester.pump(const Duration(seconds: 4));

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
        sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: testAnalysisTitle2);
        expect(sessionListItemFinder, findsNothing);

        // Verifying the Filter Chip absent
        filterChipFinder = find.descendant
        (
          of: find.byType(FilterChip), 
          matching: find.text(kwCompanionship)
        );

        expect(filterChipFinder, findsNothing);


        // await tester.pump(const Duration(seconds: 2));
      }
    }      
  );

  // "Deletion: Bulk deletion \n"
  // "(assuming an already selected path to the user session data folder)",
  testWidgets(
    "Deletion: Bulk deletion \n"
    "(assuming an already selected path to the user session data folder)",
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        "wasFirstRunModalAcknowledged": true,
        // and to have the context analysis page, with the dashboard.
        "wasCASessionDataSaved": true,
        // Temporary test dir as application folder path
        "applicationFolderPath": testTmpDir!.path
      });

      if (Platform.isAndroid || Platform.isIOS)
      {
        // Pumping the CAPage
        //
        // pumpWidget renders the first frame.
        // pumpAndSettle drives the event loop until there are no more pending frames,
        // letting the async getPreferences() call complete 
        // and setState(() { _preferencesLoading = false; }) rebuild the tree.
        //
        
        await tester.pumpWidget(buildTestableCAPage());
        await tester.pumpAndSettle();

        // ── 1. ENTERING NEW CA PROCESS DATA (3 times) ──────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        await caEnterSeveralTimesNewProcessData
        (
          formToFill: false,
          tester: tester,
          // const List<String> titlesList = [testAnalysisTitle3, testAnalysisTitle1, testAnalysisTitle2];
          titlesList: titlesList,
          kwsLists: [["kw3"], ["kw1"], ["kw2"]],
          fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
        );

        // Verifying the Filter Chips present
        var filterChipFinder = find.byType(FilterChip);
        expect(filterChipFinder, findsNWidgets(3));

        // ── 2. DELETION: SEARCHING FOR THE TILES with title 1 and title 2  ─
        // Searching and tapping the checkboxes for title 1 and title 2
        var checkbox1Finder = find.descendant
        (
          of: find.ancestor(of: find.text(testAnalysisTitle1), matching: find.byType(SessionsListItem)), 
          matching: find.byType(Checkbox)
        );
        await tester.ensureVisible(checkbox1Finder);
        await tester.tap(checkbox1Finder);
        await tester.pumpAndSettle();

        var checkbox2Finder = find.descendant
        (
            of: find.ancestor(of: find.text(testAnalysisTitle2), matching: find.byType(SessionsListItem)), 
            matching: find.byType(Checkbox)
        );
        await tester.ensureVisible(checkbox2Finder);
        await tester.tap(checkbox2Finder);
        await tester.pumpAndSettle();

        // ── 3. BULK DELETION ─────────────────────────────────────────────────────────────
        // ─────────────────────────────────────────────────────────────────────────────────
        // Searching the widget
        var bulkDeletionFinder = find.textContaining("Delete");
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
        var textFinder = find.text(testAnalysisTitle3);
        Text textWidget = tester.widget(textFinder);
        expect(textWidget.data, testAnalysisTitle3);

        // Verifying that only kw3 is present
        filterChipFinder = find.byType(FilterChip);
        expect(filterChipFinder, findsNWidgets(1));
        expect(find.text("kw3"), findsOne);

        // await tester.pump(const Duration(seconds: 2));
      }
    }      
  );      

  
  });

    group("Preview Tests: Mobile: \n", () 
  {
    // "Session data entered is found on the preview: "
    // "all fields empty \n"
    // "(assuming an already selected path to the user session data folder)",
    testWidgets(
      "Session data entered is found on the preview: "
      "all fields empty \n"
      "(assuming an already selected path to the user session data folder)",
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          "wasFirstRunModalAcknowledged": true,
          // and to have the context analysis page, with the dashboard.
          "wasCASessionDataSaved": true,
          // Temporary test dir as application folder path
          "applicationFolderPath": testTmpDir!.path
        });

        if (Platform.isAndroid || Platform.isIOS)
        {
          // Pumping the CAPage        
          await tester.pumpWidget(buildTestableCAPage());
          await tester.pumpAndSettle();

          // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────

          // All CA form fields empty in the default parameter values
          await caEnterNewProcessDataOnMobile
          (
            tester: tester, 
            title: testAnalysisTitle2,
            kwsList: kwsList2Keywords,
            fileNameWithoutExtension: fileName1WithoutExtension
          );

          // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords
          
          // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2)); 
          await dashboardSearchTitleAndKeywords(title: testAnalysisTitle2, kws: kwsList2Keywords);

          // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────────
          // Default parameter values for empty CA form fields
          await caTestPreview(tester: tester, title: testAnalysisTitle2);

          // await tester.pump(const Duration(seconds: 2));

        }
      }
    );

    // "Session data entered is found on the preview: "
    // "all fields filled \n"
    // "(assuming an already selected path to the user session data folder)",
    testWidgets(
      "Session data entered is found on the preview: "
      "all fields filled \n"
      "(assuming an already selected path to the user session data folder)",
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          "wasFirstRunModalAcknowledged": true,
          // and to have the context analysis page, with the dashboard.
          "wasCASessionDataSaved": true,
          // Temporary test dir as application folder path
          "applicationFolderPath": testTmpDir!.path
        });

        if (Platform.isAndroid || Platform.isIOS)
        {
          // Pumping the CAPage
          //
          // pumpWidget renders the first frame.
          // pumpAndSettle drives the event loop until there are no more pending frames,
          // letting the async getPreferences() call complete 
          // and setState(() { _preferencesLoading = false; }) rebuild the tree.
          //
          
          await tester.pumpWidget(buildTestableCAPage());
          await tester.pumpAndSettle();

          // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────

          // Individual perspective testing values
          // 7 values are necessary
          List<bool> checkboxValues = List.filled(7, true);
          // a1 to a7
          List<String> checkboxTextFieldValues = List.generate(7, (i) => "a${i+1}");
          String indivAnotherIssueStrValue = "a8";        

          // Group/teams perspective testing values
          String groupProblemsToSolveStrValue = "b1";
          // 4 values are necessary
          List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"No","Yes"}];
          // b2 to b5
          List<String> segmentedButtonTextFieldValues = List.generate(4, (i) => "b${i+2}");

          await caEnterNewProcessDataOnMobile
          (
            tester: tester, 
            title: testAnalysisTitle2,
            kwsList: kwsList2Keywords,
            checkboxValues: checkboxValues,
            checkboxTextFieldValues: checkboxTextFieldValues,
            indivAnotherIssueStrValue: indivAnotherIssueStrValue,
            groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
            segmentedButtonValues: segmentedButtonValues,
            segmentedButtonTextFieldValues: segmentedButtonTextFieldValues,
            fileNameWithoutExtension: fileName1WithoutExtension
          );

          // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords
          
          // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2));
          await dashboardSearchTitleAndKeywords(title: testAnalysisTitle2, kws: kwsList2Keywords);

          // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────────
          // Putting all string values together, to retrieve them by index
          List<String> individualStringValues = [...checkboxTextFieldValues, indivAnotherIssueStrValue];
          List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

          await caTestPreview(tester: tester, title: testAnalysisTitle2 , individualStringValues: individualStringValues, 
          segmentedButtonValues: segmentedButtonValues, groupStringValues: groupStringValues);

          // await tester.pump(const Duration(seconds: 2));
        }
      },
    );

    // "Session data entered is found on the preview: "
    // "not all fields filled: 1: several unchecked checkboxes, several unselected segmented buttons, empty text field only items \n"
    // "(assuming an already selected path to the user session data folder)",
    testWidgets(
    "Session data entered is found on the preview: "
    "not all fields filled: 1: several unchecked checkboxes, several unselected segmented buttons, empty text field only items \n"
    "(assuming an already selected path to the user session data folder)",
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        "wasFirstRunModalAcknowledged": true,
        // and to have the context analysis page, with the dashboard.
        "wasCASessionDataSaved": true,
        // Temporary test dir as application folder path
        "applicationFolderPath": testTmpDir!.path
      });

      if (Platform.isAndroid || Platform.isIOS)
      {
        // Pumping the CAPage
        //
        // pumpWidget renders the first frame.
        // pumpAndSettle drives the event loop until there are no more pending frames,
        // letting the async getPreferences() call complete 
        // and setState(() { _preferencesLoading = false; }) rebuild the tree.
        //
        
        await tester.pumpWidget(buildTestableCAPage());
        await tester.pumpAndSettle();

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────

        // Individual perspective testing values
        // 7 values are necessary
        List<bool> checkboxValues = [true, false, false, true, true, true, false];
        List<String> checkboxTextFieldValues = ["a1", "", "", "a4", "a5", "a6", ""];       
        String indivAnotherIssueStrValue = "";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "";
        // 4 values are necessary
        List<Set<String>> segmentedButtonValues = [{"Yes"},{},{"I don't know"},{}];
        List<String> segmentedButtonTextFieldValues = ["b2", "", "b4",""];

        await caEnterNewProcessDataOnMobile
          (
            tester: tester, 
            title: testAnalysisTitle2,
            kwsList: kwsList2Keywords,
            checkboxValues: checkboxValues,
            checkboxTextFieldValues: checkboxTextFieldValues,
            indivAnotherIssueStrValue: indivAnotherIssueStrValue,
            groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
            segmentedButtonValues: segmentedButtonValues,
            segmentedButtonTextFieldValues: segmentedButtonTextFieldValues,
            fileNameWithoutExtension: fileName1WithoutExtension
          );
        
        // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the title and keywords
        
        // To avoid intermittent test failures
        await tester.pump(const Duration(seconds: 2));
        await dashboardSearchTitleAndKeywords(title: testAnalysisTitle2, kws: kwsList2Keywords);

        // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxTextFieldValues, indivAnotherIssueStrValue]
          .where((string) => string.isNotEmpty)
          .toList();

        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

        await caTestPreview(tester: tester, title:testAnalysisTitle2 ,individualStringValues: individualStringValues, 
        segmentedButtonValues: segmentedButtonValues, groupStringValues: groupStringValues);

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

    // "Session data entered is found on the preview: "
    // "not all fields filled: 2: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n"
    // "(assuming an already selected path to the user session data folder)",
    testWidgets(
    "Session data entered is found on the preview: "
    "not all fields filled: 2: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n"
    "(assuming an already selected path to the user session data folder)",
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        "wasFirstRunModalAcknowledged": true,
        // and to have the context analysis page, with the dashboard.
        "wasCASessionDataSaved": true,
        // Temporary test dir as application folder path
        "applicationFolderPath": testTmpDir!.path
      });

      if (Platform.isAndroid || Platform.isIOS)
      {
        // Pumping the CAPage
        //
        // pumpWidget renders the first frame.
        // pumpAndSettle drives the event loop until there are no more pending frames,
        // letting the async getPreferences() call complete 
        // and setState(() { _preferencesLoading = false; }) rebuild the tree.
        //
        
        await tester.pumpWidget(buildTestableCAPage());
        await tester.pumpAndSettle();

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        // Individual perspective testing values
        // 7 values are necessary
        List<bool> checkboxValues = [false, true, false, false, true, true, false];
        List<String> checkboxTextFieldValues = ["", "a2",  "", "", "a5", "a6", ""];       
        String indivAnotherIssueStrValue = "";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "b1";
        // 4 values are necessary
        List<Set<String>> segmentedButtonValues = [{},{"No"},{},{"I don't know"}];
        List<String> segmentedButtonTextFieldValues = ["", "b3", "", "b5"];

        await caEnterNewProcessDataOnMobile
        (
          tester: tester, 
          title: testAnalysisTitle2,
          kwsList: kwsList2Keywords,
          checkboxValues: checkboxValues,
          checkboxTextFieldValues: checkboxTextFieldValues,
          indivAnotherIssueStrValue: indivAnotherIssueStrValue,
          groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
          segmentedButtonValues: segmentedButtonValues,
          segmentedButtonTextFieldValues: segmentedButtonTextFieldValues,
          fileNameWithoutExtension: fileName1WithoutExtension
        );
        
        // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the title and keywords
        
        // To avoid intermittent test failures
        await tester.pump(const Duration(seconds: 2));
        await dashboardSearchTitleAndKeywords(title: testAnalysisTitle2, kws: kwsList2Keywords);

        // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxTextFieldValues, indivAnotherIssueStrValue]
          .where((string) => string.isNotEmpty)
          .toList();

        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

        await caTestPreview(tester: tester, title: testAnalysisTitle2, individualStringValues: individualStringValues, 
        segmentedButtonValues: segmentedButtonValues, groupStringValues: groupStringValues);

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

    // "Session data entered is found on the preview: "
    // "not all fields filled: 3: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n"
    // "(assuming an already selected path to the user session data folder)",
    testWidgets(
    "Session data entered is found on the preview: "
    "not all fields filled: 3: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n"
    "(assuming an already selected path to the user session data folder)",
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        "wasFirstRunModalAcknowledged": true,
        // and to have the context analysis page, with the dashboard.
        "wasCASessionDataSaved": true,
        // Temporary test dir as application folder path
        "applicationFolderPath": testTmpDir!.path
      });

      if (Platform.isAndroid || Platform.isIOS)
      {
        // Pumping the CAPage
        //
        // pumpWidget renders the first frame.
        // pumpAndSettle drives the event loop until there are no more pending frames,
        // letting the async getPreferences() call complete 
        // and setState(() { _preferencesLoading = false; }) rebuild the tree.
        //
        
        await tester.pumpWidget(buildTestableCAPage());
        await tester.pumpAndSettle();

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        // Individual perspective testing values
        // 7 values are necessary
        List<bool> checkboxValues = [true, false, false, false, true, true, true];
        List<String> checkboxTextFieldValues = ["a1", "",  "", "", "a5", "a6", "a7"];       
        String indivAnotherIssueStrValue = "a8";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "";
        // 4 values are necessary
        List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{},{"I don't know"}];
        List<String> segmentedButtonTextFieldValues = ["b2", "b3", "", "b5"];
        
        await caEnterNewProcessDataOnMobile
        (
          tester: tester, 
          title: testAnalysisTitle2,
          kwsList: kwsList2Keywords,
          checkboxValues: checkboxValues,
          checkboxTextFieldValues: checkboxTextFieldValues,
          indivAnotherIssueStrValue: indivAnotherIssueStrValue,
          groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
          segmentedButtonValues: segmentedButtonValues,
          segmentedButtonTextFieldValues: segmentedButtonTextFieldValues,
          fileNameWithoutExtension: fileName1WithoutExtension
        );

        // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the title and keywords
        
        // To avoid intermittent test failures
        await tester.pump(const Duration(seconds: 2));
        await dashboardSearchTitleAndKeywords(title: testAnalysisTitle2, kws: kwsList2Keywords);
        
        // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxTextFieldValues, indivAnotherIssueStrValue]
          .where((string) => string.isNotEmpty)
          .toList();

        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

        await caTestPreview(tester: tester, title: testAnalysisTitle2, individualStringValues: individualStringValues, 
        segmentedButtonValues: segmentedButtonValues, groupStringValues: groupStringValues);

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

  });

    group("Edition Tests: Mobile: \n", ()
    {
      // "Edition: Title \n"
      testWidgets(
        "Edition: Title \n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis page, with the dashboard.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the CAPage        
            await tester.pumpWidget(buildTestableCAPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            var title = "CA title";

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: [],
              formToFill: false,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            await tester.pump(const Duration(seconds: 2));

            // ── 2. CLICKING TO EDIT THE TITLE ─────────────────────────────────
            // ──────────────────────────────────────────────────────────────────
              // Clicking on the title
            var titleFinder = find.text(title);
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();
              // Editing the title
            var editedTitle = "${title}${editionSuffix}";
            
            var editTfecFinder = find.byKey(const Key("titleDashboardEditField"));
            await tester.enterText(editTfecFinder, editedTitle);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

              // Verifying the text field absent
            expect(editTfecFinder, findsNothing);
              // Verifying the edited title present
            expect(find.text(editedTitle), findsOne);
          }
        });
  
      // "Edition: Keywords \n"
      testWidgets(
        "Edition: Keywords \n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis page, with the dashboard.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the CAPage        
            await tester.pumpWidget(buildTestableCAPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            var title = "CA title";

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: [kwsList2Keywords[0]],
              formToFill: false,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            await tester.pump(const Duration(seconds: 2));

            // ── 2. CLICKING TO EDIT THE KEYWORDS ─────────────────────────────────
            // ──────────────────────────────────────────────────────────────────
              // Clicking on the keyword
            var kwFinder = find.descendant
            (
              of: find.byType(SessionsListItem), 
              matching: find.textContaining(kwsList2Keywords[0])
            );            
            await tester.tap(kwFinder);
            await tester.pumpAndSettle();
              // Editing the keywords
            var kwEdited = "${kwsList2Keywords[0]}${editionSuffix}";
            var kwAdded = "kwAdded";
            var editedKeywords = "$kwEdited,$kwAdded";
            
            var editTfecFinder = find.byKey(const Key("kwsDashboardEditField"));
            await tester.enterText(editTfecFinder, editedKeywords);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();
              // Verifying the text field absent
            expect(editTfecFinder, findsNothing);
              // Verifying the input chips present
            var kw1Finder = find.descendant
            (
              of: find.byType(FilterChip), 
              matching: find.text(kwEdited)
            );
            expect(kw1Finder, findsOne);

            var kw2Finder = find.descendant
            (
              of: find.byType(FilterChip), 
              matching: find.text(kwAdded)
            );
            expect(kw2Finder, findsOne);            
          }
        });
  
      // "Context analysis data edition (from preview) \n"
      testWidgets(
        "Context analysis data edition (from preview) \n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis page, with the dashboard.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the CAPage        
            await tester.pumpWidget(buildTestableCAPage());
            await tester.pumpAndSettle();

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            var title = "CA title";
            
            // Individual perspective testing values
            // All checkboxes checked
            List<bool> checkboxValues = List.filled(7, true);
            // Values from a1 to a7 for the checkboxes text fields
            List<String> checkboxTextFieldValues = List.generate(7, (i) => "a${i+1}");  
            // a8 for the text field only (indiv. persp.)        
            String indivAnotherIssueStrValue = "a8";        

            // Group/teams perspective testing values
            // b1 for the text field only (group persp.)
            String groupProblemsToSolveStrValue = "b1";
            // 4 values are necessary for the segmented buttons
            List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"Yes","No"}];
            // Values from b2 to b5 for the segmented button text fields
            List<String> segmentedButtonTextFieldValues = List.generate(4, (i) => "b${i+2}");

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: kwsList2Keywords,
              checkboxValues: checkboxValues,
              checkboxTextFieldValues: checkboxTextFieldValues,
              indivAnotherIssueStrValue: indivAnotherIssueStrValue,
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
              segmentedButtonValues: segmentedButtonValues,
              segmentedButtonTextFieldValues: segmentedButtonTextFieldValues,
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

            // ── Verifying data present ────────────────────────────
            // ──────────────────────────────────────────────────────

            // Opening the expansion tiles
            await caOpenIndividualExpansionTile(tester);
            await caOpenGroupExpansionTile(tester);

            // ── Verifying checkbox data present ────────────────────────────
            var checkboxesFinder = find.byType(Checkbox);
            var totalCheckboxes = checkboxesFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalCheckboxes: $totalCheckboxes");

            for (var cbIndex = 0; cbIndex < totalCheckboxes; cbIndex++)
            {
              // cbIndex = 1: keywords: skipping the text field
              if (cbIndex != 1) 
              {
                expect(tester.widget<Checkbox>(checkboxesFinder.at(cbIndex)).value, checkboxValues[cbIndex]);
              }
            }

            // ── Verifying segmented button data present ────────────────────────────
            var segmentedButtonsFinder = 
              find.descendant(
                of: find.byType(ExpansionTile).last, 
                matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
              );

            var totalSegmentedButtons = segmentedButtonsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalSegmentedButtons: $totalSegmentedButtons (4: expected)");

            for (var sbIndex = 0; sbIndex < totalSegmentedButtons; sbIndex++)
            {
                expect(tester.widget<CASegmentedButtonWithSanitizedAndPaddedTextField>(segmentedButtonsFinder.at(sbIndex)).segButtonStartValue, segmentedButtonValues[sbIndex]);
            }

            // ── Verifying text field data present ────────────────────────────
            var textFieldsFinder = find.byType(TextField);
            var totalTextFields = textFieldsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalTextFields: $totalTextFields (expected: 16)");

            // null for keywords
            // Should have 16 values
            // 1 + 1 + 7 + 1
            // + 1 + 4 + 1
            var expectedData = [title, null, ...checkboxTextFieldValues, indivAnotherIssueStrValue,
                                groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues, fileName1WithoutExtension];

            for (var tfIndex = 0; tfIndex < totalTextFields; tfIndex++)
            {
              // Skipping: 1 (keywords text field), 12 (file name text field)
              if 
              (
                // keywords
                tfIndex != 1 
                && tfIndex != 12
              ) 
              {
                expect(tester.widget<TextField>(textFieldsFinder.at(tfIndex)).controller!.text, expectedData[tfIndex]);
              }
            }


            // ── Editing data ────────────────────────────
            // ────────────────────────────────────────────

            // ── Leaving the checkboxes as is ────────────────────────────
 
            // ── Editing data in the segmented buttons ────────────────────────────
            // Original values: List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"Yes","No"}];
            List<Set<String>> newSegmentedButtonValues = [{"No","Yes"},{"No","Yes"},{"I don't know","Yes"},{"I don't know" , "No", "Yes"}];
            List<String> segmentedButtonsAddedValues = ["No", "Yes", "Yes", "I don't know"];

            segmentedButtonsFinder = find.descendant(
              of: find.byType(ExpansionTile).last, 
              matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
            );

            totalSegmentedButtons = segmentedButtonsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalSegmentedButtons: $totalSegmentedButtons (4: expected)");

            var optionsToSelect = ["Yes","No","I don't know"];
            for (var sbIndex = 0; sbIndex < totalSegmentedButtons; sbIndex++)
            {
              var currentSegmentedButtonFinder = segmentedButtonsFinder.at(sbIndex);

              for (var option in optionsToSelect)
              {
                // additional option to tap
                var currentSegmentedButtonAddedValue = segmentedButtonsAddedValues[sbIndex];

                if (currentSegmentedButtonAddedValue.contains(option))
                {
                  var optionFinder = find.descendant
                                      (of: currentSegmentedButtonFinder,
                                        matching: find.text(option));

                  await tester.ensureVisible(currentSegmentedButtonFinder);
                  await tester.pumpAndSettle();
                  await tester.tap(optionFinder);
                  await tester.pumpAndSettle();
                }
              }     
            }

            // ── Editing data in the text fields ────────────────────────────

            List<String> newCheckboxTextFieldValues = 
            [for (var value in checkboxTextFieldValues) "${value}${editionSuffix}"]; 

            String newIndivAnotherIssueStrValue = "a8$editionSuffix";   

            String newGroupProblemsToSolveStrValue = "b1$editionSuffix";

            List<String> newSegmentedButtonTextFieldValues = 
            [ for (var value in segmentedButtonTextFieldValues) "${value}${editionSuffix}" ]; 

            textFieldsFinder = find.byType(TextField);
            totalTextFields = textFieldsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalTextFields: $totalTextFields (expected: 16)");

            // null for keywords and file name
            // Should have 16 values
            // 1 + 1 + 7 + 1
            // + 1 + 4 + 1
            var dataList = [title, null, ...newCheckboxTextFieldValues, newIndivAnotherIssueStrValue,
                                newGroupProblemsToSolveStrValue, ...newSegmentedButtonTextFieldValues, null];

            for (var tfIndex = 0; tfIndex < totalTextFields; tfIndex++)
            {
              if 
              (
                // keywords text field untouched
                tfIndex != 1 
                // file name unedited
                && tfIndex != 15
              ) 
              {
                if (testingDebug) pu.printd("Testing Debug: tfIndex: $tfIndex");
                if (testingDebug) pu.printd("dataList[tfIndex]!: ${dataList[tfIndex]!}");

                var currentTextFieldFinder = textFieldsFinder.at(tfIndex);
                await tester.ensureVisible(currentTextFieldFinder);
                await tester.pumpAndSettle();
                await tester.tap(currentTextFieldFinder);
                await tester.pumpAndSettle();
                await tester.enterText(currentTextFieldFinder, dataList[tfIndex]!);
                await tester.pumpAndSettle();
                // data entered only
              }
            }

            // ── Submitting edited data ──────────────────
            // ────────────────────────────────────────────

            Finder fileNameWidgetFinder =  find.byType(SessionFileNameOnMobilePlatforms);
            await tester.ensureVisible(fileNameWidgetFinder);
            await tester.pumpAndSettle();
            await tester.tap(fileNameWidgetFinder);
            await tester.pumpAndSettle();
            // data is already entered
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();  

            // await tester.pump(const Duration(seconds: 2));

            // ── Verifying the edited data present ──────────────────
            // ───────────────────────────────────────────────────────
          
            // ── Opening the preview ──────────────────
            previewFinder = find.byTooltip(previewTooltipLabel);
            await tester.ensureVisible(previewFinder);
            await tester.pumpAndSettle();
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 5));

            var textToFind = "a7$editionSuffix";
            if (testingDebug) pu.printd("Testing Debug: Scrolling toward textToFind: $textToFind for screen copy");
            var textToFindFinder = find.textContaining(textToFind);
            await tester.scrollUntilVisible
            (
              textToFindFinder, 
              45, 
              scrollable: find.descendant
                        (
                          of: find.byKey(const Key("context-analysis-preview-scrollview")), 
                          matching: find.byType(Scrollable)
                        ),
            );            
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 5));
            if (testingDebug) pu.printd("Scrolled to $textToFind");

            textToFind = "b1$editionSuffix";
            if (testingDebug) pu.printd("Testing Debug: Scrolling toward textToFind: $textToFind for screen copy");
            textToFindFinder = find.textContaining(textToFind);
            await tester.scrollUntilVisible
            (
              textToFindFinder, 
              45, 
              scrollable: find.descendant
                        (
                          of: find.byKey(const Key("context-analysis-preview-scrollview")), 
                          matching: find.byType(Scrollable)
                        ),
            );            
            await tester.pumpAndSettle();
            expect(textToFindFinder, findsOne);
            if (testingDebug) pu.printd("Scrolled to $textToFind");

            // await tester.pump(const Duration(seconds: 5));

            if (testingDebug) pu.printd("Scrolling toward title for preview");

            // Scrolling up
            var scrollableFinder = find.descendant
                        (
                          of: find.byKey(const Key("context-analysis-preview-scrollview")), 
                          matching: find.byType(Scrollable)
                        ).first;

            await tester.scrollUntilVisible
            (
              find.text(title).first, 
              -40, // getting up the list
              scrollable: scrollableFinder
            );
            await tester.pumpAndSettle();
            
            if (testingDebug) pu.printd("Testing Debug: Scrolled to title");
            // await tester.pump(const Duration(seconds: 3));

            // ── Verifying the edited data present ──────────────────            
            await caTestPreview
            (
              tester: tester, 
              title: title,
              individualStringValues: [...newCheckboxTextFieldValues, newIndivAnotherIssueStrValue], 
              groupStringValues: [newGroupProblemsToSolveStrValue,...newSegmentedButtonTextFieldValues],
              segmentedButtonValues: newSegmentedButtonValues
            );          
          } // platform-related if

        });

      // "Context analysis data edition (from dashboard) \n"

      testWidgets(
        "Context analysis data edition (from dashboard) \n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis page, with the dashboard.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the CAPage        
            await tester.pumpWidget(buildTestableCAPage());
            await tester.pumpAndSettle();

            // ── ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            var title = "CA title";
            
            // Individual perspective testing values
            // All checkboxes checked
            List<bool> checkboxValues = List.filled(7, true);
            // Values from a1 to a7 for the checkboxes text fields
            List<String> checkboxTextFieldValues = List.generate(7, (i) => "a${i+1}");  
            // a8 for the text field only (indiv. persp.)        
            String indivAnotherIssueStrValue = "a8";        

            // Group/teams perspective testing values
            // b1 for the text field only (group persp.)
            String groupProblemsToSolveStrValue = "b1";
            // 4 values are necessary for the segmented buttons
            List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"Yes","No"}];
            // Values from b2 to b5 for the segmented button text fields
            List<String> segmentedButtonTextFieldValues = List.generate(4, (i) => "b${i+2}");

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: kwsList2Keywords,
              checkboxValues: checkboxValues,
              checkboxTextFieldValues: checkboxTextFieldValues,
              indivAnotherIssueStrValue: indivAnotherIssueStrValue,
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
              segmentedButtonValues: segmentedButtonValues,
              segmentedButtonTextFieldValues: segmentedButtonTextFieldValues,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 2));

            // ── CLICKING ON THE EDIT ICON  ─────────────────────────────────
            // ──────────────────────────────────────────────────────────────────
            var editIconFromItemFinder = find.byTooltip(editFromDashboardItemTooltipLabel);
            await tester.tap(editIconFromItemFinder);
            await tester.pumpAndSettle();

            // ── EDITION: Verifying data present and editing  ─────────────────
            // ────────────────────────────────────────────────────────────────────

            // ── Verifying data present ────────────────────────────
            // ──────────────────────────────────────────────────────

            // Opening the expansion tiles
            await caOpenIndividualExpansionTile(tester);
            await caOpenGroupExpansionTile(tester);

            // ── Verifying checkbox data present ────────────────────────────
            var checkboxesFinder = find.byType(Checkbox);
            var totalCheckboxes = checkboxesFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalCheckboxes: $totalCheckboxes");

            for (var cbIndex = 0; cbIndex < totalCheckboxes; cbIndex++)
            {
              // cbIndex = 1: keywords: skipping the text field
              if (cbIndex != 1) 
              {
                expect(tester.widget<Checkbox>(checkboxesFinder.at(cbIndex)).value, checkboxValues[cbIndex]);
              }
            }

            // ── Verifying segmented button data present ────────────────────────────
            var segmentedButtonsFinder = 
              find.descendant(
                of: find.byType(ExpansionTile).last, 
                matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
              );

            var totalSegmentedButtons = segmentedButtonsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalSegmentedButtons: $totalSegmentedButtons (4: expected)");

            for (var sbIndex = 0; sbIndex < totalSegmentedButtons; sbIndex++)
            {
                expect(tester.widget<CASegmentedButtonWithSanitizedAndPaddedTextField>(segmentedButtonsFinder.at(sbIndex)).segButtonStartValue, segmentedButtonValues[sbIndex]);
            }

            // ── Verifying text field data present ────────────────────────────
            var textFieldsFinder = find.byType(TextField);
            var totalTextFields = textFieldsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalTextFields: $totalTextFields (expected: 16)");

            // null for keywords
            // Should have 16 values
            // 1 + 1 + 7 + 1
            // + 1 + 4 + 1
            var expectedData = [title, null, ...checkboxTextFieldValues, indivAnotherIssueStrValue,
                                groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues, fileName1WithoutExtension];

            for (var tfIndex = 0; tfIndex < totalTextFields; tfIndex++)
            {
              // Skipping: 1 (keywords text field), 12 (file name text field)
              if 
              (
                // keywords
                tfIndex != 1 
                && tfIndex != 12
              ) 
              {
                expect(tester.widget<TextField>(textFieldsFinder.at(tfIndex)).controller!.text, expectedData[tfIndex]);
              }
            }


            // ── Editing data ────────────────────────────
            // ────────────────────────────────────────────

            // ── Leaving the checkboxes as is ────────────────────────────
 
            // ── Editing data in the segmented buttons ────────────────────────────
            // Original values: List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"Yes","No"}];
            List<Set<String>> newSegmentedButtonValues = [{"No","Yes"},{"No","Yes"},{"I don't know","Yes"},{"I don't know" , "No", "Yes"}];
            List<String> segmentedButtonsAddedValues = ["No", "Yes", "Yes", "I don't know"];

            segmentedButtonsFinder = find.descendant(
              of: find.byType(ExpansionTile).last, 
              matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
            );

            totalSegmentedButtons = segmentedButtonsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalSegmentedButtons: $totalSegmentedButtons (4: expected)");

            var optionsToSelect = ["Yes","No","I don't know"];
            for (var sbIndex = 0; sbIndex < totalSegmentedButtons; sbIndex++)
            {
              var currentSegmentedButtonFinder = segmentedButtonsFinder.at(sbIndex);

              for (var option in optionsToSelect)
              {
                // additional option to tap
                var currentSegmentedButtonAddedValue = segmentedButtonsAddedValues[sbIndex];

                if (currentSegmentedButtonAddedValue.contains(option))
                {
                  var optionFinder = find.descendant
                                      (of: currentSegmentedButtonFinder,
                                        matching: find.text(option));

                  await tester.ensureVisible(currentSegmentedButtonFinder);
                  await tester.pumpAndSettle();
                  await tester.tap(optionFinder);
                  await tester.pumpAndSettle();
                }
              }     
            }

            // ── Editing data in the text fields ────────────────────────────

            List<String> newCheckboxTextFieldValues = 
            [for (var value in checkboxTextFieldValues) "${value}${editionSuffix}"]; 

            String newIndivAnotherIssueStrValue = "a8$editionSuffix";   

            String newGroupProblemsToSolveStrValue = "b1$editionSuffix";

            List<String> newSegmentedButtonTextFieldValues = 
            [ for (var value in segmentedButtonTextFieldValues) "${value}${editionSuffix}" ]; 

            textFieldsFinder = find.byType(TextField);
            totalTextFields = textFieldsFinder.evaluate().length;

            if (testingDebug) pu.printd("Testing Debug: totalTextFields: $totalTextFields (expected: 16)");

            // null for keywords and file name
            // Should have 16 values
            // 1 + 1 + 7 + 1
            // + 1 + 4 + 1
            var dataList = [title, null, ...newCheckboxTextFieldValues, newIndivAnotherIssueStrValue,
                                newGroupProblemsToSolveStrValue, ...newSegmentedButtonTextFieldValues, null];

            for (var tfIndex = 0; tfIndex < totalTextFields; tfIndex++)
            {
              if 
              (
                // keywords text field untouched
                tfIndex != 1 
                // file name unedited
                && tfIndex != 15
              ) 
              {
                if (testingDebug) pu.printd("Testing Debug: tfIndex: $tfIndex");
                if (testingDebug) pu.printd("dataList[tfIndex]!: ${dataList[tfIndex]!}");

                var currentTextFieldFinder = textFieldsFinder.at(tfIndex);
                await tester.ensureVisible(currentTextFieldFinder);
                await tester.pumpAndSettle();
                await tester.tap(currentTextFieldFinder);
                await tester.pumpAndSettle();
                await tester.enterText(currentTextFieldFinder, dataList[tfIndex]!);
                await tester.pumpAndSettle();
                // data entered only
              }
            }

            // ── Submitting edited data ──────────────────
            // ────────────────────────────────────────────

            Finder fileNameWidgetFinder =  find.byType(SessionFileNameOnMobilePlatforms);
            await tester.ensureVisible(fileNameWidgetFinder);
            await tester.pumpAndSettle();
            await tester.tap(fileNameWidgetFinder);
            await tester.pumpAndSettle();
            // data is already entered
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();  

            // await tester.pump(const Duration(seconds: 2));

            // ── Verifying the edited data present ──────────────────
            // ───────────────────────────────────────────────────────
          
            // ── Opening the preview ──────────────────
            var previewFinder = find.byTooltip(previewTooltipLabel);
            await tester.ensureVisible(previewFinder);
            await tester.pumpAndSettle();
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 5));

            var textToFind = "a7$editionSuffix";
            if (testingDebug) pu.printd("Testing Debug: Scrolling toward textToFind: $textToFind for screen copy");
            var textToFindFinder = find.textContaining(textToFind);
            await tester.scrollUntilVisible
            (
              textToFindFinder, 
              45, 
              scrollable: find.descendant
                        (
                          of: find.byKey(const Key("context-analysis-preview-scrollview")), 
                          matching: find.byType(Scrollable)
                        ),
            );            
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 5));
            if (testingDebug) pu.printd("Scrolled to $textToFind");

            textToFind = "b1$editionSuffix";
            if (testingDebug) pu.printd("Testing Debug: Scrolling toward textToFind: $textToFind for screen copy");
            textToFindFinder = find.textContaining(textToFind);
            await tester.scrollUntilVisible
            (
              textToFindFinder, 
              45, 
              scrollable: find.descendant
                        (
                          of: find.byKey(const Key("context-analysis-preview-scrollview")), 
                          matching: find.byType(Scrollable)
                        ),
            );            
            await tester.pumpAndSettle();
            expect(textToFindFinder, findsOne);
            if (testingDebug) pu.printd("Scrolled to $textToFind");

            // await tester.pump(const Duration(seconds: 5));

            if (testingDebug) pu.printd("Scrolling toward title for preview");

            // Scrolling up
            var scrollableFinder = find.descendant
                        (
                          of: find.byKey(const Key("context-analysis-preview-scrollview")), 
                          matching: find.byType(Scrollable)
                        ).first;

            await tester.scrollUntilVisible
            (
              find.text(title).first, 
              -40, // getting up the list
              scrollable: scrollableFinder
            );
            await tester.pumpAndSettle();
            
            if (testingDebug) pu.printd("Testing Debug: Scrolled to title");
            // await tester.pump(const Duration(seconds: 3));

            // ── Verifying the edited data present ──────────────────            
            await caTestPreview
            (
              tester: tester, 
              title: title,
              individualStringValues: [...newCheckboxTextFieldValues, newIndivAnotherIssueStrValue], 
              groupStringValues: [newGroupProblemsToSolveStrValue,...newSegmentedButtonTextFieldValues],
              segmentedButtonValues: newSegmentedButtonValues
            );          
          } // platform-related if

        });

      }); 

    group("Visual Tests: Mobile: \n", ()
    {
      // "Sharing \n"
      testWidgets(
        "Sharing \n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis page, with the dashboard.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
              // Pumping the CAPage
              //
              // pumpWidget renders the first frame.
              // pumpAndSettle drives the event loop until there are no more pending frames,
              // letting the async getPreferences() call complete 
              // and setState(() { _preferencesLoading = false; }) rebuild the tree.
              //
              
              await tester.pumpWidget(buildTestableCAPage());
              await tester.pumpAndSettle();

              // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
              // ───────────────────────────────────────────────────────────────────────────────
              await caEnterNewProcessDataOnMobile
              (
                tester: tester, 
                title: testAnalysisTitle1,
                kwsList: [],
                formToFill: false,
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