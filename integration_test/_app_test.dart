import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:integration_test/integration_test.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/pages/homepage.dart";
import "package:journeyers/utils/generic/dev/test_utils.dart";

import "externalized_code/externalized_testing_code.dart";

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

  // ── App pumping ─────────────────────────────────────────────────────────────
  Future<void> pumpApp(WidgetTester tester) async
  {
    // Pumping the app
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(onLanguageSelectedCallbackFunction: (_){})
      )
    );
    await tester.pumpAndSettle();
  }

  // ── Constants ─────────────────────────────────────────────────────────────

  // Titles
  const testAnalysisTitleRoot = "Integration-test CA session title";
  

  // Ideas
  const ideasList2Ideas = ["idea1", "idea2"];

  // File names
  const fileName1WithoutExtension = "file1";
 
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

  group("Application Tests: Mobile: \n", () 
  {
    testWidgets("CA + GPS: Session data entered in the context analysis "
                "is available for the group problem-solving"
      " (assuming an already selected path to the user session data folder)",
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          "wasFirstRunModalAcknowledged": true,
          // to have the context analysis page, with the dashboard,
          "wasCASessionDataSaved": true,
          // and to have the group problem-solving page, with the dashboard.
          "wasGPSSessionDataSaved": true,
          // Temporary test dir as application folder path
          "applicationFolderPath": testTmpDir!.path
        });

        if (Platform.isAndroid || Platform.isIOS)
        {
          // Pumping the app
          await pumpApp(tester);
          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────
          var totalEntries = 20;
          var titlesList = List.generate(totalEntries, (i)=> "$testAnalysisTitleRoot ($i)");
          var kwsLists = List.generate(totalEntries, (i)=> ["keyword-$i"]);
          var fileNamesWithoutExtensionList = List.generate(totalEntries, (i)=> "${fileName1WithoutExtension}_${i}");
          
          // formToFill: false to skip the form filling
          await caEnterSeveralTimesNewProcessData
          (
            tester: tester, 
            formToFill: false,
            titlesList: titlesList,
            kwsLists: kwsLists,
            fileNamesWithoutExtensionList: fileNamesWithoutExtensionList
          );

          // await tester.pump(const Duration(seconds: 2));      

          // ── 2. REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────
          // Reaching the GPS process page from the home page
          await gpsFromHomePageToProcessPage(tester);          

          // ── 3. SEARCHING FOR THE CA SESSION DATA IN THE GPS PROCESS  ──────────────────
          // ──────────────────────────────────────────────────────────────────────────────          
          // Searching the placeholder title
          var placeholderTitleFinder = find.text(lgps.gpsDefaultProcessSessionTitle);

          // Tapping on it
          await tester.tap(placeholderTitleFinder);
          await tester.pumpAndSettle();
          // Searching for the last title of the CA data         
          // Scrolling to tap on the last title
          var lastTitle = find.text("$testAnalysisTitleRoot (0)");

          await tester.scrollUntilVisible
            (
              lastTitle, 
              45, 
              scrollable: find.descendant
                        (
                          of: find.byKey(const Key("gps-title-scrollview")), 
                          matching: find.byType(Scrollable)
                        ),
            );            
          await tester.pumpAndSettle();

          await tester.tap(lastTitle);
          await tester.pumpAndSettle();
          // await tester.pump(const Duration(seconds: 2));

          // Searching the keywords declaration title
          var keywordsDeclarationTitleFinder = find.descendant
                                        (
                                          of: find.byType(GPSKeywordsDeclaration), 
                                          matching: find.text(lgps.gpsKeywordsTitle)
                                        );

          // Tapping on it to open the overlay
          await tester.tap(keywordsDeclarationTitleFinder);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2)); 

          // Verifying that the keyword has been imported
          var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
          expect(inputChipTextFinder, findsOne);         
          expect(find.text("keyword-0"), findsOne);
          
          // Searching the tooltip to close the overlay
          var closingIconFinder = find.byTooltip(lgps.gpsKeywordsDeclarationOverlayCloseIconButtonToolTip);

          // Closing the overlay
          await tester.tap(closingIconFinder);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2)); 

          // Verifying the overlay absent
          expect
          (
            find.descendant
            (
              of: find.byType(GPSKeywordsDeclaration), 
              matching: find.byType(StatefulBuilder)
            )        , 
            findsNothing
          );

          // ── 4. ADDING ADDITIONAL GPS DATA  ──
          // ────────────────────────────────────          

          // Adding ideas
          // Searching the text field used to add ideas
          var newIdeaTextFieldFinder = find.ancestor
          (
            of: find.text(lgps.newIdeaTextFieldHint), 
            matching: find.byType(TextField)
          );

          // Adding the ideas
          for (var idea in ideasList2Ideas)
          {
            await tester.enterText(newIdeaTextFieldFinder, idea);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));  

            await tester.tap(newIdeaTextFieldFinder); 
          }

          // Submitting the GPS data
          await dashboardEnterFileNameAndSubmitDataOnMobile(tester: tester, fileNameWithoutExtension: fileName1WithoutExtension);

          await tester.pump(const Duration(seconds: 5));
          // ── 5. VERIFYING THE CA DATA ON THE GPS PAGE  ───
          // ────────────────────────────────────────────────

          // Verifying the GPS page present
          expect(find.byType(GPSPage), findsOne);

          // Searching for the title imported from the CA 
          expect(find.text("$testAnalysisTitleRoot (0)${lgps.gpsTitleSuffix}"), findsOne);

          // Searching for the keyword imported from the CA 
          expect(find.text("keyword-0"), findsOne);

          // await tester.pump(const Duration(seconds: 2));
        }
    });
        
  });
  
}