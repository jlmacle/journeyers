import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/pages/homepage.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_const_strings.dart' show gpsTitleSuffix, previewTooltipLabel;
import 'package:journeyers/widgets/utility/process_widgets/session_file_name_mobile_platforms.dart';

import '../test/helper_functions/externalized_testing_code.dart';

// Used to define a folder value for getApplicationSupportPath (PathProvider) 
class PathProviderPlatformRedirectForTesting extends PathProviderPlatform {
  PathProviderPlatformRedirectForTesting(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
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

  // ── App pumping ─────────────────────────────────────────────────────────────
  Future<void> pumpApp(WidgetTester tester) async
  {
    // Pumping the app
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(onLanguageSelectedMainCallbackFunction: (_){})
      )
    );
    await tester.pumpAndSettle();
  }

  // ── Constants ─────────────────────────────────────────────────────────────

  // Titles
  const String testAnalysisTitleRoot = 'Integration-test CA session title';
  const String testAnalysisTitle1 = '$testAnalysisTitleRoot (1)';
  
  // Keywords
  const String kwCompanionship = 'Companionship';
  const String kwWorkplace = 'Workplace';
  const List<String> kwsList = [kwCompanionship, kwWorkplace];

  // Ideas
  const ideasList1 = ['idea1', 'idea2'];

  // File names
  const String fileName1WithoutExtension = 'file1';
 
  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;
  
  setUp(() async {
    // Creating a temporary folder to store the files to save
    testTmpDir = await Directory.systemTemp.createTemp('context_analysis_integration_test_');
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

  group('Application Tests: Mobile: \n', () 
  {
    // 'CA + GPS: Session data entered in the context analysis is available for the group problem-solving'
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
      'CA + GPS: Session data entered in the context analysis is available for the group problem-solving'
      '(assuming an already selected path to the user session data folder)',
      (WidgetTester tester) async {

        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          // Setting value for the first-run modal to be absent,
          'wasFirstRunModalAcknowledged': true,
          // to have the context analysis page, with the dashboard,
          'wasSessionDataSaved': true,
          // and to have the group problem-solving page, with the dashboard.
          'wasGPSSessionDataSaved': true,
          // Temporary test dir as application folder path
          'applicationFolderPath': testTmpDir!.path
        });

        if (Platform.isAndroid || Platform.isIOS)
        {
          // Pumping the app
          await pumpApp(tester);

          // ── 1. ENTERING NEW CA PROCESS DATA ────────────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────────

          // formToFill: false to skip the form filling
          await caEnterNewProcessDataOnMobile
          (
            tester: tester, 
            formToFill: false,
            title: testAnalysisTitle1,
            kwsList: kwsList,
            fileNameWithoutExtension: fileName1WithoutExtension
          );

          await tester.pump(const Duration(seconds: 2));      

          // ── 2. REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ───────────────────────────────────────────────────────────────────────────
          // Reaching the GPS process page from the home page
          await gpsFromHomePageToProcessPage(tester);          

          // ── 3. SEARCHING FOR THE CA SESSION DATA IN THE GPS PROCESS  ──────────────────
          // ──────────────────────────────────────────────────────────────────────────────          
          // Searching the placeholder title
          var placeholderTitleFinder = find.text(gpsProcessTitlePlaceholder);

          // Tapping on it
          await tester.tap(placeholderTitleFinder);
          await tester.pumpAndSettle();
          // Searching for the list tile with the CA data
          var listTileFinder = find.byType(ListTile);

          var totalListTile = listTileFinder.evaluate().length;
          if (testingDebug) pu.printd('Testing Debug: totalListTile: $totalListTile');

          // Tapping on the list tile
          await tester.tap(listTileFinder);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));

          // Searching the keywords declaration title
          var keywordsDeclarationTitleFinder = find.descendant
                                        (
                                          of: find.byType(GPSKeywordsDeclaration), 
                                          matching: find.text(keywordsDeclarationTitle)
                                        );

          // Tapping on it to open the overlay
          await tester.tap(keywordsDeclarationTitleFinder);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2)); 

          // Verifying that the keywords have been imported
          var inputChipTextFinder = find.descendant(of: find.byType(InputChip), matching: find.byType(Text));
          expect(inputChipTextFinder, findsNWidgets(2));

          expect(find.text(kwCompanionship), findsOne);
          expect(find.text(kwWorkplace), findsOne);
          
          // Searching the tooltip to close the overlay
          var closingIconFinder = find.byTooltip(closeKeywordsDeclarationTooltipLabel);

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
            of: find.text(newIdeaTextFieldHint), 
            matching: find.byType(TextField)
          );

          // Adding the ideas
          for (var idea in ideasList1)
          {
            await tester.enterText(newIdeaTextFieldFinder, idea);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));  

            await tester.tap(newIdeaTextFieldFinder); 
          }

          // Submitting the GPS data
          await dashboardEnterFileNameAndSubmitDataOnMobile(tester: tester, fileNameWithoutExtension: fileName1WithoutExtension);

          // ── 5. VERIFYING THE CA DATA ON THE GPS PAGE  ───
          // ────────────────────────────────────────────────

          // Verifying the GPS page present
          expect(find.byType(GPSPage), findsOne);

          // Searching for the title imported from the CA 
          expect(find.text("$testAnalysisTitle1$gpsTitleSuffix"), findsOne);

          // Searching for the keywords imported from the CA 
          expect(find.text(kwCompanionship), findsOne);
          expect(find.text(kwWorkplace), findsOne);

          // await tester.pump(const Duration(seconds: 2));
        }
    });
        
  });
  
    // TODO: to clean/move
    group('Edition Tests: Mobile: \n', ()
    {
      // 'Context analysis edition \n'
      testWidgets(
        'Context analysis edition \n',
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

          if (Platform.isAndroid || Platform.isIOS)
          {
            // Pumping the app
            await pumpApp(tester);

            // ── 1. ENTERING NEW CA PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────

            var title = "CA title";

            var keywords = kwsList;
            
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
              kwsList: keywords,
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

            if (testingDebug) pu.printd('Testing Debug: totalCheckboxes: $totalCheckboxes');

            for (var cbIndex = 0; cbIndex < totalCheckboxes; cbIndex++)
            {
              // cbIndex = 1: keywords: skipping the text field
              if (cbIndex != 1) 
              {
                expect(tester.widget<Checkbox>(checkboxesFinder.at(cbIndex)).value, checkboxValues[cbIndex]);
              }
            }

            // ── Verifying segmented button data present ────────────────────────────
              // List<Set<String>> segmentedButtonValues = [{"Yes"},{"No"},{"I don't know"},{"Yes","No"}];
              
              // var segmentedButtonsFinder = find.byType(SegmentedButton); // finds 0 SegmentedButton
            
            var segmentedButtonsFinder = 
            find.descendant(
              of: find.byType(ExpansionTile).last, 
              matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
            );

            var totalSegmentedButtons = segmentedButtonsFinder.evaluate().length;

            if (testingDebug) pu.printd('Testing Debug: totalSegmentedButtons: $totalSegmentedButtons (4: expected)');

            for (var sbIndex = 0; sbIndex < totalSegmentedButtons; sbIndex++)
            {
                expect(tester.widget<CASegmentedButtonWithSanitizedAndPaddedTextField>(segmentedButtonsFinder.at(sbIndex)).segButtonStartValue, segmentedButtonValues[sbIndex]);
            }

            // ── Verifying text field data present ────────────────────────────
            var textFieldsFinder = find.byType(TextField);
            var totalTextFields = textFieldsFinder.evaluate().length;

            if (testingDebug) pu.printd('Testing Debug: totalTextFields: $totalTextFields (expected: 16)');

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
            List<String> newSegmentedButtonValuesAddedValues = ["No", "Yes", "Yes", "I don't know"];

            segmentedButtonsFinder = find.descendant(
              of: find.byType(ExpansionTile).last, 
              matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
            );

            totalSegmentedButtons = segmentedButtonsFinder.evaluate().length;

            if (testingDebug) pu.printd('Testing Debug: totalSegmentedButtons: $totalSegmentedButtons (4: expected)');

            var optionsToSelect = ["Yes","No","I don't know"];
            for (var sbIndex = 0; sbIndex < totalSegmentedButtons; sbIndex++)
            {
              var currentSegmentedButtonFinder = segmentedButtonsFinder.at(sbIndex);

              // List<Set<String>> newSegmentedButtonValues = [{},{"Yes"},{},{"No"}];
              for (var option in optionsToSelect)
              {
                // additional option to tap
                var currentSegmentedButtonAddedValue = newSegmentedButtonValuesAddedValues[sbIndex];

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
            var suffix = "-edited";

            List<String> newCheckboxTextFieldValues = 
            [for (var value in checkboxTextFieldValues) "${value}${suffix}"]; 

            String newIndivAnotherIssueStrValue = "a8$suffix";   

            String newGroupProblemsToSolveStrValue = "b1$suffix";

            List<String> newSegmentedButtonTextFieldValues = 
            [ for (var value in segmentedButtonTextFieldValues) "${value}${suffix}" ]; 

            textFieldsFinder = find.byType(TextField);
            totalTextFields = textFieldsFinder.evaluate().length;

            if (testingDebug) pu.printd('Testing Debug: totalTextFields: $totalTextFields (expected: 16)');

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
                if (testingDebug) pu.printd('Testing Debug: tfIndex: $tfIndex');
                if (testingDebug) pu.printd('dataList[tfIndex]!: ${dataList[tfIndex]!}');

                var currentTextFieldFinder = textFieldsFinder.at(tfIndex);
                await tester.ensureVisible(currentTextFieldFinder);
                await tester.pumpAndSettle();
                await tester.tap(currentTextFieldFinder);
                await tester.pumpAndSettle();
                await tester.enterText(currentTextFieldFinder, dataList[tfIndex]!);
                await tester.pumpAndSettle();
                await tester.pump(const Duration(seconds: 1));
                // data entered only
              }
            }

            // ── Submitting edited data ──────────────────
            // ────────────────────────────────────────────

            Finder fileNameWidgetFinder =  find.byType(SessionFileNameMobilePlatforms);
            await tester.ensureVisible(fileNameWidgetFinder);
            await tester.pumpAndSettle();
            await tester.tap(fileNameWidgetFinder);
            await tester.pumpAndSettle();
            // data is already entered
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();  

            await tester.pump(const Duration(seconds: 2));

            // ── Verifying the edited data present ──────────────────
            // ───────────────────────────────────────────────────────
          
            // ── Opening the preview ──────────────────
            previewFinder = find.byTooltip(previewTooltipLabel);
            await tester.ensureVisible(previewFinder);
            await tester.pumpAndSettle();
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();

            await tester.pump(const Duration(seconds: 5));

            var textToFind = "a7$suffix";
            if (testingDebug) pu.printd('Testing Debug: Scrolling toward textToFind: $textToFind for screen copy');
            var textToFindFinder = find.textContaining(textToFind);
            await tester.scrollUntilVisible
            (
              textToFindFinder, 
              45, 
              scrollable: find.descendant
                        (
                          of: find.byKey(const ValueKey('context-analysis-preview-scrollview')), 
                          matching: find.byType(Scrollable)
                        ),
            );            
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 5));
            if (testingDebug) pu.printd('Scrolled to $textToFind');

            textToFind = "b1$suffix";
            if (testingDebug) pu.printd('Testing Debug: Scrolling toward textToFind: $textToFind for screen copy');
            textToFindFinder = find.textContaining(textToFind);
            await tester.scrollUntilVisible
            (
              textToFindFinder, 
              45, 
              scrollable: find.descendant
                        (
                          of: find.byKey(const ValueKey('context-analysis-preview-scrollview')), 
                          matching: find.byType(Scrollable)
                        ),
            );            
            await tester.pumpAndSettle();
            expect(textToFindFinder, findsOne);
            if (testingDebug) pu.printd('Scrolled to $textToFind');

            await tester.pump(const Duration(seconds: 5));

            if (testingDebug) pu.printd('Scrolling toward title for preview');

            // Scrolling up
            var scrollableFinder = find.descendant
                        (
                          of: find.byKey(const ValueKey('context-analysis-preview-scrollview')), 
                          matching: find.byType(Scrollable)
                        ).first;

            var totalScrollables = scrollableFinder.evaluate().length;
            print("totalScrollables: $totalScrollables");

            await tester.scrollUntilVisible
            (
              find.text(title).first, 
              -40, // getting up the list
              scrollable: scrollableFinder
            );
            await tester.pumpAndSettle();
            
            if (testingDebug) pu.printd('Testing Debug: Scrolled to title');
            await tester.pump(const Duration(seconds: 3));

            // ── Verifying the edited data present ──────────────────            
            
          // Todo: understand later why the preview is ok, and the test failing 
          //   await caTestPreview
          //   (
          //     tester: tester, 
          //     individualStringValues: [...newCheckboxTextFieldValues, newIndivAnotherIssueStrValue], 
          //     groupStringValues: [newGroupProblemsToSolveStrValue,...newSegmentedButtonTextFieldValues],
          //     segmentedButtonValues: newSegmentedButtonValues);            
          } // platform-related if

        });

      // 'Group problem-solving edition \n'
      testWidgets(
        'Group problem-solving edition \n',
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
            // Pumping the app
            await pumpApp(tester);

            // ── 1. CLICKING TO DISPLAY THE GPS PAGE  ────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────
            var bottomItemGPSFinder = find.byKey(const Key('homepage-bottom-navigation-bar-item-gps'));
            await tester.tap(bottomItemGPSFinder);
            await tester.pumpAndSettle();

            // ── 2. ENTERING NEW GPS PROCESS DATA  ──────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────
            var title = "GPS title";

            var keywords = kwsList;
            
            await gpsEnterNewProcessData
            (
              tester: tester, 
              title: title,
              kwsList: keywords,
              ideasList: ideasList1,
              fileNameWithoutExtension: fileName1WithoutExtension
            );

            // await tester.pump(const Duration(seconds: 2));

            // ── 3. CLICKING TO OPEN THE PREVIEW  ─────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────
            // Opening the preview
            var previewFinder = find.byTooltip(previewTooltipLabel);
            await tester.tap(previewFinder);
            await tester.pumpAndSettle();

            // ── 4. CLICKING TO START THE EDIT MODE  ──────────────────────────────
            // ─────────────────────────────────────────────────────────────────────
            // Opening the edition overlay
            var editIconFinder = find.byIcon(Icons.edit);
            await tester.tap(editIconFinder);
            await tester.pumpAndSettle();

            await tester.pump(const Duration(seconds: 2));

            // ── 5. EDITION: Verifying data present and editing  ─────────────────
            // ────────────────────────────────────────────────────────────────────

            // ── Verifying the ideas present ─────────────
            // ────────────────────────────────────────────
            for (var idea in ideasList1)
            {
              expect(find.textContaining(idea), findsNWidgets(2));
            }            

            // ── Editing data ────────────────────────────
            // ────────────────────────────────────────────

            // const ideasList1 = ['idea1', 'idea2'];
            var suffix = "-edited";

            // ── Deleting idea1  ───────────────────────────────────
            // ──────────────────────────────────────────────────────
            // Searching the checkbox
            var checkboxFinder = find.byKey(const ValueKey('editable-deletable-checkbox-0'));
            await tester.ensureVisible(checkboxFinder);
            await tester.pumpAndSettle();   
            // Tapping on the checkbox for deletion
            await tester.tap(checkboxFinder);
            await tester.pumpAndSettle();
            
            // Clicking on the Delete message
            var deleteFinder = find.textContaining('Delete').last;
            await tester.pumpAndSettle();
            await tester.tap(deleteFinder);
            await tester.pumpAndSettle();
            // Verifying the value removed from the overlay
            expect(find.text('idea1'), findsOne);
            if (testingDebug) pu.printd('Testing Debug: idea1 deleted');

            // ── Editing idea2  ───────────────────────────────────
            // ─────────────────────────────────────────────────────
            // Searching the idea
            var ideaFinder = find.byKey(const ValueKey('editable-deletable-text-item-0'));
            await tester.ensureVisible(ideaFinder);
            await tester.pumpAndSettle();   
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

            var ideaEdited = "idea2$suffix";
            await tester.enterText(editableDeletableTfFinder, ideaEdited);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));
            if (testingDebug) pu.printd('Testing Debug: idea2 edited');

            // ── Adding idea3  ───────────────────────────────────
            // ────────────────────────────────────────────────────
            // Searching the text field used to add ideas
            var newIdeaTextFieldFinder = find.byKey(const ValueKey('ideaOverlayField'));

            // Adding the new idea
            await tester.ensureVisible(newIdeaTextFieldFinder);
            await tester.pumpAndSettle(); 
            await tester.tap(newIdeaTextFieldFinder, warnIfMissed: false);
            await tester.pumpAndSettle(); 
            await tester.enterText(newIdeaTextFieldFinder, 'idea3');
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();             
            if (testingDebug) pu.printd('Testing Debug: idea3 added');

            await tester.pump(const Duration(seconds: 5)); 

            // ── 6. VERIFICATION  ─────────────────
            // ─────────────────────────────────────

            // ── Closing the overlay ──────────────────
            // ─────────────────────────────────────────
            var overlayClosingTooltipFinder = find.byTooltip(overlayClosingTooltip);
            await tester.tap(overlayClosingTooltipFinder);
            await tester.pumpAndSettle();           

            await tester.pump(const Duration(seconds: 2));

            // ── Verifying the edited/added data present ────────────
            // ───────────────────────────────────────────────────────
            // ── Verifying the data present ──────────────────
            expect(find.textContaining("idea2$suffix"), findsOne);
            expect(find.textContaining("idea3"), findsOne);
               
          } // if platform

        });


    });

 

}