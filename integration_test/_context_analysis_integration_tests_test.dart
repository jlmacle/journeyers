import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/widgets/utility/process_widgets/session_file_name_mobile_platforms.dart';

import '../test/helper_functions/externalized_testing_code.dart';

// Used define a folder value for getApplicationSupportPath (PathProvider) 
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

void main() async {
  // Required by the integration_test package.
  // https://docs.flutter.dev/testing/integration-tests#project-setup
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Keeping the app in portrait up mode 
  if (Platform.isAndroid || Platform.isIOS)
  {
    await SystemChrome.setPreferredOrientations
    ([
      DeviceOrientation.portraitUp,   // Normal upright portrait
    ]);
  }

  // ── Constants ─────────────────────────────────────────────────────────────

  // The test title text
  const String testAnalysisTitle = 'Integration-test CA session title';
  const String testAnalysisTitle2 = "$testAnalysisTitle (2)";

  // A keyword
  const String kw1 = 'Household';
  // Another keyword
  const String kw2 = 'Workplace';

  const List<String> kwsList = [kw1, kw2];

  // File names
  const String fileName1WithoutExtension = 'file1';
  const String fileName2WithoutExtension = 'file2';

  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;
  
  setUp(() async {
    // Creating a temporary folder to store the files to save
    testTmpDir = await Directory.systemTemp.createTemp('context_analysis_integration_test_');
    PathProviderPlatform.instance = PathProviderPlatformRedirectForTesting(testTmpDir!.path);
    // To use the alternative saving/reading file paths
    runningTests = true;
  });

  tearDown(() async {
    if (testTmpDir!.existsSync()) {
      // Deleting the temporary folder created to store the saved files
      await testTmpDir!.delete(recursive: true);
    }
  });

  // ── Test cases ─────────────────────────────────────────────────────────────

  // 'Context Analysis Integration Tests: Mobile: \n'
  group('Context Analysis Integration Tests: Mobile: \n', () {
    // 'Metadata entered is found on the dashboard \n'
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
      'Metadata entered is found on the dashboard \n'
      '(assuming an already selected path to the user session data folder)',
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          'wasFirstRunModalAcknowledged': true,
          // and to have the context analysis page, with the dashboard.
          'wasSessionDataSaved': true,
          // Temporary test dir as application folder path
          'applicationFolderPath': testTmpDir!.path
        });

        // Pumping the CAPage
        //
        // pumpWidget renders the first frame.
        // pumpAndSettle drives the event loop until there are no more pending frames,
        // letting the async getPreferences() call complete 
        // and setState(() { _preferencesLoading = false; }) rebuild the tree.
        //
        // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html
        await tester.pumpWidget(buildTestableCAPage());
        await tester.pumpAndSettle();

        // Verifying that the new process button functions
        await checkNewCAProcessButtonFunctions(tester);

        // ── CA PROCESS FILLING ─────────────────────────────────────────────────────────────
        // ───────────────────────────────────────────────────────────────────────────────────

        // ── TITLE SECTION ─────────────────────────────────────────────────────────────
        await enterCAProcessTitle(tester, testAnalysisTitle);

        // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
        await enterCAProcessKeywords(tester, kwsList);
        
        // ── FORM SECTION: left blank in this test ─────────────────────────────────────────────────────────────

        // ── SUBMIT BUTTON SECTION ─────────────────────────────────────────────────────────────
        if (Platform.isAndroid || Platform.isIOS)
        {
          // Entering the file name and submitting data
          await enterFileNameOnMobile(tester: tester, fileNameWithoutExtension: fileName1WithoutExtension);

          // ── SEARCHING FOR THE METADATA ON THE DASHBOARD SECTION ─────────────────────────────────────────────────────────────

          // Searching for the title
          expect(find.text(testAnalysisTitle), findsOne);

          // Searching for the keywords
          expect(find.text(kw1), findsOne);
          expect(find.text(kw2), findsOne);

          // await tester.pump(const Duration(seconds: 2));
        }
      },
    );
  
    // 'Session data entered is found on the preview: '
    // 'all fields filled \n'
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
      'Session data entered is found on the preview: '
      'all fields filled \n'
      '(assuming an already selected path to the user session data folder)',
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          'wasFirstRunModalAcknowledged': true,
          // and to have the context analysis page, with the dashboard.
          'wasSessionDataSaved': true,
          // Temporary test dir as application folder path
          'applicationFolderPath': testTmpDir!.path
        });

        // Pumping the CAPage
        //
        // pumpWidget renders the first frame.
        // pumpAndSettle drives the event loop until there are no more pending frames,
        // letting the async getPreferences() call complete 
        // and setState(() { _preferencesLoading = false; }) rebuild the tree.
        //
        // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html
        await tester.pumpWidget(buildTestableCAPage());
        await tester.pumpAndSettle();

        // Verifying that the new process button functions
        await checkNewCAProcessButtonFunctions(tester);

        // ── TITLE SECTION ─────────────────────────────────────────────────────────────
        await enterCAProcessTitle(tester, testAnalysisTitle2);

        // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
        await enterCAProcessKeywords(tester, kwsList);
        
        // ── FORM SECTION ─────────────────────────────────────────────────────────────
        // Individual perspective testing values
        // 7 values are necessary
        List<bool> checkboxValues = List.filled(7, true);
        // a1 to a7
        List<String> checkboxTextFieldValues = List.generate(7, (i) => "a${i+1}");
        String indivAnotherIssueStrValue = "a8";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "b1";
        // 4 values are necessary
        List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"Yes","No"}];
        // b2 to b5
        List<String> segmentedButtonTextFieldValues = List.generate(4, (i) => "b${i+2}");
        
        await fillCAForm(tester, checkboxValues, checkboxTextFieldValues, indivAnotherIssueStrValue, 
        groupProblemsToSolveStrValue, segmentedButtonValues, segmentedButtonTextFieldValues);
  
        // ── SUBMIT BUTTON SECTION ─────────────────────────────────────────────────────────────
        if (Platform.isAndroid || Platform.isIOS)
        {
          // Entering the file name and submitting data
          await enterFileNameOnMobile(tester: tester, fileNameWithoutExtension: fileName1WithoutExtension);

          // ── SEARCHING FOR THE METADATA ON THE DASHBOARD SECTION ─────────────────────────────────────────────────────────────

          // Searching for the title
          expect(find.text(testAnalysisTitle2), findsOne);

          // Searching for the keywords
          expect(find.text(kw1), findsOne);
          expect(find.text(kw2), findsOne);

          // ── TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
          // Putting all string values together, to retrieve them by index
          List<String> individualStringValues = [...checkboxTextFieldValues, indivAnotherIssueStrValue];
          List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

          await testPreview(tester, individualStringValues, segmentedButtonValues, groupStringValues);
  
          // await tester.pump(const Duration(seconds: 2));
        }
      },
    );

    // 'Session data entered is found on the preview: '
    // 'not all fields filled: 1: several unchecked checkboxes, several unselected segmented buttons, empty text field only items \n'
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
    'Session data entered is found on the preview: '
    'not all fields filled: 1: several unchecked checkboxes, several unselected segmented buttons, empty text field only items \n'
    '(assuming an already selected path to the user session data folder)',
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        'wasFirstRunModalAcknowledged': true,
        // and to have the context analysis page, with the dashboard.
        'wasSessionDataSaved': true,
        // Temporary test dir as application folder path
        'applicationFolderPath': testTmpDir!.path
      });

      // Pumping the CAPage
      //
      // pumpWidget renders the first frame.
      // pumpAndSettle drives the event loop until there are no more pending frames,
      // letting the async getPreferences() call complete 
      // and setState(() { _preferencesLoading = false; }) rebuild the tree.
      //
      // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html
      await tester.pumpWidget(buildTestableCAPage());
      await tester.pumpAndSettle();

      // Verifying that the new process button functions
      await checkNewCAProcessButtonFunctions(tester);

      // ── TITLE SECTION ─────────────────────────────────────────────────────────────
      await enterCAProcessTitle(tester, testAnalysisTitle2);

      // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
      await enterCAProcessKeywords(tester, kwsList);
      
      // ── FORM SECTION ─────────────────────────────────────────────────────────────
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
      
      await fillCAForm(tester, checkboxValues, checkboxTextFieldValues, indivAnotherIssueStrValue, 
      groupProblemsToSolveStrValue, segmentedButtonValues, segmentedButtonTextFieldValues);

      // ── SUBMIT BUTTON SECTION ─────────────────────────────────────────────────────────────
      Finder fileNameWidgetFinder;
      if (Platform.isAndroid || Platform.isIOS)
      {
        fileNameWidgetFinder =  find.byType(SessionFileNameMobilePlatforms);

        // Path to folder already declared 
        // Scrolling to make the text field visible for small screens
        await tester.ensureVisible(fileNameWidgetFinder);

        // Entering a file name
        await tester.enterText(fileNameWidgetFinder, fileName2WithoutExtension);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // ── SEARCHING FOR THE METADATA ON THE DASHBOARD SECTION ─────────────────────────────────────────────────────────────

        // Searching for the title
        expect(find.text(testAnalysisTitle2), findsOne);

        // Searching for the keywords
        expect(find.text(kw1), findsOne);
        expect(find.text(kw2), findsOne);

        // ── TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxTextFieldValues, indivAnotherIssueStrValue]
          .where((string) => string.isNotEmpty)
          .toList();
  
        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

        await testPreview(tester, individualStringValues, segmentedButtonValues, groupStringValues);

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

    // 'Session data entered is found on the preview: '
    // 'not all fields filled: 2: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n'
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
    'Session data entered is found on the preview: '
    'not all fields filled: 2: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n'
    '(assuming an already selected path to the user session data folder)',
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        'wasFirstRunModalAcknowledged': true,
        // and to have the context analysis page, with the dashboard.
        'wasSessionDataSaved': true,
        // Temporary test dir as application folder path
        'applicationFolderPath': testTmpDir!.path
      });

      // Pumping the CAPage
      //
      // pumpWidget renders the first frame.
      // pumpAndSettle drives the event loop until there are no more pending frames,
      // letting the async getPreferences() call complete 
      // and setState(() { _preferencesLoading = false; }) rebuild the tree.
      //
      // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html
      await tester.pumpWidget(buildTestableCAPage());
      await tester.pumpAndSettle();

      // Verifying that the new process button functions
      await checkNewCAProcessButtonFunctions(tester);

      // ── TITLE SECTION ─────────────────────────────────────────────────────────────
      await enterCAProcessTitle(tester, testAnalysisTitle2);

      // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
      await enterCAProcessKeywords(tester, kwsList);
      
      // ── FORM SECTION ─────────────────────────────────────────────────────────────
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
      
      await fillCAForm(tester, checkboxValues, checkboxTextFieldValues, indivAnotherIssueStrValue, 
      groupProblemsToSolveStrValue, segmentedButtonValues, segmentedButtonTextFieldValues);

      // ── SUBMIT BUTTON SECTION ─────────────────────────────────────────────────────────────
      Finder fileNameWidgetFinder;
      if (Platform.isAndroid || Platform.isIOS)
      {
        fileNameWidgetFinder =  find.byType(SessionFileNameMobilePlatforms);

        // Path to folder already declared 
        // Scrolling to make the text field visible for small screens
        await tester.ensureVisible(fileNameWidgetFinder);

        // Entering a file name
        await tester.enterText(fileNameWidgetFinder, fileName2WithoutExtension);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // ── SEARCHING FOR THE METADATA ON THE DASHBOARD SECTION ─────────────────────────────────────────────────────────────

        // Searching for the title
        expect(find.text(testAnalysisTitle2), findsOne);

        // Searching for the keywords
        expect(find.text(kw1), findsOne);
        expect(find.text(kw2), findsOne);

        // ── TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxTextFieldValues, indivAnotherIssueStrValue]
          .where((string) => string.isNotEmpty)
          .toList();
  
        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

        await testPreview(tester, individualStringValues, segmentedButtonValues, groupStringValues);

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

    // 'Session data entered is found on the preview: '
    // 'not all fields filled: 3: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n'
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
    'Session data entered is found on the preview: '
    'not all fields filled: 3: several unchecked checkboxes, several unselected segmented buttons, one empty text field only item \n'
    '(assuming an already selected path to the user session data folder)',
    (WidgetTester tester) async {

      // Setting mock values for SharedPreferences
      SharedPreferences.setMockInitialValues
      ({
        // Setting value for the first-run modal to be absent,
        'wasFirstRunModalAcknowledged': true,
        // and to have the context analysis page, with the dashboard.
        'wasSessionDataSaved': true,
        // Temporary test dir as application folder path
        'applicationFolderPath': testTmpDir!.path
      });

      // Pumping the CAPage
      //
      // pumpWidget renders the first frame.
      // pumpAndSettle drives the event loop until there are no more pending frames,
      // letting the async getPreferences() call complete 
      // and setState(() { _preferencesLoading = false; }) rebuild the tree.
      //
      // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html
      await tester.pumpWidget(buildTestableCAPage());
      await tester.pumpAndSettle();

      // Verifying that the new process button functions
      await checkNewCAProcessButtonFunctions(tester);

      // ── TITLE SECTION ─────────────────────────────────────────────────────────────
      await enterCAProcessTitle(tester, testAnalysisTitle2);

      // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
      await enterCAProcessKeywords(tester, kwsList);
      
      // ── FORM SECTION ─────────────────────────────────────────────────────────────
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
      
      await fillCAForm(tester, checkboxValues, checkboxTextFieldValues, indivAnotherIssueStrValue, 
      groupProblemsToSolveStrValue, segmentedButtonValues, segmentedButtonTextFieldValues);

      // ── SUBMIT BUTTON SECTION ─────────────────────────────────────────────────────────────
      Finder fileNameWidgetFinder;
      if (Platform.isAndroid || Platform.isIOS)
      {
        fileNameWidgetFinder =  find.byType(SessionFileNameMobilePlatforms);

        // Path to folder already declared 
        // Scrolling to make the text field visible for small screens
        await tester.ensureVisible(fileNameWidgetFinder);

        // Entering a file name
        await tester.enterText(fileNameWidgetFinder, fileName2WithoutExtension);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // ── SEARCHING FOR THE METADATA ON THE DASHBOARD SECTION ─────────────────────────────────────────────────────────────

        // Searching for the title
        expect(find.text(testAnalysisTitle2), findsOne);

        // Searching for the keywords
        expect(find.text(kw1), findsOne);
        expect(find.text(kw2), findsOne);

        // ── TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
        // Putting all non-empty string values together, to retrieve them by index
        List<String> individualStringValues = 
          [...checkboxTextFieldValues, indivAnotherIssueStrValue]
          .where((string) => string.isNotEmpty)
          .toList();
  
        List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

        await testPreview(tester, individualStringValues, segmentedButtonValues, groupStringValues);

        // await tester.pump(const Duration(seconds: 2));
      }
    },
  ); 

  });
}