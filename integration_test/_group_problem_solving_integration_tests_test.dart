import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:integration_test/integration_test.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/l10n/localized_participants_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/test_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/project_specific/dev/test_utils.dart";
import "package:journeyers/widgets/custom/interaction_and_inputs/editable_deletable_text_list_item.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/4_dashboard_sessions_list_item.dart";
import "package:journeyers/l10n/localized_dashboard_strings.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/4_participants_lists_item.dart";
import "package:journeyers/widgets/utility/process/new_process_button.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart";

import "../test/_widget_testing_utils/widget_testing_utils.dart";
import "externalized_code/externalized_testing_code.dart";

// ─── Helper function ──────────────────────────────────────────────────────────────────

/// Wraps the widget under test inside the mandatory Material / Directionality /
/// Localizations ancestors that several Flutter widgets require.
///
/// Providing [AppLocalizations] delegates ensures that any `AppLocalizations.of(context)`
/// call inside GPSPage (e.g. the first-run AlertDialog) resolves correctly instead
/// of returning null and falling back to the raw fallback string.
Widget buildTestableGPSPage() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: appTheme,
    home: const GPSPage(),
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
  const testGPSTitleRoot = "Integration-test GPS session title";
  const testGPSTitle1 = "$testGPSTitleRoot (1)";
  const testGPSTitle2 = "$testGPSTitleRoot (2)";
  const testGPSTitle3 = "$testGPSTitleRoot (3)";
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
  const kwCompanionship = "Companionship";
  const kwWorkplace = "Workplace";
  const kwStudies = "Studies";  
  const kwCommunication = "Communication";
  const kwMaintenance = "Maintenance";
  const kwLogistics = "Logistics";
  const List<String> kwsList2Keywords = [kwCompanionship, kwWorkplace];
  const List<List<String>> kwsListsKwsSorting = 
                    [
                      [kwMaintenance], [kwCompanionship, kwLogistics], [kwWorkplace, kwCommunication],
                      [kwCompanionship, kwStudies], [kwMaintenance], [kwMaintenance],
                    ];

  // Ideas
  const ideasList2Ideas = ["idea1", "idea2"];

  // File names
  const fileName1WithoutExtension = "file1";
  const fileName2WithoutExtension = "file2";
  const fileName3WithoutExtension = "file3";
  const List<String> fileNamesWithoutExtensionList = [fileName1WithoutExtension, fileName2WithoutExtension, fileName3WithoutExtension];

  // Edition
  const editionSuffix = "-edited";

  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;
  
  setUp(() async {
    // Creating a temporary folder to store the files to save
    testTmpDir = await Directory.systemTemp.createTemp("group_problem_solving_integration_test_");
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

  group("Group Problem-Solving Integration Tests: Mobile: \n", () 
  { 
    group("Checklist Tests: \n", () 
    {
      testWidgets("The checklist title border is orange, and turns transparent when all items are checked. "
      "An item checked (and the checkbox) turns to green.",
      (WidgetTester tester) async 
      {
        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          "wasFirstRunModalAcknowledged": true,
          // and to have the group problem-solving page, without the dashboard.
          "wasGPSSessionDataSaved": false,
          // Temporary test dir as application folder path
          "applicationFolderPath": testTmpDir!.path
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

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // Verifying the default rectangle color is orange
          await gpsTestChecklistTitleBorderColor(tester, rectangleColor);

          // Searching the checklist
          var checklistFinder = find.byType(GPSChecklist);

          // Tapping the checklist
          await tester.tap(checklistFinder);
          await tester.pumpAndSettle();

          // Searching the checkbox list tiles in the checklist
          var checkboxListTilesFinder = find.descendant
          (
            of: find.byType(ListView), 
            matching: find.byType(CheckboxListTile)
          );

          var totalCheckboxListTilesFinder = checkboxListTilesFinder.evaluate().length;
          if (testingDebug) pu.printd("Testing Debug: totalCheckboxListTilesFinder: $totalCheckboxListTilesFinder");

          // Verifying their color after tapping them 
          for (var index = 0; index < totalCheckboxListTilesFinder; index++)
          {
            Finder checkboxListTileFinder = checkboxListTilesFinder.at(index);
            await tester.ensureVisible(checkboxListTileFinder);
            await tester.tap(checkboxListTileFinder);
            await tester.pumpAndSettle();

            CheckboxListTile checklistItemWidget = tester.widget<CheckboxListTile>(checkboxListTileFinder);
            if (testingDebug) pu.printd("Testing Debug: checklistItemWidget.value: ${checklistItemWidget.value}");

            Color activeColor = checklistItemWidget.activeColor!;
    
            expect (activeColor, checkboxCheckedColor);        
          }

          // Searching to close the overlay
          var closeChecklistFinder = find.byTooltip(lgps.closeChecklistTooltipLabel);
          await tester.tap(closeChecklistFinder);
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle();
          
          // Verifying the rectangle color is transparent
          await gpsTestChecklistTitleBorderColor(tester, Colors.transparent);

        }
      });
    }); 
    group("Entered metadata is displayed on the dashboard: Mobile: \n", ()
    {
     testWidgets("Session metadata entered (title, keywords, date) is found "
      " and the correct snackbar message is displayed: "
      "(assuming an already selected path to the user session data folder)",
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          "wasFirstRunModalAcknowledged": true,
          // and to have the group problem-solving page, with the dashboard.
          "wasGPSSessionDataSaved": true,
          // Temporary test dir as application folder path
          "applicationFolderPath": testTmpDir!.path
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
          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);
          LocalizedDashboardStrings lds = .new(context);

          // ── 1. ENTERING NEW GPS PROCESS DATA ───────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────
          await gpsEnterNewProcessDataOnMobile
          (
            tester: tester, 
            title: testGPSTitle1,
            kwsList: kwsList2Keywords,
            ideasList: ideasListAtLeastOneIdeaNeeded,
            fileNameWithoutExtension: fileName1WithoutExtension
          );

          // ── 2. VERIFYING THE CORRECT SNACKBAR MESSAGE PRESENT ───────────────────────────────────────────
          // snackbarMessage hard-coded strings
          var snackbarMessage = "";
          
          var localeLanguageCode = getLocaleLanguageCode(tester);

          switch(localeLanguageCode.toLowerCase())
          {
            case("en"): { snackbarMessage = "Session data saved"; }
            case("fr"): { snackbarMessage = "Session sauvegardée"; }        
          }
          
          if (testingDebug) pu.printd("Testing Debug: snackbarMessage: $snackbarMessage");
          
          // Verifying consistency between hard-coded string and localized string
          // GPSProcess: lds.snackbarMessageSessionSavedSuccessfully
          expect(snackbarMessage, lds.snackbarMessageSessionSavedSuccessfully);  
          
          // Verifying the snackbarMessage present
          expect(find.text(lds.snackbarMessageSessionSavedSuccessfully), findsOne);

          // ── 3. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────────
          // Searching for the title and keywords          
            // To avoid intermittent test failures
          await tester.pump(const Duration(seconds: 2)); 
          // todo: a dashboardSearchMetadata
          await dashboardSearchTitleAndKeywords(title: "${testGPSTitle1}${lgps.gpsTitleSuffix}", kws: kwsList2Keywords);

          // Searching for the date
          dateForTestingIndex = 0;
          expect(find.textContaining(datesForTestingList[0]), findsOne);
        }
      }); 
    });


    group("Sorting and filtering Tests: Mobile: \n", ()
    {
      testWidgets("Sorting by title \n"
        "(assuming an already selected path to the user session data folder)",
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
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
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedGPSStrings lgps = .new(context);

            // ── 1. ENTERING NEW GPS PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterSeveralTimesNewProcessData
            (
              tester: tester,
              titlesList: titlesList,
              kwsLists: [[], [], []],
              ideasList: [ideasList2Ideas, ideasList2Ideas, ideasList2Ideas],
              fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
            );
            // await tester.pump(const Duration(seconds: 2));
          
            // ── 2. SORTING BY TITLE ──────────────────────────────────
            // ────────────────────────────────────────────────────────
            // Triggering the sort
            var sortByTitleFinder = find.textContaining(lds.sortByTitle);
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
              expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesListSorted[index]}${lgps.gpsTitleSuffix}");
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
              expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesListSorted.reversed.toList()[index]}${lgps.gpsTitleSuffix}");
            }
          }          
        }
      );
      
      testWidgets("Sorting by date \n"
        "(assuming an already selected path to the user session data folder)",
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
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
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);

            // ── 1. ENTERING NEW GPS PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterSeveralTimesNewProcessData
            (
              tester: tester,
              titlesList: titlesList,
              kwsLists: [[], [], []],
              ideasList: [ideasList2Ideas, ideasList2Ideas, ideasList2Ideas],
              fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
            );
            // await tester.pump(const Duration(seconds: 2));
          
            // ── 2. SORTING BY DATE ──────────────────────────────────
            // ────────────────────────────────────────────────────────
            // Triggering the sort
            var sortByDateFinder = find.textContaining(lds.sortByDate);
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
    
      testWidgets("Filtering by keywords \n"
          "(assuming an already selected path to the user session data folder)",
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
              // Temporary test dir as application folder path
              "applicationFolderPath": testTmpDir!.path
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
              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedGPSStrings lgps = .new(context);

              // ── 1. ENTERING NEW GPS PROCESS DATA (6 times) ──────────────────────────────────
              // ───────────────────────────────────────────────────────────────────────────────
              
              await gpsEnterSeveralTimesNewProcessData
              (
                tester: tester,
                titlesList: titlesListKwsSorting,
                kwsLists: kwsListsKwsSorting,
                ideasList: [ideasList2Ideas, ideasList2Ideas, ideasList2Ideas, ideasList2Ideas, ideasList2Ideas, ideasList2Ideas],
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
                expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesMaintenance.reversed.toList()[index]}${lgps.gpsTitleSuffix}");
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
                expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesCompanionship.reversed.toList()[index]}${lgps.gpsTitleSuffix}");
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
                expect((tester.widget<Text>(titlesFinder.at(index)).data), "${titlesWorkplace.reversed.toList()[index]}${lgps.gpsTitleSuffix}");
              }              

              // await tester.pump(const Duration(seconds: 2));
            }
          });     
    
    });
  
    group("Deletion Tests: Mobile: \n", ()
    {
      testWidgets("Deletion: Single deletion with icon \n"
        "(assuming an already selected path to the user session data folder)",
        (WidgetTester tester) async {

          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
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
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedGPSStrings lgps = .new(context);

            // ── 1. ENTERING NEW GPS PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: testGPSTitle1,
              kwsList: kwsList2Keywords,
              ideasList: ideasList2Ideas,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────
            // Searching for the finder with the title
            Finder sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester,title: testGPSTitle1, titleSuffix: lgps.gpsTitleSuffix);
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
            var deleteIconFinder = find.byTooltip(lds.deleteTooltipLabel);

            // Tapping the icon
            await tester.tap(deleteIconFinder);
            await tester.pumpAndSettle();

            // Verifying the sessions list item absent
            sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: testGPSTitle1, titleSuffix: lgps.gpsTitleSuffix);
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

      testWidgets("Deletion: Bulk deletion \n"
        "(assuming an already selected path to the user session data folder)",
        (WidgetTester tester) async {

          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
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
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedGPSStrings lgps = .new(context);

            // ── 1. ENTERING NEW GPS PROCESS DATA (3 times) ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────
            
            await gpsEnterSeveralTimesNewProcessData
            (
              tester: tester,
              // const List<String> titlesList = [testGPSTitle3, testGPSTitle1, testGPSTitle2];
              titlesList: titlesList,
              kwsLists: [["kw3"], ["kw1"], ["kw2"]],
              ideasList: [ideasList2Ideas, ideasList2Ideas, ideasList2Ideas],
              fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
            );

            // ── 2. SEARCHING FOR THE TILES with title 1 and title 2 TO CHECK ON THE DASHBOARD  ─
            // Searching and tapping the checkboxes for title 1 and title 2
            var checkbox1Finder = find.descendant
            (
              of: find.ancestor(of: find.text("$testGPSTitle1${lgps.gpsTitleSuffix}"), matching: find.byType(SessionsListItem)), 
              matching: find.byType(Checkbox)
            );
            // Needed more than ensureVisible
            await scrollListUpScrollableByFirstDescendant(tester: tester, listFinder: find.byType(CustomScrollView), elementToReachFinder: checkbox1Finder);
            await tester.tap(checkbox1Finder);
            await tester.pumpAndSettle();
            // await tester.pump(const Duration(seconds: 2));

           var checkbox2Finder = find.descendant
            (
                of: find.ancestor(of: find.text("$testGPSTitle2${lgps.gpsTitleSuffix}"), matching: find.byType(SessionsListItem)), 
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
            var title3WithSuffix = "$testGPSTitle3${lgps.gpsTitleSuffix}";
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
  
    group("Preview Tests: Mobile: \n", () 
    {
      testWidgets("Session data entered is found on the preview \n"
        "(assuming an already selected path to the user session data folder)",
        (WidgetTester tester) async {

          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // To have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
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
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            // await tester.pump(const Duration(seconds: 3));

            // ── 1. ENTERING NEW GPS PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────

            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: testGPSTitle1,
              kwsList: kwsList2Keywords,
              ideasList: ideasList2Ideas,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 5));
            
            // ── 2. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────────
            await tester.pump(const Duration(seconds: 2));
            await gpsTestPreview(context: context, tester: tester, title: testGPSTitle1, ideasList: ideasList2Ideas);

            // await tester.pump(const Duration(seconds: 2));

          }
        }
      );
    });

    group("Edition Tests: Preview: Mobile: \n", ()
    {
      testWidgets("Group problem-solving data edition (from preview)\n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedGPSStrings lgps = .new(context);
            // await tester.pump(const Duration(seconds: 2));

            // ── 1. ENTERING NEW GPS PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────
            var titleForEdition = "GPS title";
            var keywordsListForEdition3Kws = [...kwsList2Keywords, kwMaintenance]; 
            var ideasListForEdition = ideasList2Ideas;
            var idea3Added = "idea3-edited";
            
            // important for gpsTestPreview
            // expect(find.textContaining(datesForTestingList[0]), findsNWidgets(2));
            dateForTestingIndex = 0;
            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: titleForEdition,
              kwsList: keywordsListForEdition3Kws,
              ideasList: ideasListForEdition,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 2));

            // ── 2. CLICKING TO OPEN THE PREVIEW  ─────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────
            // Opening the preview
            var previewFinder = find.byTooltip(lds.previewTooltipLabel);
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
            expect(find.text(titleForEdition), findsOne);

            // ── Verifying the keywords present ──────────
            // ────────────────────────────────────────────
              // Opening the keywords overlay
            var keywordsWidgetTitleFinder = find.text(lgps.gpsKeywordsTitle);
            await tester.tap(keywordsWidgetTitleFinder);
            await tester.pumpAndSettle();
              // Verifying the keywords present
              for (var kw in keywordsListForEdition3Kws)
              {
                expect(find.text(kw), findsOne);
              }
              // Closing the keywords overlay
              var closeKeywordsDeclarationTooltipLabelFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
              await tester.tap(closeKeywordsDeclarationTooltipLabelFinder);
              await tester.pumpAndSettle();

            // ── Verifying the ideas present ─────────────
            // ────────────────────────────────────────────
            for (var idea in ideasList2Ideas)
            {
              expect(find.textContaining(idea), findsNWidgets(1));
            }            

            // important for gpsTestPreview
            // expect(find.textContaining(datesForTestingList[0]), findsNWidgets(2));
            dateForTestingIndex = 0;
            // ── Editing data ────────────────────────────
            // ────────────────────────────────────────────
              // TITLE EDITION
            var titleFinder = find.text(titleForEdition);
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();
              // searching the text field
            titleFinder = find.byKey(const Key("problemToSolveField"));
            await tester.enterText(titleFinder, "${titleForEdition}${editionSuffix}");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

              // IDEAS EDITION
             // Searching idea1
            var idea1Finder = find.text(ideasList2Ideas[0]);
            await tester.ensureVisible(idea1Finder);
            await tester.pumpAndSettle();   
              // Tapping on the idea to open the edition overlay
            await tester.tap(idea1Finder);
            await tester.pumpAndSettle();

            var editableDeletableTextListItemFinder = find.byType(EditableDeletableTextListItem);
            var totalEditableDeletableTextListItemFinder = editableDeletableTextListItemFinder.evaluate().length;
            if (testingDebug) pu.printd("Testing Debug: totalEditableDeletableTextListItemFinder: $totalEditableDeletableTextListItemFinder");

              // Searching the editable/deletable field for idea1
            var idea1EditableDeletableFinder = find.byKey(const Key("editable-deletable-list-tile-0"));   // todo: to clean           
            await tester.tap(idea1EditableDeletableFinder);
            await tester.pumpAndSettle();

            // ── Editing idea1: modification  ─────────────────────
            // ────────────────────────────────────────────────────
            var tfIdea1Finder = find.byKey(const Key("editable-deletable-tf-0"));
            await tester.enterText(tfIdea1Finder, "${ideasList2Ideas[0]}$editionSuffix");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));  
            if (testingDebug) pu.printd("Testing Debug: idea1 edited");

            // ── Editing idea2 : deletion ─────────────────────────
            // ─────────────────────────────────────────────────────
              // Searching idea2
              // Searching the editable/deletable checkbox for idea2
            var idea2EditableDeletableFinder = find.byKey(const Key("editable-deletable-checkbox-1"));   // todo: to clean           
            await tester.ensureVisible(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
            await tester.tap(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
              // Deleting 
            var deleteFinder = find.textContaining("Delete");
            await tester.tap(deleteFinder);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 10));
            
            if (testingDebug) pu.printd("Testing Debug: idea2 deleted");
              // Waiting on Snackbar removal
            await tester.pump(const Duration(seconds: 5));

            // ── Adding idea3: addition  ─────────────────────────
            // ────────────────────────────────────────────────────
            var ideaOverlayTextFieldFinder = find.byKey(const Key("ideaOverlayField"));
            await tester.enterText(ideaOverlayTextFieldFinder, idea3Added);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));             
            if (testingDebug) pu.printd("Testing Debug: idea3 added");  

            // ── Closing the ideas list  ───────────────────────
            // ───────────────────────────────────────────────────
            var closeFinder = find.byIcon(Icons.close);  
            await tester.tap(closeFinder);
            await tester.pumpAndSettle();

            // KEYWORDS EDITION
              // Opening the keywords overlay
            keywordsWidgetTitleFinder = find.text(lgps.gpsKeywordsTitle);
            await tester.tap(keywordsWidgetTitleFinder);
            await tester.pumpAndSettle();

              // Removing kwMaintenance
            var deletekwMaintenanceFinder = 
              find.descendant
              (
                of: find.ancestor
                (
                  of: find.text(kwMaintenance), 
                  matching: find.byType(InputChip)
                ), 
                matching: find.byIcon(Icons.close)                
              );
            
              await tester.tap(deletekwMaintenanceFinder);
              await tester.pumpAndSettle();

              // Adding kwCommunication
              var kwTecFinder = find.byKey(const Key("gpsKeywordsField"));
              await tester.enterText(kwTecFinder, kwCommunication);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();

              // closing the overlay
              var closeOverlayFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
              await tester.tap(closeOverlayFinder);
              await tester.pumpAndSettle();

            // ── Submitting new data  ───────────────────────
            // ───────────────────────────────────────────────
              // Searching the file name text field and submitting data
            var sessionFileNameOnMobilePlatformsFinder = find.byType(SessionFileNameOnMobilePlatforms);
            await tester.tap(sessionFileNameOnMobilePlatformsFinder);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 10));

            // ── 5. VERIFICATION  ─────────────────
            // ─────────────────────────────────────   
              // Verifying the edited title present
            expect(find.text("${titleForEdition}${editionSuffix}${lgps.gpsTitleSuffix}"),findsOne);

              // Verifying the edited keywords present
            for (var kw in [...kwsList2Keywords, kwCommunication])
            {
              expect(find.text(kw), findsOne);
            }

              // Verifying the edited/added data present
            await gpsTestPreview
            (
              context: context,
              tester: tester, title: "${titleForEdition}${editionSuffix}", 
              ideasList: ["${ideasList2Ideas[0]}${editionSuffix}", idea3Added]
            );
       
          } // if platform

        });
    
      testWidgets("Group problem-solving data edition (from dashboard)\n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedGPSStrings lgps = .new(context);
            // await tester.pump(const Duration(seconds: 2));

            // ──  ENTERING NEW GPS PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────
            var titleForEdition = "GPS title";
            var keywordsListForEdition3Kws = [...kwsList2Keywords, kwMaintenance]; 
            var ideasListForEdition = ideasList2Ideas;
            var idea3Added = "idea3-edited";
            
            // important for gpsTestPreview
            // expect(find.textContaining(datesForTestingList[0]), findsNWidgets(2));
            dateForTestingIndex = 0;
            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: titleForEdition,
              kwsList: keywordsListForEdition3Kws,
              ideasList: ideasListForEdition,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 2));

            // ── CLICKING ON THE EDIT ICON  ─────────────────────────────────
            // ──────────────────────────────────────────────────────────────────
            var editIconFromItemFinder = find.byTooltip(lds.editFromDashboardItemTooltipLabel);
            await tester.tap(editIconFromItemFinder);
            await tester.pumpAndSettle();

            // ── EDITION: Verifying data present and editing  ─────────────────
            // ────────────────────────────────────────────────────────────────────

            // ── Verifying the title present ─────────────
            // ────────────────────────────────────────────
            expect(find.text(titleForEdition), findsOne);

            // ── Verifying the keywords present ──────────
            // ────────────────────────────────────────────
              // Opening the keywords overlay
            var keywordsWidgetTitleFinder = find.text(lgps.gpsKeywordsTitle);
            await tester.tap(keywordsWidgetTitleFinder);
            await tester.pumpAndSettle();
              // Verifying the keywords present
              for (var kw in keywordsListForEdition3Kws)
              {
                expect(find.text(kw), findsOne);
              }
              // Closing the keywords overlay
              var closeKeywordsDeclarationTooltipLabelFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
              await tester.tap(closeKeywordsDeclarationTooltipLabelFinder);
              await tester.pumpAndSettle();

            // ── Verifying the ideas present ─────────────
            // ────────────────────────────────────────────
            for (var idea in ideasList2Ideas)
            {
              expect(find.textContaining(idea), findsNWidgets(1));
            }            

            // important for gpsTestPreview
            // expect(find.textContaining(datesForTestingList[0]), findsNWidgets(2));
            dateForTestingIndex = 0;
            // ── Editing data ────────────────────────────
            // ────────────────────────────────────────────
              // TITLE EDITION
            var titleFinder = find.text(titleForEdition);
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();
              // searching the text field
            titleFinder = find.byKey(const Key("problemToSolveField"));
            await tester.enterText(titleFinder, "${titleForEdition}${editionSuffix}");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

              // IDEAS EDITION
             // Searching idea1
            var idea1Finder = find.text(ideasList2Ideas[0]);
            await tester.ensureVisible(idea1Finder);
            await tester.pumpAndSettle();   
              // Tapping on the idea to open the edition overlay
            await tester.tap(idea1Finder);
            await tester.pumpAndSettle();

            var editableDeletableTextListItemFinder = find.byType(EditableDeletableTextListItem);
            var totalEditableDeletableTextListItemFinder = editableDeletableTextListItemFinder.evaluate().length;
            if (testingDebug) pu.printd("Testing Debug: totalEditableDeletableTextListItemFinder: $totalEditableDeletableTextListItemFinder");

              // Searching the editable/deletable field for idea1
            var idea1EditableDeletableFinder = find.byKey(const Key("editable-deletable-list-tile-0"));   // todo: to clean           
            await tester.tap(idea1EditableDeletableFinder);
            await tester.pumpAndSettle();

            // ── Editing idea1: modification  ─────────────────────
            // ────────────────────────────────────────────────────
            var tfIdea1Finder = find.byKey(const Key("editable-deletable-tf-0"));
            await tester.enterText(tfIdea1Finder, "${ideasList2Ideas[0]}$editionSuffix");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));  
            if (testingDebug) pu.printd("Testing Debug: idea1 edited");

            // ── Editing idea2 : deletion ─────────────────────────
            // ─────────────────────────────────────────────────────
              // Searching idea2
              // Searching the editable/deletable checkbox for idea2
            var idea2EditableDeletableFinder = find.byKey(const Key("editable-deletable-checkbox-1"));   // todo: to clean           
            await tester.ensureVisible(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
            await tester.tap(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
              // Deleting 
            var deleteFinder = find.textContaining("Delete");
            await tester.tap(deleteFinder);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 10));
            
            if (testingDebug) pu.printd("Testing Debug: idea2 deleted");
              // Waiting on Snackbar removal
            await tester.pump(const Duration(seconds: 5));

            // ── Adding idea3: addition  ─────────────────────────
            // ────────────────────────────────────────────────────
            var ideaOverlayTextFieldFinder = find.byKey(const Key("ideaOverlayField"));
            await tester.enterText(ideaOverlayTextFieldFinder, idea3Added);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));             
            if (testingDebug) pu.printd("Testing Debug: idea3 added");  

            // ── Closing the ideas list  ───────────────────────
            // ───────────────────────────────────────────────────
            var closeFinder = find.byIcon(Icons.close);  
            await tester.tap(closeFinder);
            await tester.pumpAndSettle();

            // KEYWORDS EDITION
              // Opening the keywords overlay
            keywordsWidgetTitleFinder = find.text(lgps.gpsKeywordsTitle);
            await tester.tap(keywordsWidgetTitleFinder);
            await tester.pumpAndSettle();

              // Removing kwMaintenance
            var deletekwMaintenanceFinder = 
              find.descendant
              (
                of: find.ancestor
                (
                  of: find.text(kwMaintenance), 
                  matching: find.byType(InputChip)
                ), 
                matching: find.byIcon(Icons.close)                
              );
            
              await tester.tap(deletekwMaintenanceFinder);
              await tester.pumpAndSettle();

              // Adding kwCommunication
              var kwTecFinder = find.byKey(const Key("gpsKeywordsField"));
              await tester.enterText(kwTecFinder, kwCommunication);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();

              // closing the overlay
              var closeOverlayFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
              await tester.tap(closeOverlayFinder);
              await tester.pumpAndSettle();

            // ── Submitting edited data  ───────────────────────
            // ───────────────────────────────────────────────
              // Searching the file name text field and submitting data
            var sessionFileNameOnMobilePlatformsFinder = find.byType(SessionFileNameOnMobilePlatforms);
            await tester.tap(sessionFileNameOnMobilePlatformsFinder);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 10));

            // ──  VERIFICATION  ─────────────────
            // ─────────────────────────────────────   
              // Verifying the edited title present
            expect(find.text("${titleForEdition}${editionSuffix}${lgps.gpsTitleSuffix}"),findsOne);

              // Verifying the edited keywords present
            for (var kw in [...kwsList2Keywords, kwCommunication])
            {
              expect(find.text(kw), findsOne);
            }

              // Verifying the edited/added data present
            await gpsTestPreview
            (
              context: context,
              tester: tester, title: "${titleForEdition}${editionSuffix}", 
              ideasList: ["${ideasList2Ideas[0]}${editionSuffix}", idea3Added]
            );
       
          } // if platform

        });

      testWidgets("Edition data is not retained in next process \n",
        (WidgetTester tester) async {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
            // Temporary test dir as application folder path
            "applicationFolderPath": testTmpDir!.path
          });

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();
            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);
            LocalizedGPSStrings lgps = .new(context);
            // await tester.pump(const Duration(seconds: 2));

            // ──  ENTERING NEW GPS PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────
            var titleForEdition = "GPS title";
            var keywordsListForEdition3Kws = [...kwsList2Keywords, kwMaintenance]; 
            var ideasListForEdition = ideasList2Ideas;
            var idea3Added = "idea3-edited";
            
            // important for gpsTestPreview
            // expect(find.textContaining(datesForTestingList[0]), findsNWidgets(2));
            dateForTestingIndex = 0;
            await gpsEnterNewProcessDataOnMobile
            (
              tester: tester, 
              title: titleForEdition,
              kwsList: keywordsListForEdition3Kws,
              ideasList: ideasListForEdition,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 2));

            // ── CLICKING ON THE EDIT ICON  ─────────────────────────────────
            // ──────────────────────────────────────────────────────────────────
            var editIconFromItemFinder = find.byTooltip(lds.editFromDashboardItemTooltipLabel);
            await tester.tap(editIconFromItemFinder);
            await tester.pumpAndSettle();

            // ── EDITION: Verifying data present and editing  ─────────────────
            // ────────────────────────────────────────────────────────────────────

            // ── Verifying the title present ─────────────
            // ────────────────────────────────────────────
            expect(find.text(titleForEdition), findsOne);

            // ── Verifying the keywords present ──────────
            // ────────────────────────────────────────────
              // Opening the keywords overlay
            var keywordsWidgetTitleFinder = find.text(lgps.gpsKeywordsTitle);
            await tester.tap(keywordsWidgetTitleFinder);
            await tester.pumpAndSettle();
              // Verifying the keywords present
              for (var kw in keywordsListForEdition3Kws)
              {
                expect(find.text(kw), findsOne);
              }
              // Closing the keywords overlay
              var closeKeywordsDeclarationTooltipLabelFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
              await tester.tap(closeKeywordsDeclarationTooltipLabelFinder);
              await tester.pumpAndSettle();

            // ── Verifying the ideas present ─────────────
            // ────────────────────────────────────────────
            for (var idea in ideasList2Ideas)
            {
              expect(find.textContaining(idea), findsNWidgets(1));
            }            

            // important for gpsTestPreview
            // expect(find.textContaining(datesForTestingList[0]), findsNWidgets(2));
            dateForTestingIndex = 0;
            // ── Editing data ────────────────────────────
            // ────────────────────────────────────────────
              // TITLE EDITION
            var titleFinder = find.text(titleForEdition);
            await tester.tap(titleFinder);
            await tester.pumpAndSettle();
              // searching the text field
            titleFinder = find.byKey(const Key("problemToSolveField"));
            var titleEdited = "${titleForEdition}${editionSuffix}";
            await tester.enterText(titleFinder, titleEdited);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pump(const Duration(seconds: 10));
            await tester.pumpAndSettle();

              // IDEAS EDITION
             // Searching idea1
            var idea1Finder = find.text(ideasList2Ideas[0]);
            await tester.ensureVisible(idea1Finder);
            await tester.pumpAndSettle();   
              // Tapping on the idea to open the edition overlay
            await tester.tap(idea1Finder);
            await tester.pumpAndSettle();

            var editableDeletableTextListItemFinder = find.byType(EditableDeletableTextListItem);
            var totalEditableDeletableTextListItemFinder = editableDeletableTextListItemFinder.evaluate().length;
            if (testingDebug) pu.printd("Testing Debug: totalEditableDeletableTextListItemFinder: $totalEditableDeletableTextListItemFinder");

              // Searching the editable/deletable field for idea1
            var idea1EditableDeletableFinder = find.byKey(const Key("editable-deletable-list-tile-0"));   // todo: to clean           
            await tester.tap(idea1EditableDeletableFinder);
            await tester.pumpAndSettle();

            // ── Editing idea1: modification  ─────────────────────
            // ────────────────────────────────────────────────────
            var tfIdea1Finder = find.byKey(const Key("editable-deletable-tf-0"));
            await tester.enterText(tfIdea1Finder, "${ideasList2Ideas[0]}$editionSuffix");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));  
            if (testingDebug) pu.printd("Testing Debug: idea1 edited");

            // ── Editing idea2 : deletion ─────────────────────────
            // ─────────────────────────────────────────────────────
              // Searching idea2
              // Searching the editable/deletable checkbox for idea2
            var idea2EditableDeletableFinder = find.byKey(const Key("editable-deletable-checkbox-1"));   // todo: to clean           
            await tester.ensureVisible(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
            await tester.tap(idea2EditableDeletableFinder);
            await tester.pumpAndSettle();
              // Deleting 
            var deleteFinder = find.textContaining("Delete");
            await tester.tap(deleteFinder);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 10));
            
            if (testingDebug) pu.printd("Testing Debug: idea2 deleted");
              // Waiting on Snackbar removal
            await tester.pump(const Duration(seconds: 5));

            // ── Adding idea3: addition  ─────────────────────────
            // ────────────────────────────────────────────────────
            var ideaOverlayTextFieldFinder = find.byKey(const Key("ideaOverlayField"));
            await tester.enterText(ideaOverlayTextFieldFinder, idea3Added);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));             
            if (testingDebug) pu.printd("Testing Debug: idea3 added");  

            // ── Closing the ideas list  ───────────────────────
            // ───────────────────────────────────────────────────
            var closeFinder = find.byIcon(Icons.close);  
            await tester.tap(closeFinder);
            await tester.pumpAndSettle();

            // KEYWORDS EDITION
              // Opening the keywords overlay
            keywordsWidgetTitleFinder = find.text(lgps.gpsKeywordsTitle);
            await tester.tap(keywordsWidgetTitleFinder);
            await tester.pumpAndSettle();

              // Removing kwMaintenance
            var deletekwMaintenanceFinder = 
              find.descendant
              (
                of: find.ancestor
                (
                  of: find.text(kwMaintenance), 
                  matching: find.byType(InputChip)
                ), 
                matching: find.byIcon(Icons.close)                
              );
            
              await tester.tap(deletekwMaintenanceFinder);
              await tester.pumpAndSettle();

              // Adding kwCommunication
              var kwTecFinder = find.byKey(const Key("gpsKeywordsField"));
              await tester.enterText(kwTecFinder, kwCommunication);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();

              // closing the overlay
              var closeOverlayFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
              await tester.tap(closeOverlayFinder);
              await tester.pumpAndSettle();

            // ── Submitting edited data  ───────────────────
            // ───────────────────────────────────────────────
              // Searching the file name text field and submitting data
            var sessionFileNameOnMobilePlatformsFinder = find.byType(SessionFileNameOnMobilePlatforms);
            await tester.tap(sessionFileNameOnMobilePlatformsFinder);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 10));

            // ──  VERIFICATION  ─────────────────
            // ─────────────────────────────────────   
              // Verifying the edited title present
            expect(find.text("${titleForEdition}${editionSuffix}${lgps.gpsTitleSuffix}"),findsOne);

              // Verifying the edited keywords present
            for (var kw in [...kwsList2Keywords, kwCommunication])
            {
              expect(find.text(kw), findsOne);
            }

              // Verifying the edited/added data present
            await gpsTestPreview
            (
              context: context,
              tester: tester, title: "${titleForEdition}${editionSuffix}", 
              ideasList: ["${ideasList2Ideas[0]}${editionSuffix}", idea3Added]
            );
              // ── Closing the GPS preview ──────────────────
            var previewClosingTooltipLabelFinder = find.byTooltip(lds.previewClosingTooltipLabel);
            await tester.tap(previewClosingTooltipLabelFinder);
            await tester.pumpAndSettle();

            // ──  VERIFYING THE EDITED DATA ABSENT FROM A NEW PROCESS  ──────────────
            // ───────────────────────────────────────────────────────────────────────

            // ── STARTING A NEW GPS PROCESS ──────────────────
            // ───────────────────────────────────────────────
            var newProcessButtonFinder = find.byType(NewProcessButton);
            await tester.tap(newProcessButtonFinder);
            await tester.pumpAndSettle();

            // ── VERIFYING ALL FIELDS EMPTY ─────────────────
            // ───────────────────────────────────────────────
            
              // ── VERIFYING TITLE TEXT EMPTY ──────────────
              // ──────────────────────────────────────────────────
            var titleTextFinder = find.byKey(const Key("gps-process-gpsproblemtosolvedeclaration-title-text"), skipOffstage: false);
            var titleText = tester.widget<Text>(titleTextFinder);
            expect(titleText.data, lgps.gpsDefaultProcessSessionTitle);

              // ── VERIFYING KEYWORDS TEXT FIELD EMPTY AND KEYWORDS INPUT CHIPS ABSENT ─────────────
              // ──────────────────────────────────────────────────────────────────────────────────────
              // ── OPENING THE KEYWORDS OVERLAY ─────────────
            var keywordsTitleFinder = find.byType(GPSKeywordsDeclaration, skipOffstage: false);
            await tester.tap(keywordsTitleFinder);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 5));

              // ── VERIFYING KEYWORDS TEXT FIELD EMPTY ─────────────
            var keywordsTextFieldFinder = find.byKey(const Key("gpsKeywordsField"));
            var keywordsTextField = tester.widget<TextField>(keywordsTextFieldFinder);
            expect(keywordsTextField.controller!.text,"");

              // ── VERIFYING KEYWORDS INPUT CHIPS ABSENT ──────
            var inputChipsFinder = find.byType(InputChip);
            expect(inputChipsFinder, findsNothing);

              // ── CLOSING THE OVERLAY ──────
            var closeDeclarationTooltipFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
            await tester.tap(closeDeclarationTooltipFinder);
            await tester.pumpAndSettle();

              // ── VERIFYING IDEAS LIST EMPTY ────────────
              // ──────────────────────────────────────────
            var listTilesFinder = find.byType(ListTile);
            expect(listTilesFinder, findsNothing);

              // ── VERIFYING NEW IDEA LIST EMPTY ────────────
              // ──────────────────────────────────────────
            var gpsNewListFieldFinder = find.byKey(const Key("gpsNewIdeaField"), skipOffstage: false);
            var gpsNewListFieldWidget = tester.widget<TextField>(gpsNewListFieldFinder);
            expect(gpsNewListFieldWidget.controller!.text, "");
            
            // await tester.pump(const Duration(seconds: 5));

              // ── VERIFYING FILE NAME TEXT FIELD EMPTY ────────
              // ────────────────────────────────────────────────
            sessionFileNameOnMobilePlatformsFinder = find.byKey(const Key("gps-process-sessionfilenameonmobileplatforms-widget"), skipOffstage: false);
            var sessionFileNameOnMobilePlatformsTextFieldFinder = find.descendant(of: sessionFileNameOnMobilePlatformsFinder, matching: find.byType(TextField), skipOffstage: false);
            await tester.ensureVisible(sessionFileNameOnMobilePlatformsTextFieldFinder);         
            await tester.pumpAndSettle();
            var sessionFileNameOnMobilePlatformsTextFieldWidget = tester.widget<TextField>(sessionFileNameOnMobilePlatformsTextFieldFinder);
            expect(sessionFileNameOnMobilePlatformsTextFieldWidget.controller!.text,"");       
          } // if platform

        });

    });

  group("Participants-related Tests: \n", () 
  {
    var name1 = "Bob";
    var name2 = "Alice";
    var name3 = "Ben";
    var name4 = "Jane";
    List<String> names1 = [name1, name2, name3];
    List<String> names2 = [name2, name4];
    List<String> names3 = [name1, name3];
    var listLabel1 = "List1";
    var listLabel2 = "List2";
    var listLabel3 = "List3";
    var listLabelsSorted = [listLabel1, listLabel2, listLabel3];
    var keywordsListKwCompanionship = [kwCompanionship];
    var keywordsListKwWorkplace = [kwWorkplace];
    var titlesCompanionship = [listLabel1];
    var titlesWorkplace = [listLabel2, listLabel3];

    group("New participants list Tests: \n", () 
    {
      group("New participants list saving: \n", () 
      {

        group("New participants list labels/content: \n", () 
        {
          testWidgets("Lists labels must be unique", 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
              // Temporary test dir as application folder path
              "applicationFolderPath": testTmpDir!.path
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedGPSStrings lgps = .new(context);
            LocalizedParticipantsStrings lps = .new(context);

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
            var newParticipantTextFieldFinder = find.byKey(const Key("participantNameField"));
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

            // Searching the "Save" icon
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsOne);

            // Tapping on it
            await tester.tap(saveListIconFinder);
            await tester.pumpAndSettle();

            // Searching the text field to add the same list name
            var listNameSavingTextFieldFinder = find.byKey(const Key("saveListField"));
            expect(listNameSavingTextFieldFinder, findsOne);

            // Adding the same list name
            await tester.ensureVisible(listNameSavingTextFieldFinder);
            await tester.tap(listNameSavingTextFieldFinder);
            await tester.enterText(listNameSavingTextFieldFinder, listLabel1);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            await tester.pump(const Duration(seconds: 5));

            // Searching for the error message
            var listAlreadySavedErrorFinder = find.textContaining(lps.listAlreadySavedErrorEndPart);
            expect(listAlreadySavedErrorFinder, findsOne);

            // Verifying transition to GPS process page absent
            expect(find.text(lgps.checkListTitle), findsNothing);
          });            
        
          testWidgets("Lists labels must be non empty", 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedGPSStrings lgps = .new(context);
            LocalizedParticipantsStrings lps = .new(context);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and ATTEMPTING TO SAVE THE LIST  ──────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);
            
            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const Key("participantNameField"));
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

            
            // Searching the "Save" icon
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsOne);

            // Tapping on it
            await tester.tap(saveListIconFinder);
            await tester.pumpAndSettle();

            // Searching the text field to add an empty list name
            var listNameSavingTextFieldFinder = find.byKey(const Key("saveListField"));
            expect(listNameSavingTextFieldFinder, findsOne);

            // Adding an empty list name
            await tester.ensureVisible(listNameSavingTextFieldFinder);
            await tester.tap(listNameSavingTextFieldFinder);
            await tester.enterText(listNameSavingTextFieldFinder, "");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // await tester.pump(const Duration(seconds: 5));
            // Searching for the error message
            var labelEmptyErrorFinder = find.textContaining(lps.emptyLabelEditError);
            expect(labelEmptyErrorFinder, findsOne);

            // Verifying transition to GPS process page absent
            expect(find.text(lgps.checkListTitle), findsNothing);    
          });            
        
          testWidgets("List content must be unique (without reversed order when adding 2nd list)", 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
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
            var newParticipantTextFieldFinder = find.byKey(const Key("participantNameField"));
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

            // Verifying the "Save" icon absent
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsNothing);        
          });            
        
          testWidgets("List content must be unique (with reversed order when adding 2nd list)", 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
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
            var newParticipantTextFieldFinder = find.byKey(const Key("participantNameField"));
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

            // Verifying the "Save" icon absent
            var saveListIconFinder = find.byIcon(Icons.save_outlined);
            expect(saveListIconFinder, findsNothing);        
          });            
        
          testWidgets("Names are displayed in the order added (names in alphabetical order)", 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            var names = ["a", "b", "c"];
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // ── VERIFYING THE ORDER  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────
            var listItemsFinder = await gpsGetNewListTextItems(tester);

            var totalItems = listItemsFinder.evaluate().length;
            if (testingDebug) pu.printd("Testing Debug: totalItems: $totalItems");

            for (var itemIndex = 0; itemIndex < totalItems; itemIndex++)
            {
              expect(tester.widget<Text>(listItemsFinder.at(itemIndex)), names[itemIndex]);
            }
                
          });            
        
          testWidgets("Names are displayed in the order added (names not in alphabetical order)", 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            var names = ["c", "b", "a"];
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // ── VERIFYING THE ORDER  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────
            var listItemsFinder = await gpsGetNewListTextItems(tester);

            var totalItems = listItemsFinder.evaluate().length;
            if (testingDebug) pu.printd("Testing Debug: totalItems: $totalItems");

            for (var itemIndex = 0; itemIndex < totalItems; itemIndex++)
            {
              expect(tester.widget<Text>(listItemsFinder.at(itemIndex)), names[itemIndex]);
            }
                
          });            
        
          // Todo: To find a better integration tests/widget tests organization
          // "Keywords can be added/removed"
          testWidgets("Keywords can be added/removed", 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedGPSStrings lgps = .new(context);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── REACHING THE NEW PARTICIPANTS LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            await gpsFromProcessPageToNewParticipantsListPage(tester);

            // ── ADDING KEYWORDS  ──────────────────────────────────
            // ──────────────────────────────────────────────────────
              // Searching the keywordsDeclarationTitle
            var keywordsDeclarationTitleFinder = find.text(lgps.gpsKeywordsTitle);
            await tester.tap(keywordsDeclarationTitleFinder);
            await tester.pumpAndSettle();
              // Adding two keywords
            var keywordsListKw1Kw2 = ["kw1", "kw2"];
                // Searching the text field
            var keywordTecFinder = find.byKey(const Key("kwsFieldNewList"));
            for (var kw in keywordsListKw1Kw2)
            {
              await tester.enterText(keywordTecFinder, kw);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();
              await tester.tap(keywordTecFinder);
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
            var closeOverlayFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);
            await tester.tap(closeOverlayFinder); 
            await tester.pumpAndSettle();   

            // ── ADDING A PARTICIPANT  ──────────────────
            // ───────────────────────────────────────────
            var participantNameFieldFinder = find.byKey(const Key("participantNameField"));
            await tester.enterText(participantNameFieldFinder, "Bob");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // ── SAVING THE LIST  ──────────────────
            // ──────────────────────────────────────
            var saveListFinder = find.byTooltip("Save list");
            await tester.tap(saveListFinder);
            await tester.pumpAndSettle();
              // Entering the list name
            var saveListFieldFinder = find.byKey(const Key("saveListField"));
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
      
        group("New participants list saving: \n", () 
        {
          testWidgets("1. Participants can be added, keywords added, the data saved in a list, "
                      "and the participants' names are loaded in the GPS process page"
                      "(the correct snackbar message is displayed) ", 
            (WidgetTester tester) async 
            {
                // Setting mock values for SharedPreferences
                SharedPreferences.setMockInitialValues
                ({
                  // Setting value for the first-run modal to be absent,
                  "wasFirstRunModalAcknowledged": true,
                  // and to have the group problem-solving page, with the dashboard.
                  "wasGPSSessionDataSaved": true,
                });

                // Pumping the GPSPage
                await tester.pumpWidget(buildTestableGPSPage());
                await tester.pumpAndSettle();

                // Getting the localized strings
                var context = tester.element(find.byType(Scaffold).first);
                LocalizedGPSStrings lgps = .new(context);
                LocalizedParticipantsStrings lps = .new(context);

                // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────
                await gpsFromGPSPageToProcessPage(tester);

                // ── CLICKING TO DISPLAY THE PARTICIPANTS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────────
                // Adding the names
                await gpsFromProcessPageAddParticipantsAndKeywords(tester, names1, keywordsListKwCompanionship);   

                // Verifying the names present
                expect(find.text(name1), findsOne);    
                expect(find.text(name2), findsOne);  

                // Searching the "Save" icon
                var saveListIconFinder = find.byIcon(Icons.save_outlined);
                expect(saveListIconFinder, findsOne);

                // Tapping on it
                await tester.tap(saveListIconFinder);
                await tester.pumpAndSettle();

                // Searching the text field to add the list name
                var listNameSavingTextFieldFinder = find.byKey(const Key("saveListField"));
                expect(listNameSavingTextFieldFinder, findsOne);

                // Adding a list name
                await tester.ensureVisible(listNameSavingTextFieldFinder);
                await tester.tap(listNameSavingTextFieldFinder);
                await tester.enterText(listNameSavingTextFieldFinder, listLabel1);
                await tester.testTextInput.receiveAction(TextInputAction.done);
                await tester.pumpAndSettle();

                // Verifying the correct snackbar message present ───────────────────────────────────────────
                // snackbarMessage hard-coded strings
                var snackbarMessage = "";
                
                var localeLanguageCode = getLocaleLanguageCode(tester);

                switch(localeLanguageCode.toLowerCase())
                {
                  case("en"): { snackbarMessage = "Saved as "; }
                  case("fr"): { snackbarMessage = "Enregistrée en tant que "; }        
                }
                
                if (testingDebug) pu.printd("Testing Debug: snackbarMessage: $snackbarMessage");
                
                // Verifying consistency between hard-coded string and localized string
                // NewParticipantsList: lps.savedAsSnackBarMessage
                expect(snackbarMessage, lps.savedAsSnackBarMessage);  
                
                // Verifying the snackbarMessage present
                expect(find.textContaining(lps.savedAsSnackBarMessage), findsOne);

                // Verifying the GPS process page present
                expect(find.text(lgps.checkListTitle), findsOne);

                // Verifying the names present
                expect(find.text(name1), findsOne);    
                expect(find.text(name2), findsOne);  
              });
        
          testWidgets("2. Participants can be added, keywords added, the data saved in a list, "
                      "and the participants' names are loaded in the GPS process page", 
            (WidgetTester tester) async 
            {
                // Setting mock values for SharedPreferences
                SharedPreferences.setMockInitialValues
                ({
                  // Setting value for the first-run modal to be absent,
                  "wasFirstRunModalAcknowledged": true,
                  // and to have the group problem-solving page, with the dashboard.
                  "wasGPSSessionDataSaved": true,
                });

                // Pumping the GPSPage
                await tester.pumpWidget(buildTestableGPSPage());
                await tester.pumpAndSettle();

                // Getting the localized strings
                var context = tester.element(find.byType(Scaffold).first);
                LocalizedGPSStrings lgps = .new(context);

                // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────
                await gpsFromGPSPageToProcessPage(tester);

                // ── CLICKING TO DISPLAY THE PARTICIPANTS PAGE  ──────────────────────────────────────
                // ────────────────────────────────────────────────────────────────────────────
                // Adding the names
                var names = ["Bob", "Alice", "Benny", "Lily"];
                await gpsFromProcessPageAddParticipantsAndKeywords(tester, names, [kwCompanionship]);   

                // Verifying the names present
                for (var name in names)
                {
                  expect(find.text(name), findsOne);  
                }                  

                // Searching the "Save" icon
                var saveListIconFinder = find.byIcon(Icons.save_outlined);
                expect(saveListIconFinder, findsOne);

                // Tapping on it
                await tester.tap(saveListIconFinder);
                await tester.pumpAndSettle();

                // Searching the text field to add the list name
                var listNameSavingTextFieldFinder = find.byKey(const Key("saveListField"));
                expect(listNameSavingTextFieldFinder, findsOne);

                // Adding a list name
                await tester.ensureVisible(listNameSavingTextFieldFinder);
                await tester.tap(listNameSavingTextFieldFinder);
                await tester.enterText(listNameSavingTextFieldFinder, "Our household");
                await tester.testTextInput.receiveAction(TextInputAction.done);
                await tester.pumpAndSettle();

                // Verifying the GPS process page present
                expect(find.text(lgps.checkListTitle), findsOne);

                // Verifying the names present
                for (var name in names)
                {
                  expect(find.text(name), findsOne);  
                }   
              });
        
          testWidgets("Multi-list: Participants can be added, keywords added, the data saved in a list, "
                      " and the participants' names are loaded in the GPS process page", 
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
                // Temporary test dir as application folder path
                "applicationFolderPath": testTmpDir!.path
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

      group("New participants list editing: \n", () 
      {
        testWidgets("Participants names can be edited (while building a new list)", 
        (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
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
            var newParticipantTextFieldFinder = find.byKey(const Key("participantNameField"));
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
            var editionTfFinder = find.byKey(const ValueKey("editable-deletable-tf-0"));
            await tester.ensureVisible(editionTfFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(editionTfFinder);
            await tester.pumpAndSettle();

            var editedName = "$name1-edited";
            await tester.enterText(editionTfFinder, editedName);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Verifying the text field absent
            expect(find.byKey(const ValueKey("editable-deletable-tf-0")), findsNothing);
            
            // Verifying the edited name present
            expect(find.text(editedName), findsOne);

          });
        
        testWidgets("Participants names can be deleted (while building a new list)"
                    "(the correct snackbar message is displayed) ", 
        (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // Setting value for the first-run modal to be absent,
              "wasFirstRunModalAcknowledged": true,
              // and to have the group problem-solving page, with the dashboard.
              "wasGPSSessionDataSaved": true,
            });

            // Pumping the GPSPage
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            // Getting the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedDashboardStrings lds = .new(context);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            await gpsFromGPSPageToProcessPage(tester);

            // ── ADDING A PARTICIPANT ──────────────────────────────────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewParticipantsListPage(tester);

            // Searching for the new participant text field
            // Searching by placeholder text is not robust enough
            var newParticipantTextFieldFinder = find.byKey(const Key("participantNameField"));
            await tester.ensureVisible(newParticipantTextFieldFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(newParticipantTextFieldFinder);
            await tester.pumpAndSettle();
            
            // Adding the name
            await tester.enterText(newParticipantTextFieldFinder, name1);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Checking the checkbox
            var deletionCheckboxFinder = find.byKey(const ValueKey("editable-deletable-checkbox-0"));
            await tester.ensureVisible(deletionCheckboxFinder); 
            await tester.pumpAndSettle(); 
            await tester.tap(deletionCheckboxFinder);
            await tester.pumpAndSettle();

            // Tapping the deletion label
            var bulkDeletionFinder = find.textContaining("Delete");
            await tester.tap(bulkDeletionFinder);
            await tester.pumpAndSettle();

            // Verifying the correct snackbar message present ───────────────────────────────────────────
            // snackbarMessage hard-coded strings
            var snackbarMessage = "";
            
            var localeLanguageCode = getLocaleLanguageCode(tester);

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): { snackbarMessage = "Data deleted"; }
              case("fr"): { snackbarMessage = "Données supprimées"; }        
            }
            
            if (testingDebug) pu.printd("Testing Debug: snackbarMessage: $snackbarMessage");
            
            // Verifying consistency between hard-coded string and localized string
            // NewParticipantsDeletionByBulk: lds.snackbarMessageDataDeleted
            expect(snackbarMessage, lds.snackbarMessageDataDeleted);  
            
            // Verifying the snackbarMessage present
            expect(find.text(lds.snackbarMessageDataDeleted), findsOne);
            
            // Verifying the edited name absent
            expect(find.text(name1), findsNothing);

          });
        
      });

    });  

    group("Participants loading/dashboard Tests: \n", () 
    {
      group("Participants loading: \n", () 
      {        
        testWidgets("Participants can be loaded from an existing list, they can be edited, "
        "and deleted using single deletion or bulk deletion", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving process page.
            "wasGPSSessionDataSaved": false,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedParticipantsStrings lps = .new(context);
          LocalizedGPSStrings lgps = .new(context);

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
          var optionsPageFinder = find.text(lps.participantsListsSubTitle);
          expect(optionsPageFinder, findsOne);

          // Searching the loading button
          var loadingAListOptionFinder = find.text(lps.loadingAListOptionLabel);
          await tester.ensureVisible(loadingAListOptionFinder);
          expect(loadingAListOptionFinder, findsOne);

          // Tapping on it
          await tester.tap(loadingAListOptionFinder);
          await tester.pumpAndSettle();

          // Verifying the lists dashboard title present
          var participantsListsDashboardTitleFinder = find.text(lps.listsDashboardTitle);
          expect(participantsListsDashboardTitleFinder, findsOne);

          // Searching for a loading button
          var loadingButtonFinder = find.descendant
          (
            of: find.byType(ElevatedButton), 
            matching: find.text(lps.loadingButtonLabel)
          );
          expect(participantsListsDashboardTitleFinder, findsOne);

          // await tester.pump(const Duration(seconds: 2));

          // Tapping on it
          await tester.tap(loadingButtonFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process present
          expect(find.text(lgps.checkListTitle), findsOne);

          // Verifying the names present
          for (var name in names1)
          {
            expect(find.text(name), findsOne);    
          }  

          // ── PARTICIPANTS EDITION   ─────────────────────────────────
          // ───────────────────────────────────────────────────────────

          // Tapping the edit emoji to enter edition mode
          await tester.tap(find.text(editEmoji).last);
          await tester.pumpAndSettle();

          for (var name in names1)
          {
            // Tapping the name
            await tester.tap(find.text(name));  
            await tester.pumpAndSettle();

            // Finding the text field
            var textFieldFinder = find.byKey(const Key("gpsParticipantsEditField"));            
            await tester.enterText(textFieldFinder, "${name}${editionSuffix}");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // helped with a failing test
            await tester.pump(const Duration(seconds: 1));

          } 
          await tester.pumpAndSettle();

          // Verifying the text field absent
          expect(find.byKey(const Key("gpsParticipantsEditField")), findsNothing);

          // Verifying the edition
          for (var name in names1)
          {
            expect(find.text("${name}${editionSuffix}"), findsOne);
          }

          // ── PARTICIPANTS DELETION   ─────────────────────────────────
          // ───────────────────────────────────────────────────────────

            // ── SINGLE DELETION   ─────────────────────────────────
          // Edit mode still on
          // Clicking on "Clear One"
          await tester.tap(find.text(lgps.participantIdentifiersSingleDeletionLabel));

          await tester.pump(const Duration(seconds: 2));

          // Clicking on the delete icon for name1
          var identifierForName1Finder = find.ancestor
          (
            of: find.text("${name1}${editionSuffix}"), 
            matching: find.byType(IdentifierWidget)
          );

          var deleteIconForName1Finder = find.descendant
          (
            of: identifierForName1Finder, 
            matching: find.byIcon(Icons.delete_rounded)
          );

          await tester.tap(deleteIconForName1Finder);
          await tester.pumpAndSettle();

          await tester.pump(const Duration(seconds: 2));

          // Verifying the name removed
          expect(find.text("${name1}${editionSuffix}"), findsNothing);

           // ── BULK DELETION   ─────────────────────────────────
          // Edit mode still on
          // Clicking on "Clear All"
          await tester.tap(find.text(lgps.participantIdentifiersBulkDeletionLabel));
          await tester.pumpAndSettle();

          // Verifying remaining names absent
          expect(find.text("${name2}${editionSuffix}"), findsNothing);
          expect(find.text("${name3}${editionSuffix}"), findsNothing);

          await tester.pump(const Duration(seconds: 1));
      });      
        
        testWidgets("(Mobile) Stakeholders identifiers' colors can be changed from green, to orange, to red, and vice-versa by swiping", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving process page.
            "wasGPSSessionDataSaved": false,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
          // ──────────────────────────────────────────────────────────────────────────────────────
          List< Map<String,Map<String, dynamic>> > listDataMapsList =
          [
            {listLabel1:{"names":names1,"keywords":[]}},
          ];
          await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);
        
          // Verifying the names present
          for (var name in names1)
          {
            expect(find.text(name), findsOne);    
          }  

          if (Platform.isAndroid || Platform.isIOS)
          {
            // ── MODIFYING FEEDBACK DATA ON EMOTIONS   ──────────────────
            // ───────────────────────────────────────────────────────────
            var name1Finder = find.text(name1);
            // Searching the container
            var identifierFinder = find.ancestor
            (
              of: name1Finder, 
              matching: find.byType(IdentifierWidget)
            );

            var containerFinder = find.descendant
            (
              of: identifierFinder, 
              matching: find.byType(Container)
            );

            // Verifying that the color is green
            await gpsTestIdentifierColor(tester, containerFinder, greenShade900);
            await tester.pump(const Duration(seconds: 2));

              // SWIPING RIGHT  
            await tester.fling(name1Finder, const Offset(100, 0), 1000.0);
            await tester.pumpAndSettle();
            await gpsTestIdentifierColor(tester, containerFinder, orange);

            await tester.fling(name1Finder, const Offset(100, 0), 1000.0);
            await tester.pumpAndSettle();
            await gpsTestIdentifierColor(tester, containerFinder, red);

              // SWIPING LEFT
            await tester.fling(name1Finder, const Offset(-100, 0), 1000.0);
            await tester.pumpAndSettle();
            await gpsTestIdentifierColor(tester, containerFinder, orange);

            await tester.fling(name1Finder, const Offset(-100, 0), 1000.0);
            await tester.pumpAndSettle();
            await gpsTestIdentifierColor(tester, containerFinder, greenShade900);
            // await tester.pump(const Duration(seconds: 2));
          }
      });      
        
      });

      group("Participants dashboard Tests: \n", () 
      {    

        group("Entered list data is displayed on the list dashboard: Mobile: \n", ()
        {
          testWidgets("List data entered (participants, list name, keywords) is found: "
            "(assuming an already selected path to the user session data folder)",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedGPSStrings lgps = .new(context);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              await gpsFromGPSPageToProcessPage(tester);

              // ── CLICKING TO DISPLAY THE PARTICIPANTS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────────
              // Adding the names
              await gpsFromProcessPageAddParticipantsAndKeywords(tester, names1, keywordsListKwCompanionship);   

              // Verifying the names present
              expect(find.text(name1), findsOne);    
              expect(find.text(name2), findsOne);  

              // Searching the "Save" icon
              var saveListIconFinder = find.byIcon(Icons.save_outlined);
              expect(saveListIconFinder, findsOne);

              // Tapping on it
              await tester.tap(saveListIconFinder);
              await tester.pumpAndSettle();

              // Searching the text field to add the list name
              var listNameSavingTextFieldFinder = find.byKey(const Key("saveListField"));
              expect(listNameSavingTextFieldFinder, findsOne);

              // Adding a list name
              await tester.ensureVisible(listNameSavingTextFieldFinder);
              await tester.tap(listNameSavingTextFieldFinder);
              await tester.enterText(listNameSavingTextFieldFinder, listLabel1);
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();

              // Verifying the GPS process page present
              expect(find.text(lgps.checkListTitle), findsOne);

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
              for (var kw in keywordsListKwCompanionship)
              {
                expect(find.text(kw), findsOne);
              }

              // await tester.pump(const Duration(seconds: 5));
            }
          );
        });   

        group("Sorting and Filtering Tests: \n", ()
        {
          testWidgets("Sorting by list label \n",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedParticipantsStrings lps = .new(context);

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
              var sortByTitleFinder = find.textContaining(lps.listsSortByLabel);
              await tester.tap(sortByTitleFinder);
              await tester.pumpAndSettle();
              // await tester.pump(const Duration(seconds: 2));

              // Searching the list labels          
              var titlesFinder = await dashboardGetAllSessionsTitles(tester);
              var totalTitles = titlesFinder.evaluate().length;
              if (testingDebug) pu.printd("Testing Debug: totalTitles: $totalTitles");

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
        
          testWidgets("Filtering by keywords \n",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
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
                {listLabel1:{"names":names1,"keywords":keywordsListKwCompanionship}},
                {listLabel2:{"names":names2,"keywords":keywordsListKwWorkplace}},
                {listLabel3:{"names":names3,"keywords":keywordsListKwWorkplace}},                          
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
              if (testingDebug) pu.printd("Testing Debug: totalTitles for $kwCompanionship: $totalTitles");

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
              if (testingDebug) pu.printd("Testing Debug: totalTitles for $kwWorkplace: $totalTitles");

              for (var index = 0; index < totalTitles; index++)
              {
                expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesWorkplace.reversed.toList()[index]);
              }         

              // await tester.pump(const Duration(seconds: 2));

            });      
        
        });
    
        group("Deletion Tests: \n", ()
        {
          testWidgets("Deletion: Single deletion with icon \n",
            (WidgetTester tester) async {

              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedParticipantsStrings lps = .new(context);

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
              var deleteIconFinder = find.byTooltip(lps.listsDeleteTooltipLabel);

              // Tapping the icon
              await tester.tap(deleteIconFinder);
              await tester.pumpAndSettle();

              // Verifying the list item absent
              var sessionListItemFinder = await dashboardGetSessionListItemFinderByTitle(tester: tester, title: listLabel1);
              expect(sessionListItemFinder, findsNothing);
            }      
          );         
        
          testWidgets("Deletion: Bulk deletion \n"
                      "(the correct snackbar message is displayed) ",
            (WidgetTester tester) async {

              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedDashboardStrings lds = .new(context);

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
                of: find.ancestor(of: find.text(listLabel1), matching: find.byType(ParticipantsListsItem)), 
                matching: find.byType(Checkbox)
              );
              await tester.ensureVisible(checkbox1Finder);
              await tester.tap(checkbox1Finder);
              await tester.pumpAndSettle();

            var checkbox2Finder = find.descendant
              (
                  of: find.ancestor(of: find.text(listLabel2), matching: find.byType(ParticipantsListsItem)), 
                  matching: find.byType(Checkbox)
              );
              await tester.ensureVisible(checkbox2Finder);
              await tester.tap(checkbox2Finder);
              await tester.pumpAndSettle();

              // ── BULK DELETION ────────────────────────────────────────────────────────────
              // ─────────────────────────────────────────────────────────────────────────────            
              // Searching the widget 
              var bulkDeletionFinder = find.textContaining("Delete");
              expect(bulkDeletionFinder, findsOne);
              await tester.ensureVisible(bulkDeletionFinder);
              // Deletion
              await tester.tap(bulkDeletionFinder);
              await tester.pumpAndSettle();

              // Verifying the correct snackbar message present ───────────────────────────────────────────
              // snackbarMessage hard-coded strings
              var snackbarMessage = "";
              
              var localeLanguageCode = getLocaleLanguageCode(tester);

              switch(localeLanguageCode.toLowerCase())
              {
                case("en"): { snackbarMessage = "Data deleted"; }
                case("fr"): { snackbarMessage = "Données supprimées"; }        
              }
              
              if (testingDebug) pu.printd("Testing Debug: snackbarMessage: $snackbarMessage");
              
              // Verifying consistency between hard-coded string and localized string
              // ParticipantsListsDashboardDeletionByBulk: lds.snackbarMessageDataDeleted
              expect(snackbarMessage, lds.snackbarMessageDataDeleted);  
              
              // Verifying the snackbarMessage present
              expect(find.text(lds.snackbarMessageDataDeleted), findsOne);


              // ── TESTING THE DELETION ────────────────────────────────────────────────────────────
              // ───────────────────────────────────────────────────────────────────────────────────────       
              // Checking the number of list items left 
              var sessionsListItemsFinder = find.byType(ParticipantsListsItem);
              expect(sessionsListItemsFinder, findsOne);
              // Verifying listName3 remains
              var textFinder = find.text(listLabel3);
              Text textWidget = tester.widget(textFinder);
              expect(textWidget.data, listLabel3);            
            }      
          );
        });    
      
        group("Edition Tests: \n", ()
        {
          testWidgets("List label edition: Non empty label \n"
                      "(the correct snackbar message is displayed) ",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedParticipantsStrings lps = .new(context);

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
              if (testingDebug) pu.printd("Testing Debug: totalLabels: $totalLabels");

              // Verifying the label present
              expect((tester.widget<Text>(labelsFinder.first).data), listLabel1);

              // Tapping to edit the label
              await tester.tap(labelsFinder);
              await tester.pumpAndSettle();

              // Searching the text field to edit the label
              var listNameEditFieldFinder = find.byKey(const Key("listLabelGroupsDashboardEditField"));
              expect(listNameEditFieldFinder, findsOne);
              await tester.ensureVisible(listNameEditFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(listNameEditFieldFinder);
              await tester.pumpAndSettle();

              // Adding the edited label
              await tester.enterText(listNameEditFieldFinder, "${listLabel1}-edited");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();     

              // Verifying the correct snackbar message present ───────────────────────────────────────────
              // snackbarMessage hard-coded strings
              var snackbarMessage = "";
              
              var localeLanguageCode = getLocaleLanguageCode(tester);

              switch(localeLanguageCode.toLowerCase())
              {
                case("en"): { snackbarMessage = "List name updated"; }
                case("fr"): { snackbarMessage = "Nom de liste mis à jour"; }        
              }
              
              if (testingDebug) pu.printd("Testing Debug: snackbarMessage: $snackbarMessage");
              
              // Verifying consistency between hard-coded string and localized string
              // ParticipantsListsDashboard: lps.listUpdatedSnackBarMessage
              expect(snackbarMessage, lps.listUpdatedSnackBarMessage);  
              
              // Verifying the snackbarMessage present
              expect(find.text(lps.listUpdatedSnackBarMessage), findsOne);        
         

              // Verifying the edited label present
              expect(find.text("${listLabel1}-edited"), findsOne);                   

            });

          testWidgets("List label edition: Empty label \n",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedParticipantsStrings lps = .new(context);

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
              var listNameEditFieldFinder = find.byKey(const Key("listLabelGroupsDashboardEditField"));
              expect(listNameEditFieldFinder, findsOne);
              await tester.ensureVisible(listNameEditFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(listNameEditFieldFinder);
              await tester.pumpAndSettle();

              // Adding the empty label
              await tester.enterText(listNameEditFieldFinder, "");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle(); 

              // Clicking on the "Save" button
              // await tester.pump(const Duration(seconds: 5));  
              var saveButtonFinder = find.text(lps.saveButtonLabel); 
              await tester.tap(saveButtonFinder);
              await tester.pumpAndSettle();

              // Verifying error message present
              expect(find.text(lps.emptyLabelEditError), findsOne);

            });
        
          testWidgets("Participants edition: Non empty participants list \n"
                      "(the correct snackbar message is displayed) ",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedParticipantsStrings lps = .new(context);

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
              var participantsContainersFinder = await gpsGetParticipantsContainersOnParticipantsListsDashboard(tester);
              var totalNames = participantsContainersFinder.evaluate().length;
              if (testingDebug) pu.printd("Testing Debug: totalNames: $totalNames");

              // Searching for text within the container
              var aParticipant = 
                find.descendant(of: participantsContainersFinder, matching: find.byType(Text));

              // Tapping to edit the participants
              await tester.tap(aParticipant.first);
              await tester.pumpAndSettle();

              // Searching the text field to edit the participants
              var newParticipantsTextFieldFinder = find.byKey(const Key("participantsGroupsDashboardEditField"));
              expect(newParticipantsTextFieldFinder, findsOne);
              await tester.ensureVisible(newParticipantsTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(newParticipantsTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the edited participant data (comma-separated values)
              await tester.enterText(newParticipantsTextFieldFinder, "Bob,Benny,Alicia");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();        

              
              // Verifying the correct snackbar message present ───────────────────────────────────────────
              // snackbarMessage hard-coded strings
              var snackbarMessage = "";
              
              var localeLanguageCode = getLocaleLanguageCode(tester);

              switch(localeLanguageCode.toLowerCase())
              {
                case("en"): { snackbarMessage = "Participants updated"; }
                case("fr"): { snackbarMessage = "Participants mis à jour"; }        
              }
              
              if (testingDebug) pu.printd("Testing Debug: snackbarMessage: $snackbarMessage");
              
              // Verifying consistency between hard-coded string and localized string
              // ParticipantsListsDashboard: lps.participantsUpdatedSnackBarMessage
              expect(snackbarMessage, lps.participantsUpdatedSnackBarMessage);  
              
              // Verifying the snackbarMessage present
              expect(find.text(lps.participantsUpdatedSnackBarMessage), findsOne);       

              // Verifying data in the participants container
              participantsContainersFinder = await gpsGetParticipantsContainersOnParticipantsListsDashboard(tester);
              var participantsFinder = find.descendant
                                      (
                                        of: participantsContainersFinder, 
                                        matching: find.byType(Text)
                                      );

              var totalParticipants = participantsFinder.evaluate().length;
              if (testingDebug) pu.printd("Testing Debug: totalParticipants: $totalParticipants");

              List<String> editedAndSortedParticipantsList = ["Alicia","Benny","Bob"];
              for (var index = 0; index < totalParticipants; index++)
              {
                expect((tester.widget<Text>(participantsFinder.at(index)).data), editedAndSortedParticipantsList[index]);
              }

            });
        
          testWidgets("Participants edition: Empty participants list \n",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedParticipantsStrings lps = .new(context);

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
              var participantsContainersFinder = await gpsGetParticipantsContainersOnParticipantsListsDashboard(tester);
              var totalNames = participantsContainersFinder.evaluate().length;
              if (testingDebug) pu.printd("Testing Debug: totalNames: $totalNames");

              // Searching for text within the container
              var aParticipant = 
                find.descendant(of: participantsContainersFinder, matching: find.byType(Text));

              // Tapping to edit the participants
              await tester.tap(aParticipant.first);
              await tester.pumpAndSettle();

              // Searching the text field to edit the participants
              var newParticipantsTextFieldFinder = find.byKey(const Key("participantsGroupsDashboardEditField"));
              expect(newParticipantsTextFieldFinder, findsOne);
              await tester.ensureVisible(newParticipantsTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(newParticipantsTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the empty edited participant data
              await tester.enterText(newParticipantsTextFieldFinder, "");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle(); 

              // Clicking on the "Save" button
              // await tester.pump(const Duration(seconds: 5));  
              var saveButtonFinder = find.text(lps.saveButtonLabel); 
              await tester.tap(saveButtonFinder);
              await tester.pumpAndSettle();

              // Verifying error message present
              expect(find.text(lps.emptyParticipantsListError), findsOne);
            });
        
          testWidgets("Keywords edition \n"
                      "(the correct snackbar message is displayed) ",
            (WidgetTester tester) async 
            {
              // Setting mock values for SharedPreferences
              SharedPreferences.setMockInitialValues
              ({
                // Setting value for the first-run modal to be absent,
                "wasFirstRunModalAcknowledged": true,
                // and to have the group problem-solving page, with the dashboard.
                "wasGPSSessionDataSaved": true,
              });

              // Pumping the GPSPage
              await tester.pumpWidget(buildTestableGPSPage());
              await tester.pumpAndSettle();

              // Getting the localized strings
              var context = tester.element(find.byType(Scaffold).first);
              LocalizedDashboardStrings lds = .new(context);

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
              var newKeywordsTextFieldFinder = find.byKey(const Key("kwsGroupsDashboardEditField"));
              expect(newKeywordsTextFieldFinder, findsOne);
              await tester.ensureVisible(newKeywordsTextFieldFinder); 
              await tester.pumpAndSettle(); 
              await tester.tap(newKeywordsTextFieldFinder);
              await tester.pumpAndSettle();

              // Adding the edited keywords data (comma-separated values)
              await tester.enterText(newKeywordsTextFieldFinder, "${kwWorkplace},${kwCompanionship}");
              await tester.testTextInput.receiveAction(TextInputAction.done);
              await tester.pumpAndSettle();      

              // Verifying the correct snackbar message present ───────────────────────────────────────────
              // snackbarMessage hard-coded strings
              var snackbarMessage = "";
              
              var localeLanguageCode = getLocaleLanguageCode(tester);

              switch(localeLanguageCode.toLowerCase())
              {
                case("en"): { snackbarMessage = "Keywords updated"; }
                case("fr"): { snackbarMessage = "Mots-clés mis à jour"; }        
              }
              
              if (testingDebug) pu.printd("Testing Debug: snackbarMessage: $snackbarMessage");
              
              // Verifying consistency between hard-coded string and localized string
              // ParticipantsListsDashboard: lds.snackbarMessageKeywordsUpdated
              expect(snackbarMessage, lds.snackbarMessageKeywordsUpdated);  
              
              // Verifying the snackbarMessage present
              expect(find.text(lds.snackbarMessageKeywordsUpdated), findsOne);        

              // Verifying data
              var newKeywordsDataFinder = await dashboardGetKeywordsOnDashboard(tester);
              var editedAndSortedKeywordsData ="Keywords: $kwCompanionship, $kwWorkplace";
              expect((tester.widget<Text>(newKeywordsDataFinder).data), editedAndSortedKeywordsData);
            });
        
        });
    });
  });


});

  group("Ideas overlay-related Tests: \n", () 
  {

    group("Ideas overlay opening Tests: \n", () 
    {
      testWidgets("The overlay can be opened clicking on the ideas area title", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // Accessing the localized data
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings? lgps = .new(context);

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── CLICKING ON THE IDEAS LIST TITLE  ───────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          var ideasListTitleFinder = find.text(lgps.ideasListTitle);
          await tester.tap(ideasListTitleFinder);
          await tester.pumpAndSettle();

          // ── OVERLAY  ───────────────────────────────────
          // ───────────────────────────────────────────────
          // Verifying the overlay present
          expect(find.byKey(const Key("ideaOverlayField")), findsOne);
        });
      
      testWidgets("The overlay can be opened clicking on the ideas", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the text field used to add ideas
          var newIdeaTextFieldFinder = find.ancestor
          (
            of: find.text(lgps.newIdeaTextFieldHint), 
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
          var ideaFinder = find.byKey(const Key("idea-0"));
          await tester.tap(ideaFinder);
          await tester.pumpAndSettle();

          // Verifying the overlay present
          expect(find.byKey(const Key("ideaOverlayField")), findsOne);
        });
    });

    group("Ideas overlay editing Tests: \n", () 
    {
      var idea1 = "idea1";
      var idea2 = "idea2";
      var idea3 = "idea3";
      var idea4 = "idea4";

      testWidgets("Ideas can be added in the overlay", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // Accessing the context
          var context = tester.element(find.byType(Scaffold).first);

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(context:context, tester:tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the text field used to add ideas
          var newIdeaTextFieldFinder = find.byKey(const Key("ideaOverlayField"));
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
          var ideaFinder = find.byKey(const Key("idea-0"));
          await tester.ensureVisible(ideaFinder);
          await tester.pumpAndSettle();   
          // Verifying the idea present
          expect(ideaFinder, findsOne);

          // await tester.pump(const Duration(seconds: 5)); 
        });
    
      testWidgets("Ideas can be edited in the overlay", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(context: context, tester: tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          await gpsFromOverlayAddIdea(tester, idea1);

          // ── EDITING THE IDEA  ────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the idea
          var ideaFinder = find.byKey(const Key("editable-deletable-text-item-0"));
          await tester.ensureVisible(ideaFinder);
          await tester.pumpAndSettle();   
          // Verifying the idea present
          expect(ideaFinder, findsOne);
          // Tapping on the idea for edition
          await tester.tap(ideaFinder);
          await tester.pumpAndSettle();
          // Edition
          const tfKeyLabel = "editable-deletable-tf-0";
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
          var overlayClosingTooltipFinder = find.byTooltip(lgps.ideasListOverlayClosingTooltip);
          await tester.tap(overlayClosingTooltipFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process page present
          expect(find.text(lgps.checkListTitle), findsOne);

          // Verifing the edited idea on the GPS process page
          expect(find.text(ideaEdited), findsOne);

          // await tester.pump(const Duration(seconds: 2)); 
        });
    
      testWidgets("Ideas can be deleted in the overlay", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(context:context, tester:tester);

          // ── ADDING AN IDEA  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          await gpsFromOverlayAddIdea(tester, idea1);

          // ── DELETING THE IDEA  ────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the checkbox
          var checkboxFinder = find.byKey(const Key("editable-deletable-checkbox-0"));
          await tester.ensureVisible(checkboxFinder);
          await tester.pumpAndSettle();   
          // Tapping on the checkbox for deletion
          await tester.tap(checkboxFinder);
          await tester.pumpAndSettle();
          
          // Clicking on the Delete message
          var deleteFinder = find.textContaining("Delete");
          await tester.ensureVisible(deleteFinder);
          await tester.tap(deleteFinder);
          await tester.pumpAndSettle();

          // Verifying the value removed from the overlay
          expect(find.text(idea1), findsNothing);

          // Closing the overlay
          var overlayClosingTooltipFinder = find.byTooltip(lgps.ideasListOverlayClosingTooltip);
          await tester.tap(overlayClosingTooltipFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process page present
          expect(find.text(lgps.checkListTitle), findsOne);

          // Verifying the value removed from the GPS process page
          expect(find.text(idea1), findsNothing);

          // await tester.pump(const Duration(seconds: 2)); 
        });
    
      testWidgets("Ideas overlay: 4 additions, 2 deletions", 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for the first-run modal to be absent,
            "wasFirstRunModalAcknowledged": true,
            // and to have the group problem-solving page, with the dashboard.
            "wasGPSSessionDataSaved": true,
          });

          // Pumping the GPSPage
          await tester.pumpWidget(buildTestableGPSPage());
          await tester.pumpAndSettle();

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          await gpsFromGPSPageToProcessPage(tester);

          // ── REACHING THE OVERLAY  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await gpsFromProcessPageToIdeasOverlay(context:context, tester:tester);

          // ── ADDING IDEAS  ──────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          await gpsFromOverlayAddIdea(tester, idea1);
          await gpsFromOverlayAddIdea(tester, idea2);
          await gpsFromOverlayAddIdea(tester, idea3);
          await gpsFromOverlayAddIdea(tester, idea4);

          // ── DELETING 2 IDEAs  ────────────────────────────────────
          // ─────────────────────────────────────────────────────────
          // Searching the checkboxes
          var checkboxFinder = find.byKey(const Key("editable-deletable-checkbox-0"));
          await tester.ensureVisible(checkboxFinder);
          await tester.pumpAndSettle();   
          // Tapping on the checkbox for deletion
          await tester.tap(checkboxFinder);
          await tester.pumpAndSettle();

          checkboxFinder = find.byKey(const Key("editable-deletable-checkbox-2"));
          await tester.ensureVisible(checkboxFinder);
          await tester.pumpAndSettle();   
          // Tapping on the checkbox for deletion
          await tester.tap(checkboxFinder);
          await tester.pumpAndSettle();
          
          // Clicking on the Delete message
          var deleteFinder = find.textContaining("Delete");
          await tester.ensureVisible(deleteFinder);
          await tester.tap(deleteFinder);
          await tester.pumpAndSettle();

          // Verifying the values removed from the overlay
          expect(find.text(idea1), findsNothing);
          expect(find.text(idea2), findsNWidgets(2));
          expect(find.text(idea3), findsNothing);
          expect(find.text(idea4), findsNWidgets(2));

          // Closing the overlay
          var overlayClosingTooltipFinder = find.byTooltip(lgps.ideasListOverlayClosingTooltip);
          await tester.tap(overlayClosingTooltipFinder);
          await tester.pumpAndSettle();

          // Verifying the GPS process page present
          expect(find.text(lgps.checkListTitle), findsOne);

          // Verifying the values removed from the GPS process page
          expect(find.text(idea1), findsNothing);
          expect(find.text(idea2), findsOne);
          expect(find.text(idea3), findsNothing);
          expect(find.text(idea4), findsOne);

          // await tester.pump(const Duration(seconds: 2)); 
        });
    
    });
    
  });

  group("Visual Tests: Mobile: \n", ()
  {
    testWidgets("Sharing \n",
      (WidgetTester tester) async {
        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          "wasFirstRunModalAcknowledged": true,
          // and to have the group problem-solving page, with the dashboard.
          "wasGPSSessionDataSaved": true,
          // Temporary test dir as application folder path
          "applicationFolderPath": testTmpDir!.path
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
              ideasList: ideasListAtLeastOneIdeaNeeded,
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