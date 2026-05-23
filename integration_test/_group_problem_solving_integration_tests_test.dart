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
import 'package:journeyers/widgets/utility/dashboard_const_strings.dart';

import '../test/helper_functions/externalized_testing_code.dart';

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

  // Keeping the app in portrait up mode 
  if (Platform.isAndroid || Platform.isIOS)
  {
    await SystemChrome.setPreferredOrientations
    ([
      DeviceOrientation.portraitUp,   // Normal upright portrait
    ]);
  }

  // ── Constants ─────────────────────────────────────────────────────────────

  // Test title texts
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

  tearDown(() async {
    if (testTmpDir!.existsSync()) {
      // Deleting the temporary folder created to store the saved files
      await testTmpDir!.delete(recursive: true);
    }
  });

  // ── Test cases ─────────────────────────────────────────────────────────────

  // 'Group Problem-Solving Integration Tests: Mobile: \n'
  group('Group Problem-Solving Integration Tests: Mobile: \n', () 
  {
    group('Preview Tests: Mobile: \n', () 
    {
      // 'Session data entered is found on the preview '
      // '(assuming an already selected path to the user session data folder)',
      testWidgets(
        'Session data entered is found on the preview '
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
            // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html
            await tester.pumpWidget(buildTestableGPSPage());
            await tester.pumpAndSettle();

            await tester.pump(const Duration(seconds: 3));

            const solutionsList = ['solution'];

            // ── 1. ENTERING NEW GPS PROCESS DATA ────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────

            await enterNewGPSProcessData
            (
              tester: tester, 
              title: testGPSTitle1,
              kwsList: kwsList,
              solutionsList: solutionsList,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 5));

            // ── 2. SEARCHING FOR THE METADATA ON THE DASHBOARD  ────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────
            // Searching for the title and keywords
            await searchTitleAndKeywords(title: testGPSTitle1, kws: kwsList, titleSuffix: gpsTitleSuffix);

            // ── 3. TESTING THE PREVIEW ─────────────────────────────────────────────────────────────
            // ───────────────────────────────────────────────────────────────────────────────────────
            await tester.pump(const Duration(seconds: 2));
            await testGPSPreview(tester: tester, title: testGPSTitle1, solutionsList: solutionsList);

            // await tester.pump(const Duration(seconds: 2));

          }
        }
      );

    });
});
}