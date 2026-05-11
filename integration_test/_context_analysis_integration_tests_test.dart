import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/1_context_analysis_title_declaration.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/2_context_analysis_keywords_declaration.dart';
import 'package:journeyers/widgets/utility/process_widgets/new_process_button.dart';
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

void main() {
  // Required by the integration_test package.
  // https://docs.flutter.dev/testing/integration-tests#project-setup
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Constants ─────────────────────────────────────────────────────────────

  // The test title text
  const String testAnalysisTitle = 'Integration-test CA session title';
  const String testAnalysisTitle2 = "$testAnalysisTitle (2)";

  // A keyword
  const String kw1 = 'Household';
  // Another keyword
  const String kw2 = 'Workplace';

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

  // ── Test case ─────────────────────────────────────────────────────────────

  // 'Context Analysis Integration Tests: Mobile: \n'
  group('Context Analysis Integration Tests: Mobile: \n', () {
    // 'Assuming an already selected path to the user session data folder,'
    // 'the metadata entered during the context analysis is found on the dashboard'
    testWidgets(
      'Assuming an already selected path to the user session data folder,'
      'the metadata entered during the context analysis is found on the dashboard',
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

        // Verifying the NewProcessButton present
        expect(
          find.byType(NewProcessButton),
          findsOneWidget,
          reason: 'NewProcessButton should be visible when CA session data is already saved.',
        );

        // Tapping NewProcessButton
        await tester.tap(find.byType(NewProcessButton));
        // pumpAndSettle waits for CAProcess (and its _loadDTO / initState async work)
        // to settle before searching for children widgets.
        await tester.pumpAndSettle();

        // Verifying CAProcess displayed
        expect(
          find.byType(CAProcess),
          findsOneWidget,
          reason: 'CAProcess should be visible after tapping NewProcessButton.',
        );

        // ── TITLE SECTION ─────────────────────────────────────────────────────────────
        // Searching the TextField inside CATitleDeclaration
        Finder titleTextField = find.descendant(
          of: find.byType(CATitleDeclaration),
          matching: find.byType(TextField),
        );

        expect(
          titleTextField,
          findsOneWidget,
          reason: 'A TextField should exist inside CATitleDeclaration.',
        );

        // Entering a title
        await tester.enterText(titleTextField, testAnalysisTitle);

        // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
        // Searching the TextField inside CAKeywordsDeclaration
        Finder keywordsTextField = find.descendant(
          of: find.byType(CAKeywordsDeclaration),
          matching: find.byType(TextField),
        );

        // Entering a keyword
        await tester.enterText(keywordsTextField, kw1);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Necessary for kw2 to be added
        await tester.tap(keywordsTextField);

        // Entering another keyword 
        await tester.enterText(keywordsTextField, kw2);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        
        // ── FORM SECTION: left blank in this test ─────────────────────────────────────────────────────────────

        // ── SUBMIT BUTTON SECTION ─────────────────────────────────────────────────────────────
        Finder fileNameWidgetFinder;
        if (Platform.isAndroid || Platform.isIOS)
        {
          fileNameWidgetFinder =  find.byType(SessionFileNameMobilePlatforms);

          // Path to folder already declared 
          // Scrolling to make the text field visible for small screens
          await tester.ensureVisible(fileNameWidgetFinder);

          // Entering a file name
          await tester.enterText(fileNameWidgetFinder, fileName1WithoutExtension);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

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
  
    // 'Assuming an already selected path to the user session data folder,'
    // 'session data entered during the context analysis is found on the preview'
    // '(all fields filled)'
    testWidgets(
      'Assuming an already selected path to the user session data folder,'
      'session data entered during the context analysis is found on the preview'
      '(all fields filled)',
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

        // Verifying the NewProcessButton present
        expect(
          find.byType(NewProcessButton),
          findsOneWidget,
          reason: 'NewProcessButton should be visible when CA session data is already saved.',
        );

        // Tapping NewProcessButton
        await tester.tap(find.byType(NewProcessButton));
        // pumpAndSettle waits for CAProcess (and its _loadDTO / initState async work)
        // to settle before searching for children widgets.
        await tester.pumpAndSettle();

        // Verifying CAProcess displayed
        expect(
          find.byType(CAProcess),
          findsOneWidget,
          reason: 'CAProcess should be visible after tapping NewProcessButton.',
        );

        // ── TITLE SECTION ─────────────────────────────────────────────────────────────
        // Searching the TextField inside CATitleDeclaration
        Finder titleTextField = find.descendant(
          of: find.byType(CATitleDeclaration),
          matching: find.byType(TextField),
        );

        expect(
          titleTextField,
          findsOneWidget,
          reason: 'A TextField should exist inside CATitleDeclaration.',
        );

        // Entering a title
        await tester.enterText(titleTextField, testAnalysisTitle2);

        // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
        // Searching the TextField inside CAKeywordsDeclaration
        Finder keywordsTextField = find.descendant(
          of: find.byType(CAKeywordsDeclaration),
          matching: find.byType(TextField),
        );

        // Entering a keyword
        await tester.enterText(keywordsTextField, kw1);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Necessary for kw2 to be added
        await tester.tap(keywordsTextField);

        // Entering another keyword 
        await tester.enterText(keywordsTextField, kw2);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        
        // ── FORM SECTION ─────────────────────────────────────────────────────────────
        // Individual perspective testing values
        List<bool> checkboxValues = List.filled(7, true);
        // a1 to a7
        List<String> checkboxTextFieldValues = List.generate(7, (i) => "a${i+1}");
        String indivAnotherIssueStrValue = "a8";        

        // Group/teams perspective testing values
        String groupProblemsToSolveStrValue = "b1";
        List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"Yes","No"}];
        // b2 to b5
        List<String> segmentedButtonTextFieldValues = List.generate(4, (i) => "b${i+2}");
        
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
          // Putting all string values together, to retrieve them by index
          List<String> individualStringValues = [...checkboxTextFieldValues, indivAnotherIssueStrValue];
          List<String> groupStringValues = [groupProblemsToSolveStrValue, ...segmentedButtonTextFieldValues];

          await testPreview(tester, individualStringValues, segmentedButtonValues, groupStringValues);
  
          await tester.pump(const Duration(seconds: 3));
        }
      },
    );
  });
}