import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:flutter/services.dart";

import "package:material_ui/material_ui.dart";


import "package:integration_test/integration_test.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_ca_form_questions.dart";
import "package:journeyers/l10n/localized_ca_other_strings.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/l10n/localized_dashboard_strings.dart";
import "package:journeyers/l10n/localized_testing_strings.dart";
import "package:journeyers/pages/context_analysis/context_analysis_page.dart";
import "package:journeyers/utils/generic/testing/test_utils.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/4_dashboard_sessions_list_item.dart";
import "package:journeyers/widgets/utility/process/new_process_button.dart";

import "externalized_code/externalized_testing_code.dart";


// ─── Helper function ──────────────────────────────────────────────────────────────────

/// Wraps the widget under test inside the mandatory Material / Directionality /
/// Localizations ancestors that several Flutter widgets require.
///
/// Providing [AppLocalizations] delegates ensures that any `AppLocalizations.of(context)`
/// call inside CAPage (e.g. the first-run AlertDialog) resolves correctly instead
/// of returning null and falling back to the raw fallback string.
Widget buildTestableCAPage() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales, 
    theme: appTheme,   
    home: const Scaffold
    ( 
      body: CAPage()
    ),
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
  const testAnalysisTitleRoot = "CA session title";
  const testAnalysisTitle1 = "$testAnalysisTitleRoot (1)";
  const testAnalysisTitle2 = "$testAnalysisTitleRoot (2)";
  const testAnalysisTitle3 = "$testAnalysisTitleRoot (3)";
  const List<String> titlesList = [testAnalysisTitle3, testAnalysisTitle1, testAnalysisTitle2];
  const List<String> titlesMaintenance = ["Maintenance topic 1", "Maintenance topic 2", "Maintenance topic 3"];
  const List<String> titlesCompanionship = ["Companionship and Logistics topic", "Companionship and Studies topic"];
  const List<String> titlesWorkplace = ["Workplace and Communication topic"];
  List<String> titlesListKwsSorting = 
                      [
                        titlesMaintenance[0], titlesCompanionship[0], titlesWorkplace[0],
                        titlesCompanionship[1], titlesMaintenance[1], titlesMaintenance[2]
                      ];
  const List<String> titlesListSorted = ["atitl", "aTitle", "atitle2", "Untitled", "untitre"];

  // Keywords
  const kwHarmony = "Harmony";
  const kwWorkplace = "Workplace";
  const kwStudies = "Studies";  
  const kwCommunication = "Communication";
  const kwMaintenance = "Maintenance";
  const kwLogistics = "Logistics";
  const List<String> kwsList2Keywords = [kwHarmony, kwWorkplace];
  const List<List<String>> kwsListsKwsSorting = 
                    [
                      [kwMaintenance], [kwHarmony, kwLogistics], [kwWorkplace, kwCommunication],
                      [kwHarmony, kwStudies], [kwMaintenance], [kwMaintenance],
                    ];

  // Links
  var linkToExternalNotes = "https://ext-notes.com";

  // File names
  const fileNameWithoutExtension = "file";
  List<String> fileNamesWithoutExtensionList = List.generate(3, (i)=>"$fileNameWithoutExtension${i+1}");

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

  group("Context Analysis Integration Tests: Mobile:", () 
  {
    group("Entered metadata is displayed on the dashboard: Mobile:", ()
    {
    testWidgets("Session metadata entered (title, keywords, date) is found: "
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

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedTestingStrings lts = .new(context);

          // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────

            // formToFill: false to skip the form filling
            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              formToFill: false,
              title: testAnalysisTitle1,
              kwsList: kwsList2Keywords,
              fileNameWithoutExtension: fileNameWithoutExtension
            );


          // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords
          
          // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2)); 
          await testTitleAndKeywords(title: testAnalysisTitle1, kws: kwsList2Keywords);

          await tester.pump(const Duration(seconds: 5));

          // Searching for the date
          dateForTestingIndex = 0;
          expect(find.textContaining(lts.datesForTestingList[0]), findsOne);
        }
    });
 
    });

    group("Sorting and filtering Tests: Mobile:", ()
    {
      testWidgets("Sorting by title"
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
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);

            // ── 1. ENTERING NEW CA PROCESS DATA (5 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            var fileNamesList = List.generate(5, (i)=> "file-$i");
            await caEnterSeveralTimesNewProcessDataWithoutFormData
            (
              formToFill: false,
              tester: tester,
              titlesList: ["aTitle", "atitl","atitle2","untitre", "Untitled"],
              kwsLists: [[], [], [], [], []],
              fileNamesWithoutExtensionList: fileNamesList
            );
            // await tester.pump(const Duration(seconds: 2));
          
            // ── 2. SORTING BY TITLE ──────────────────────────────────
            // ────────────────────────────────────────────────────────
            // Triggering the sort
            var sortByTitleFinder = find.textContaining(lds.sortByTitleLabel);
            await tester.tap(sortByTitleFinder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

            // Searching the titles          
            var titlesFinder = await dashboardGetAllSessionsTitles(tester);        

            var totalTitles = titlesFinder.evaluate().length;
            logt("totalTitles: $totalTitles");

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
         
      testWidgets("Sorting by date"
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

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedTestingStrings lts = .new(context);

            // ── 1. ENTERING NEW CA PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await caEnterSeveralTimesNewProcessDataWithoutFormData
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
            var sortByDateFinder = find.textContaining(lds.sortByDateLabel);
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
              expect((tester.widget<Text>(datesFinder.at(index)).data), "(${lts.constJanuaryDatesListSorted[index]})");
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
              expect((tester.widget<Text>(datesFinder.at(index)).data), "(${lts.constJanuaryDatesListSorted.reversed.toList()[index]})");
            }
          }
        });

      testWidgets("Filtering by keywords"
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
              
              await caEnterSeveralTimesNewProcessDataWithoutFormData
              (
                formToFill: false,
                tester: tester,
                titlesList: titlesListKwsSorting,
                kwsLists: kwsListsKwsSorting,
                fileNamesWithoutExtensionList: List.generate(6, (i)=> "file${i+1}")
              );
              // await tester.pump(const Duration(seconds: 4));
            
              // ── 2. FILTERING BY KEYWORDS ────────────────────────────
              List<String> titlesMaintenanceExpected = [titlesMaintenance[2], titlesMaintenance[0],titlesMaintenance[1]];
              List<String> titlesCompanionshipExpected = titlesCompanionship;

              // ────────────────────────────────────────────────────────

              // 1. Filtering by kwMaintenance
              var kwMaintenanceFinder = await dashboardGetKwFilterChip(tester, kwMaintenance);
              await tester.tap(kwMaintenanceFinder);
              await tester.pumpAndSettle();

              // Verifying the titles present
              var titlesFinder = await dashboardGetAllSessionsTitles(tester);
              var totalTitles = titlesFinder.evaluate().length;

              logt("totalTitles for $kwMaintenance: $totalTitles");

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesMaintenanceExpected[index]);
              }
              // Un-selecting the keyword
              await tester.tap(kwMaintenanceFinder);
              await tester.pumpAndSettle();

              // 2. Filtering by kwCompanionship
              var kwCompanionshipFinder = await dashboardGetKwFilterChip(tester, kwHarmony);
              await tester.tap(kwCompanionshipFinder);
              await tester.pumpAndSettle();

              // Verifying the titles present
              titlesFinder = await dashboardGetAllSessionsTitles(tester);
              totalTitles = titlesFinder.evaluate().length;

              logt("totalTitles for $kwHarmony: $totalTitles");

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesCompanionshipExpected[index]);
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

              logt("totalTitles for $kwWorkplace: $totalTitles");

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesWorkplace[index]);
              }
              

              // await tester.pump(const Duration(seconds: 2));
            }
          });     
    });
  
    group("Deletion Tests: Mobile:", ()
  {
  testWidgets("Deletion: Single deletion with icon \n"
    "(the correct snackbar message is displayed) "
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
        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        await caEnterNewProcessDataOnMobile
        (
          formToFill: false,
          tester: tester, 
          title: testAnalysisTitleRoot,
          kwsList: [kwHarmony],              
          fileNameWithoutExtension: fileNameWithoutExtension
        );

        // ── 2. SEARCHING FOR THE SESSION DATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the finder with the title
        Finder sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: testAnalysisTitleRoot);
        expect(sessionListItemFinder, findsOne);

        // await tester.pump(const Duration(seconds: 4));

        // Verifying the Filter Chip present
        var filterChipFinder = find.descendant
        (
          of: find.byType(FilterChip), 
          matching: find.text(kwHarmony)
        );

        expect(filterChipFinder, findsOne);

        // ── 3. TESTING THE DELETION ────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────────
        
        // Searching for the tooltip 
        var deleteIconFinder = find.byTooltip(lds.deleteTooltipLabel);

        // Tapping the icon
        await tester.tap(deleteIconFinder);
        await tester.pumpAndSettle();

        // Verifying the sessions list item absent
        sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: testAnalysisTitleRoot);
        expect(sessionListItemFinder, findsNothing);

        // Verifying the Filter Chip absent
        filterChipFinder = find.descendant
        (
          of: find.byType(FilterChip), 
          matching: find.text(kwHarmony)
        );

        expect(filterChipFinder, findsNothing);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "snackbarMessage",
          expectedTexts: {"en":"Data deleted", "fr":"Données supprimées"}, 
          onScreenValue: lds.snackbarMessageDataDeleted,          
        );

        // Verifying the snackbarMessage present
        expect(find.text(lds.snackbarMessageDataDeleted), findsOne);

        // await tester.pump(const Duration(seconds: 2));
      }
    }      
  );

  testWidgets("Deletion: Bulk deletion"
              "(the correct snackbar message is displayed) "
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

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);
        LocalizedGPSStrings lgps = .new(context);

        // ── 1. ENTERING NEW CA PROCESS DATA (3 times) ──────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        await caEnterSeveralTimesNewProcessDataWithoutFormData
        (
          formToFill: false,
          tester: tester,
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
        var bulkDeletionFinder = find.textContaining(lgps.ideasListBulkDeletionText);
        expect(bulkDeletionFinder, findsOne);
        await tester.ensureVisible(bulkDeletionFinder);
        await tester.tap(bulkDeletionFinder);
        await tester.pumpAndSettle();

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "snackbarMessage",
          expectedTexts: {"en":"Data deleted", "fr":"Données supprimées"}, 
          onScreenValue: lds.snackbarMessageDataDeleted,          
        );
        // Verifying the snackbarMessage present
        expect(find.text(lds.snackbarMessageDataDeleted), findsOne);

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

    group("Preview Tests: Mobile:", () 
  {
    testWidgets("Session data entered is found on the preview: "
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
            title: testAnalysisTitleRoot,
            kwsList: kwsList2Keywords,
            linkToExternalNotes: linkToExternalNotes,
            fileNameWithoutExtension: fileNameWithoutExtension
          );

          // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords
          
          // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2)); 
          await testTitleAndKeywords(title: testAnalysisTitleRoot, kws: kwsList2Keywords);

          // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────────
          // Default parameter values for empty CA form fields
          var context = tester.element(find.byType(Scaffold).first);
          
          await caTestPreview
          (
            context: context, 
            tester: tester, 
            title: testAnalysisTitleRoot, 
            linkToExternalNotes: linkToExternalNotes,
            checkboxesValues: [], 
            individualStringValues: [], 
            segmentedButtonsValues: [], 
            groupStringValues: []
          );

          // await tester.pump(const Duration(seconds: 2));

        }
      }
    );

    testWidgets("Session data entered is found on the preview: "
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
          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedCAOtherStrings los= .new(context);

          // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────

          // Individual perspective testing values
          // 7 values are necessary
          List<bool> checkboxesValues = List.filled(7, true);
          // a1 to a7
          List<String> checkboxesTextFieldValues = List.generate(7, (i) => "a${i+1}");
          String indivAnotherIssueStrValue = "a8";        

          // Group/teams perspective testing values
          String groupProblemsToSolveStrValue = "b1";
          // 4 values are necessary
          List<Set<String>> segmentedButtonsValues = [{los.yes},{los.no},{los.iDontKnow},{los.no,los.yes}];
          // b2 to b5
          List<String> segmentedButtonsTextFieldValues = List.generate(4, (i) => "b${i+2}");

          await caEnterNewProcessDataOnMobile
          (
            tester: tester, 
            title: testAnalysisTitleRoot,
            kwsList: kwsList2Keywords,
            checkboxesValues: checkboxesValues,
            checkboxesTextFieldValues: checkboxesTextFieldValues,
            indivAnotherIssueStrValue: indivAnotherIssueStrValue,
            groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
            segmentedButtonsValues: segmentedButtonsValues,
            segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
            fileNameWithoutExtension: fileNameWithoutExtension
          );

          // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords
          
          // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2));
          await testTitleAndKeywords(title: testAnalysisTitleRoot, kws: kwsList2Keywords);

          // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────────
          // Putting all string values together, to retrieve them by index
          List<String> individualStringValues = [...checkboxesTextFieldValues, indivAnotherIssueStrValue];
          List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonsTextFieldValues];

          await caTestPreview
          (
            context: context, 
            tester: tester, 
            title: testAnalysisTitleRoot, 
            linkToExternalNotes: linkToExternalNotes,
            checkboxesValues: checkboxesValues, 
            individualStringValues: individualStringValues, 
            segmentedButtonsValues: segmentedButtonsValues,
            groupStringValues: groupStringValues            
          );

          // await tester.pump(const Duration(seconds: 2));
        }
      },
    );

    testWidgets("Session data entered is found on the preview: "
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
        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedCAOtherStrings los= .new(context);

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────

        // Individual perspective testing values
        // 7 values are necessary
        List<bool> checkboxesValues = [true, false, false, true, true, true, false];
        List<String> checkboxesTextFieldValues = ["a1", "", "", "a4", "a5", "a6", ""];       
        String indivAnotherIssueStrValue = "";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "";
        // 4 values are necessary
        List<Set<String>> segmentedButtonsValues = [{los.yes},{},{los.iDontKnow},{}];
        List<String> segmentedButtonsTextFieldValues = ["b2", "", "b4",""];

        await caEnterNewProcessDataOnMobile
        (
          tester: tester, 
          title: testAnalysisTitleRoot,
          kwsList: kwsList2Keywords,
          checkboxesValues: checkboxesValues,
          checkboxesTextFieldValues: checkboxesTextFieldValues,
          indivAnotherIssueStrValue: indivAnotherIssueStrValue,
          groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
          segmentedButtonsValues: segmentedButtonsValues,
          segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
          fileNameWithoutExtension: fileNameWithoutExtension
        );
        
        // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the title and keywords
        
        // To avoid intermittent test failures
        await tester.pump(const Duration(seconds: 2));
        await testTitleAndKeywords(title: testAnalysisTitleRoot, kws: kwsList2Keywords);

        // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxesTextFieldValues, indivAnotherIssueStrValue];

        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonsTextFieldValues];

        await caTestPreview
        (
          context: context, 
          tester: tester, 
          title:testAnalysisTitleRoot,
          linkToExternalNotes: linkToExternalNotes,
          checkboxesValues: checkboxesValues,
          individualStringValues: individualStringValues, 
          segmentedButtonsValues: segmentedButtonsValues, 
          groupStringValues: groupStringValues, 
          );

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

    testWidgets("Session data entered is found on the preview: "
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
        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedCAOtherStrings los= .new(context);

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        // Individual perspective testing values
        // 7 values are necessary
        List<bool> checkboxesValues = [false, true, false, false, true, true, false];
        List<String> checkboxesTextFieldValues = ["", "a2",  "", "", "a5", "a6", ""];       
        String indivAnotherIssueStrValue = "";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "b1";
        // 4 values are necessary
        List<Set<String>> segmentedButtonsValues = [{},{los.no},{},{los.iDontKnow}];
        List<String> segmentedButtonsTextFieldValues = ["", "b3", "", "b5"];

        await caEnterNewProcessDataOnMobile
        (
          tester: tester, 
          title: testAnalysisTitleRoot,
          kwsList: kwsList2Keywords,
          checkboxesValues: checkboxesValues,
          checkboxesTextFieldValues: checkboxesTextFieldValues,
          indivAnotherIssueStrValue: indivAnotherIssueStrValue,
          groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
          segmentedButtonsValues: segmentedButtonsValues,
          segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
          fileNameWithoutExtension: fileNameWithoutExtension
        );
        
        // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the title and keywords
        
        // To avoid intermittent test failures
        await tester.pump(const Duration(seconds: 2));
        await testTitleAndKeywords(title: testAnalysisTitleRoot, kws: kwsList2Keywords);

        // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxesTextFieldValues, indivAnotherIssueStrValue];

        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonsTextFieldValues];

        await caTestPreview
        (
          context: context, 
          tester: tester, 
          title: testAnalysisTitleRoot, 
          linkToExternalNotes: linkToExternalNotes,
          individualStringValues: individualStringValues, 
          segmentedButtonsValues: segmentedButtonsValues, 
          groupStringValues: groupStringValues, 
          checkboxesValues: checkboxesValues
        );

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

    testWidgets("Session data entered is found on the preview: "
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
        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedCAOtherStrings los= .new(context);

        // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────
        
        // Individual perspective testing values
        // 7 values are necessary
        List<bool> checkboxesValues = [true, false, false, false, true, true, true];
        List<String> checkboxesTextFieldValues = ["a1", "",  "", "", "a5", "a6", "a7"];       
        String indivAnotherIssueStrValue = "a8";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "";
        // 4 values are necessary
        List<Set<String>> segmentedButtonsValues = [{los.yes},{los.no},{},{los.iDontKnow}];
        List<String> segmentedButtonsTextFieldValues = ["b2", "b3", "", "b5"];
        
        await caEnterNewProcessDataOnMobile
        (
          tester: tester, 
          title: testAnalysisTitleRoot,
          kwsList: kwsList2Keywords,
          checkboxesValues: checkboxesValues,
          checkboxesTextFieldValues: checkboxesTextFieldValues,
          indivAnotherIssueStrValue: indivAnotherIssueStrValue,
          groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
          segmentedButtonsValues: segmentedButtonsValues,
          segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
          fileNameWithoutExtension: fileNameWithoutExtension
        );

        // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────
        // Searching for the title and keywords
        
        // To avoid intermittent test failures
        await tester.pump(const Duration(seconds: 2));
        await testTitleAndKeywords(title: testAnalysisTitleRoot, kws: kwsList2Keywords);
        
        // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxesTextFieldValues, indivAnotherIssueStrValue];

        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonsTextFieldValues];

        await caTestPreview
        (
          context: context, 
          tester: tester, 
          title: testAnalysisTitleRoot, 
          linkToExternalNotes: linkToExternalNotes,
          checkboxesValues: checkboxesValues,
          individualStringValues: individualStringValues, 
          segmentedButtonsValues: segmentedButtonsValues, 
          groupStringValues: groupStringValues          
        );

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

  });

    group("Edition Tests: Mobile:", ()
    {
      testWidgets("Edition: Title (non empty edited title)\n"
                  "(the correct snackbar message is displayed) ",
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

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedTestingStrings lts = .new(context);

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            var title = "CA title";

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: [],
              formToFill: false,
              fileNameWithoutExtension: fileNameWithoutExtension
            );

            await tester.pump(const Duration(seconds: 2));

            // ── 2. CLICKING TO EDIT THE TITLE ─────────────────────────────────
            // ──────────────────────────────────────────────────────────────────
              // Clicking on the title
            var titleFinder = find.text(title);
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();
              // Editing the title
            var editedTitle = "${title}${lts.editionSuffix}";
            
            var editTfFinder = find.byKey(const Key("titleDashboardEditField"));
            await tester.enterText(editTfFinder, editedTitle);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Verifying the correct localized string present
            verifyLocalizedStringAsExpected
            (
              tester: tester, 
              label: "snackbarMessage",
              expectedTexts: {"en":"Title updated", "fr":"Titre mis à jour"}, 
              onScreenValue: lds.snackbarMessageTitleUpdated,          
            );
            
            // Verifying the snackbarMessage present
            expect(find.text(lds.snackbarMessageTitleUpdated), findsOne);

            // Verifying the text field absent
            expect(editTfFinder, findsNothing);
            // Verifying the edited title present
            expect(find.text(editedTitle), findsOne);
          }
        });
  
      testWidgets("Edition: Title (empty edited title)", 
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
            fileNameWithoutExtension: fileNameWithoutExtension
          );

          await tester.pump(const Duration(seconds: 2));

          // ── 2. EDITING THE TITLE ─────────────────────────────────
          // ──────────────────────────────────────────────────────────
            // Clicking on the title
          var titleFinder = find.text(title);
          await tester.tap(titleFinder);
          await tester.pumpAndSettle();
            // Editing the title toward empty
          var editedTitle = "";
          
          var editTfFinder = find.byKey(const Key("titleDashboardEditField"));
          await tester.enterText(editTfFinder, editedTitle);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          // ── 3. CLICKING ON THE SAVE BUTTON ────────────────────────
          // ──────────────────────────────────────────────────────────
          var elevatedButtonFinder = find.byKey(const Key("overlay-edit-save-button"),);
          await tester.tap(elevatedButtonFinder);
          await tester.pumpAndSettle();
          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedDashboardStrings lds = .new(context);
          

          // Searching for the error message
          var emptyTitleEditErrorFinder = find.textContaining(lds.emptyTitleEditError);
          expect(emptyTitleEditErrorFinder, findsOne);

          // Verifying bottom sheet remaining present
          expect(find.byType(StatefulBuilder), findsOne);   
        } 
      });            
    
      testWidgets("Edition: Keywords",
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

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedTestingStrings lts = .new(context);

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            var title = "CA title";

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: [kwsList2Keywords[0]],
              formToFill: false,
              fileNameWithoutExtension: fileNameWithoutExtension
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
            var kwEdited = "${kwsList2Keywords[0]}${lts.editionSuffix}";
            var kwAdded = "kwAdded";
            var editedKeywords = "$kwEdited,$kwAdded";
            
            var editTfFinder = find.byKey(const Key("kwsDashboardEditField"));
            await tester.enterText(editTfFinder, editedKeywords);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Verifying the correct localized string present
            verifyLocalizedStringAsExpected
            (
              tester: tester, 
              label: "snackbarMessage",
              expectedTexts: {"en":"Keywords updated", "fr":"Mots-clés mis à jour"}, 
              onScreenValue: lds.snackbarMessageKeywordsUpdated,          
            );

            // Verifying the snackbarMessage present
            expect(find.text(lds.snackbarMessageKeywordsUpdated), findsOne);

              // Verifying the text field absent
            expect(editTfFinder, findsNothing);
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
  
      testWidgets("Context analysis data edition (from preview)",
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

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedCAOtherStrings los= .new(context);
            LocalizedCAFormQuestions lfq = .new(context);
            LocalizedTestingStrings lts = .new(context);

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            // ── 1.a Title  ──────────────────────────────────
            var title = "CA title";
            
            // ── 1.b Keywords  ──────────────────────────────────
            var keywords = kwsList2Keywords;
            
            // ── 1.c Form data  ──────────────────────────────────
            // Individual perspective testing values
            // All checkboxes checked
            List<bool> checkboxesValues = List.filled(7, true);
            // Values from a1 to a7 for the checkboxes text fields
            List<String> checkboxesTextFieldValues = List.generate(7, (i) => "a${i+1}");  
            // a8 for the text field only (indiv. persp.)        
            String indivAnotherIssueStrValue = "a8";        

            // Group/teams perspective testing values
            // b1 for the text field only (group persp.)
            String groupProblemsToSolveStrValue = "b1";
            // 4 values are necessary for the segmented buttons
            List<Set<String>> segmentedButtonsValues = [{los.yes},{los.no},{los.iDontKnow},{los.yes,los.no}];
            // Values from b2 to b5 for the segmented button text fields
            List<String> segmentedButtonsTextFieldValues = List.generate(4, (i) => "b${i+2}");

            // ── 1.d Link to external notes  ──────────────────────────────────
            String linkToExternalNotes = "https://ext-notes.com";

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: keywords,
              checkboxesValues: checkboxesValues,
              checkboxesTextFieldValues: checkboxesTextFieldValues,
              indivAnotherIssueStrValue: indivAnotherIssueStrValue,
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
              segmentedButtonsValues: segmentedButtonsValues,
              segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
              linkToExternalNotes: linkToExternalNotes,
              fileNameWithoutExtension: fileNameWithoutExtension
            );

            await tester.pump(const Duration(seconds: 2));

            // ── 2. CLICKING TO OPEN THE PREVIEW  ─────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────
            // Opening the preview
            var previewFinder = find.byTooltip(lds.previewTooltipLabel);
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();
            //Scrolling to the second half of the screen 
            await tester.scrollUntilVisible(find.text(lfq.level3TitleLegacyIssueForDataSaving), 45, scrollable: find.byType(Scrollable).last);
            await tester.pumpAndSettle();

            await tester.pump(const Duration(seconds: 2));

            // ── 3. EDITION  ─────────────────
            // ────────────────────────────────────────────────────────────────────           
            // ── Editing data in the segmented buttons ────────────────────────────
            List<String> newKwsList = [kwMaintenance, kwLogistics];
            List<bool>  newCheckboxesValues = [true, true, false, true, false, true, true];
            // Original values: List<Set<String>> segmentedButtonsValues = [{"los.yes"},{"los.no"},{"I don't know"},{"los.yes","los.no"}];
            List<Set<String>> newSegmentedButtonsValues = [{los.no,los.yes},{los.no,los.yes},{los.iDontKnow,los.yes},{los.iDontKnow , los.no, los.yes}];
            List<String> newcheckboxesTextFieldValues = 
                          [for (var value in checkboxesTextFieldValues) "${value}${lts.editionSuffix}"]; 
            String newIndivAnotherIssueStrValue = "a8${lts.editionSuffix}";  
            String newGroupProblemsToSolveStrValue = "b1${lts.editionSuffix}";
            List<String> newsegmentedButtonsTextFieldValues = 
                          [ for (var value in segmentedButtonsTextFieldValues) "${value}${lts.editionSuffix}" ]; 

            await caEditDataOnMobile(
              editingFromPreview: true,
              tester: tester, 
              title: title, 
              kwsList: keywords, 
              newKwsList: newKwsList, 
              checkboxesValues: checkboxesValues, 
              newCheckboxesValues: newCheckboxesValues,
              checkboxesTextFieldValues: checkboxesTextFieldValues, 
              indivAnotherIssueStrValue: indivAnotherIssueStrValue, 
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue, 
              segmentedButtonsValues: segmentedButtonsValues, 
              newSegmentedButtonsValues: newSegmentedButtonsValues, 
              segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues, 
              linkToExternalNotes: linkToExternalNotes,
              fileNameWithoutExtension: fileNameWithoutExtension
            );

            // ── 4. VERIFYING THE EDITED DATA PRESENT  ─────────────────────────────────  
            await caTestPreview
            (
              context: context, 
              tester: tester, 
              title: title,
              linkToExternalNotes: linkToExternalNotes,
              checkboxesValues: newCheckboxesValues,
              individualStringValues: [...newcheckboxesTextFieldValues, newIndivAnotherIssueStrValue], 
              groupStringValues: [newGroupProblemsToSolveStrValue,...newsegmentedButtonsTextFieldValues],
              segmentedButtonsValues: newSegmentedButtonsValues,              
            );
          } // platform-related if

        });

      testWidgets("Context analysis data edition (from dashboard)",
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

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedCAOtherStrings los= .new(context);
            LocalizedTestingStrings lts = .new(context);

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            // ── 1.a Title  ──────────────────────────────────
            var title = "CA title";
            
            // ── 1.b Keywords  ──────────────────────────────────
            var keywords = kwsList2Keywords;
            
            // ── 1.c Form data  ──────────────────────────────────
            // Individual perspective testing values
            // All checkboxes checked
            List<bool> checkboxesValues = List.filled(7, true);
            // Values from a1 to a7 for the checkboxes text fields
            List<String> checkboxesTextFieldValues = List.generate(7, (i) => "a${i+1}");  
            // a8 for the text field only (indiv. persp.)        
            String indivAnotherIssueStrValue = "a8";        

            // Group/teams perspective testing values
            // b1 for the text field only (group persp.)
            String groupProblemsToSolveStrValue = "b1";
            // 4 values are necessary for the segmented buttons
            List<Set<String>> segmentedButtonsValues = [{los.yes},{los.no},{los.iDontKnow},{los.yes,los.no}];
            // Values from b2 to b5 for the segmented button text fields
            List<String> segmentedButtonsTextFieldValues = List.generate(4, (i) => "b${i+2}");

            // ── 1.d Link to external notes  ──────────────────────────────────
            String linkToExternalNotes = "https://ext-notes.com";

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: keywords,
              checkboxesValues: checkboxesValues,
              checkboxesTextFieldValues: checkboxesTextFieldValues,
              indivAnotherIssueStrValue: indivAnotherIssueStrValue,
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
              segmentedButtonsValues: segmentedButtonsValues,
              segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
              linkToExternalNotes: linkToExternalNotes,
              fileNameWithoutExtension: fileNameWithoutExtension
            );

            await tester.pump(const Duration(seconds: 2));

            // ── 2. EDITION  ─────────────────
            // ────────────────────────────────────────────────────────────────────           
            // ── Editing data in the segmented buttons ────────────────────────────
            List<String> newKwsList = [kwMaintenance, kwLogistics];
            List<bool>  newCheckboxesValues = [true, true, false, true, false, true, true];
            // Original values: List<Set<String>> segmentedButtonsValues = [{"los.yes"},{"los.no"},{"I don't know"},{"los.yes","los.no"}];
            List<Set<String>> newSegmentedButtonsValues = [{los.no,los.yes},{los.no,los.yes},{los.iDontKnow,los.yes},{los.iDontKnow , los.no, los.yes}];
            List<String> newcheckboxesTextFieldValues = 
                          [for (var value in checkboxesTextFieldValues) "${value}${lts.editionSuffix}"]; 
            String newIndivAnotherIssueStrValue = "a8${lts.editionSuffix}";  
            String newGroupProblemsToSolveStrValue = "b1${lts.editionSuffix}";
            List<String> newsegmentedButtonsTextFieldValues = 
                          [ for (var value in segmentedButtonsTextFieldValues) "${value}${lts.editionSuffix}" ]; 

            await caEditDataOnMobile(
              tester: tester, 
              title: title, 
              kwsList: keywords, 
              newKwsList: newKwsList, 
              checkboxesValues: checkboxesValues, 
              newCheckboxesValues: newCheckboxesValues,
              checkboxesTextFieldValues: checkboxesTextFieldValues, 
              indivAnotherIssueStrValue: indivAnotherIssueStrValue, 
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue, 
              segmentedButtonsValues: segmentedButtonsValues, 
              newSegmentedButtonsValues: newSegmentedButtonsValues, 
              segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues, 
              linkToExternalNotes: linkToExternalNotes,
              fileNameWithoutExtension: fileNameWithoutExtension
            );

            // ── 3. VERIFYING THE EDITED DATA PRESENT  ─────────────────────────────────  
            await caTestPreview
            (
              context: context, 
              tester: tester, 
              title: title,
              linkToExternalNotes: linkToExternalNotes,
              checkboxesValues: newCheckboxesValues,
              individualStringValues: [...newcheckboxesTextFieldValues, newIndivAnotherIssueStrValue], 
              groupStringValues: [newGroupProblemsToSolveStrValue,...newsegmentedButtonsTextFieldValues],
              segmentedButtonsValues: newSegmentedButtonsValues,              
            );          
          } // platform-related if

        });

      testWidgets("Edition data is not retained in next process",
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

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedCAOtherStrings los= .new(context);
            LocalizedTestingStrings lts = .new(context);
            LocalizedCAFormQuestions lfq = .new(context);

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            // ── 1.a Title  ──────────────────────────────────
            var title = "CA title";
            
            // ── 1.b Keywords  ──────────────────────────────────
            var keywords = kwsList2Keywords;
            
            // ── 1.c Form data  ──────────────────────────────────
            // Individual perspective testing values
            // All checkboxes checked
            List<bool> checkboxesValues = List.filled(7, true);
            // Values from a1 to a7 for the checkboxes text fields
            List<String> checkboxesTextFieldValues = List.generate(7, (i) => "a${i+1}");  
            // a8 for the text field only (indiv. persp.)        
            String indivAnotherIssueStrValue = "a8";        

            // Group/teams perspective testing values
            // b1 for the text field only (group persp.)
            String groupProblemsToSolveStrValue = "b1";
            // 4 values are necessary for the segmented buttons
            List<Set<String>> segmentedButtonsValues = [{los.yes},{los.no},{los.iDontKnow},{los.yes,los.no}];
            // Values from b2 to b5 for the segmented button text fields
            List<String> segmentedButtonsTextFieldValues = List.generate(4, (i) => "b${i+2}");

            // ── 1.d Link to external notes  ──────────────────────────────────
            String linkToExternalNotes = "https://ext-notes.com";

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: title,
              kwsList: keywords,
              checkboxesValues: checkboxesValues,
              checkboxesTextFieldValues: checkboxesTextFieldValues,
              indivAnotherIssueStrValue: indivAnotherIssueStrValue,
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
              segmentedButtonsValues: segmentedButtonsValues,
              segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
              linkToExternalNotes: linkToExternalNotes,
              fileNameWithoutExtension: fileNameWithoutExtension
            );

            await tester.pump(const Duration(seconds: 2));

            // ── 2. EDITION  ─────────────────
            // ────────────────────────────────────────────────────────────────────           
            // ── Editing data in the segmented buttons ────────────────────────────
            List<String> newKwsList = [kwMaintenance, kwLogistics];
            List<bool>  newCheckboxesValues = [true, true, false, true, false, true, true];
            // Original values: List<Set<String>> segmentedButtonsValues = [{"los.yes"},{"los.no"},{"I don't know"},{"los.yes","los.no"}];
            List<Set<String>> newSegmentedButtonsValues = [{los.no,los.yes},{los.no,los.yes},{los.iDontKnow,los.yes},{los.iDontKnow , los.no, los.yes}];
            List<String> newcheckboxesTextFieldValues = 
                          [for (var value in checkboxesTextFieldValues) "${value}${lts.editionSuffix}"]; 
            String newIndivAnotherIssueStrValue = "a8${lts.editionSuffix}";  
            String newGroupProblemsToSolveStrValue = "b1${lts.editionSuffix}";
            List<String> newsegmentedButtonsTextFieldValues = 
                          [ for (var value in segmentedButtonsTextFieldValues) "${value}${lts.editionSuffix}" ]; 

            await caEditDataOnMobile(
              tester: tester, 
              title: title, 
              kwsList: keywords, 
              newKwsList: newKwsList, 
              checkboxesValues: checkboxesValues, 
              newCheckboxesValues: newCheckboxesValues,
              checkboxesTextFieldValues: checkboxesTextFieldValues, 
              indivAnotherIssueStrValue: indivAnotherIssueStrValue, 
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue, 
              segmentedButtonsValues: segmentedButtonsValues, 
              newSegmentedButtonsValues: newSegmentedButtonsValues, 
              segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues, 
              linkToExternalNotes: linkToExternalNotes,
              fileNameWithoutExtension: fileNameWithoutExtension
            );

            // ── 3. VERIFYING THE EDITED DATA PRESENT  ─────────────────────────────────  
            await caTestPreview
            (
              context: context, 
              tester: tester, 
              title: title,
              linkToExternalNotes: linkToExternalNotes,
              checkboxesValues: newCheckboxesValues,
              individualStringValues: [...newcheckboxesTextFieldValues, newIndivAnotherIssueStrValue], 
              groupStringValues: [newGroupProblemsToSolveStrValue,...newsegmentedButtonsTextFieldValues],
              segmentedButtonsValues: newSegmentedButtonsValues,              
            );

            // ── 4. STARTING A NEW CA PROCESS ──────────────────
            // ───────────────────────────────────────────────
            var newProcessButtonFinder = find.byType(NewProcessButton);
            await tester.tap(newProcessButtonFinder);
            await tester.pumpAndSettle();

            // ── VERIFYING ALL FIELDS EMPTY ─────────────────
            // ───────────────────────────────────────────────
              // Opening all expansion tiles
            await caOpenIndividualExpansionTile(context, tester);
            await caOpenGroupExpansionTile(context, tester);

            // ── VERIFYING TITLE TEXT FIELD EMPTY ──────────────
            // ──────────────────────────────────────────────────
            var caTitleDeclarationFinder = find.byKey(const Key("ca-process-catitledeclaration-widget"));
            var titleTextFieldFinder = find.descendant(of: caTitleDeclarationFinder, matching: find.byType(TextField));
            var titleTextField = tester.widget<TextField>(titleTextFieldFinder);
            expect(titleTextField.controller!.text,"");

            // ── VERIFYING KEYWORDS TEXT FIELD EMPTY ─────────────
            // ────────────────────────────────────────────────────
            var caKeywordsDeclarationFinder = find.byKey(const Key("ca-process-cakeywordsdeclaration-widget"));
            var keywordsTextFieldFinder = find.descendant(of: caKeywordsDeclarationFinder, matching: find.byType(TextField));
            var keywordsTextField = tester.widget<TextField>(keywordsTextFieldFinder);
            expect(keywordsTextField.controller!.text,"");

            // ── VERIFYING KEYWORDS INPUT CHIPS ABSENT ──────
            // ───────────────────────────────────────────────
            var inputChipsFinder = find.byType(InputChip);
            expect(inputChipsFinder.evaluate().length, 0);

            // ── VERIFYING FORM TEXT FIELDS EMPTY ────────────
            // ────────────────────────────────────────────────
              // Getting the scrollable
            var firstScrollable =  find.descendant
                        (
                          of: find.byKey(const Key("context-analysis-process-scrollview")), 
                          matching: find.byType(Scrollable)
                        ).first;
            
            // ── Individual perspective ────────────          
            await caCheckboxesVerifyEmptyContent
            (
              tester: tester,
              listOfTextsToFind: lfq.childrenOfLevel3TitleBalanceIssue.toList(),
              scrollable: firstScrollable
            );

              // Workplace issue items
            await caCheckboxesVerifyEmptyContent
            (
              tester: tester,
              listOfTextsToFind: lfq.childrenOfLevel3TitleWorkplaceIssue.toList(),
              scrollable: firstScrollable
            );

              // Legacy issue item
            await caCheckboxesVerifyEmptyContent
            (
              tester: tester,
              listOfTextsToFind: lfq.childrenOfLevel3TitleLegacyIssue.toList(),
              scrollable: firstScrollable
            );

              // Another issue item
            await caTextFieldOnlyVerifyEmptyContent
            (
              tester: tester,
              key: const Key("ca-process-another-issue-widget"),
              scrollable: firstScrollable
            );

            // ── Group/teams perspective ────────────
              // Problems to solve item
            await caTextFieldOnlyVerifyEmptyContent
            (
              tester: tester,
              key: const Key("ca-process-group-problems-to-solve-widget"),
              scrollable: firstScrollable
            );            
           
              // Segmented buttons items
            await caSegmentedButtonsVerifyEmptyContent
            (
              context: context,
              tester: tester,
              listOfKeysToFind: 
                [
                  const Key("ca-process-group-same-problems-to-solve-widget"),
                  const Key("ca-process-group-harmony-home-widget"),
                  const Key("ca-process-group-appreciability-at-work-widget"),
                  const Key("ca-process-group-earning-ability-widget")
                ],
              scrollable: firstScrollable
            );
   
            // ── VERIFYING FILE NAME TEXT FIELD EMPTY ────────
            // ────────────────────────────────────────────────
            var sessionFileNameOnMobilePlatformsFinder = find.byKey(const Key("ca-process-sessionfilenameonmobileplatforms-widget"));
            var sessionFileNameOnMobilePlatformsTextField = find.descendant(of: sessionFileNameOnMobilePlatformsFinder, matching: find.byType(TextField));
            var sessionFileNameOnMobilePlatformsTextFieldWidget = tester.widget<TextField>(sessionFileNameOnMobilePlatformsTextField);
            expect(sessionFileNameOnMobilePlatformsTextFieldWidget.controller!.text,"");
            
          } // platform-related if
        });
      }); 

    group("Visual Tests: Mobile:", ()
    {
      testWidgets("Sharing",
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
                fileNameWithoutExtension: fileNameWithoutExtension
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

      testWidgets("Complex data",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the context analysis process.
            "wasCASessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the CAPage        
            await tester.pumpWidget(buildTestableCAPage());
            await tester.pumpAndSettle();
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedCAOtherStrings los= .new(context);
            LocalizedDashboardStrings lds = .new(context);

            // Building data for the form
              // Individual perspective testing values
              // 7 values are necessary
            List<bool> checkboxesValues = List.filled(7, true);
              // Getting the complex data              
            var data = await rootBundle.loadString("assets/caFormLoading/complex_data.txt");           
            List<String> checkboxesTextFieldValues = [data, ...List.filled(7, "")];
            String indivAnotherIssueStrValue = "";        

             // Group/teams perspective testing values
            String groupProblemsToSolveStrValue = "b1";
              // 4 values are necessary   
            List<Set<String>> segmentedButtonsValues = [{los.yes},{los.no},{los.iDontKnow},{los.no,los.yes}];
              // b2 to b5
            List<String> segmentedButtonsTextFieldValues = List.generate(4, (i) => "b${i+2}");

            await caEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: "",
              kwsList: [],
              checkboxesValues: checkboxesValues,
              checkboxesTextFieldValues: checkboxesTextFieldValues,
              indivAnotherIssueStrValue: indivAnotherIssueStrValue,
              groupProblemsToSolveStrValue: groupProblemsToSolveStrValue,
              segmentedButtonsValues: segmentedButtonsValues,
              segmentedButtonsTextFieldValues: segmentedButtonsTextFieldValues,
              fileNameWithoutExtension: fileNameWithoutExtension
            );
           
            // Opening the preview
            var previewFinder = find.byTooltip(lds.previewTooltipLabel);
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();

            await tester.pump(const Duration(seconds: 10));
          }
      });
    });  
  });
}