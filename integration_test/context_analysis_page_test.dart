import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:integration_test/integration_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_questions.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_checkbox_with_text_field.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_segmented_button_with_text_field.dart';
import 'package:journeyers/widgets/utility/sessions_dashboard_page.dart';


// ─── Test infrastructure ──────────────────────────────────────────────────────

class PathProviderPlatformRedirectForTesting extends PathProviderPlatform {

  // Test folder for I/O operations
  @override
  Future<String?> getApplicationSupportPath() async {
    // Get the standard system temp path
    final baseDir = Directory.systemTemp.path;
    
    // Define a sub-folder specifically for this test suite
    final testFolder = Directory('$baseDir/test_storage');

    // Ensure the directory exists before the app tries to write to it
    if (!await testFolder.exists()) {
      await testFolder.create(recursive: true);
    }

    return testFolder.path;
  }
}

/// Pumps the app in its standard form-visible state:
/// modal already acknowledged, no prior session data saved.
Future<void> pumpFormPage(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'isInformationModalAcknowledged': true,
    'wasSessionDataSaved': false,
  });
  await tester.pumpWidget(const MaterialApp(home: CAPage()));
  await tester.pumpAndSettle();
}

/// Expands the individual perspective ExpansionTile by tapping its title text.
Future<void> expandIndividualTile(WidgetTester tester) async {
  final q = CAFormQuestions();
  await tester.tap(find.text(q.level2TitleIndividual));
  await tester.pumpAndSettle();
}

/// Expands the group/teams perspective ExpansionTile by tapping its title text.
Future<void> expandGroupTile(WidgetTester tester) async {
  final q = CAFormQuestions();
  await tester.tap(find.text(q.level2TitleGroup));
  await tester.pumpAndSettle();
}


// ─── Main ─────────────────────────────────────────────────────────────────────

void main() async
{
  // "A subclass of [LiveTestWidgetsFlutterBinding] that reports tests results
  // on a channel to adapt them to native instrumentation test format."
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // "Platform-specific plugins should set this with their own platform-specific
  // class that extends [PathProviderPlatform] when they register themselves."
  PathProviderPlatform.instance = PathProviderPlatformRedirectForTesting();

  // Test bindings that are used by tests that mock message handlers for plugins
  // should mix in this binding to enable the use of the
  // [TestDefaultBinaryMessenger] APIs.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler
    (
      const MethodChannel('dev.journeyers/saf'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listFiles':
            // Returns a plausible non-empty list
            return <String>['file.csv'];
          case 'saveFile':
            // Returns a plausible file path for the save workflow test
            return '${Directory.systemTemp.path}/test_output.csv';
          default:
            return null;
        }
      },
    );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler
    (
      const MethodChannel('dev.journeyers/iossaf'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listFiles':
            return <String>['file.csv'];
          case 'saveFile':
            return '${Directory.systemTemp.path}/test_output.csv';
          default:
            return null;
        }
      },
    );

  tearDown(() async {
    du.currentListOfStoredFileNames = [];
  });
  // ─────────────────────────────────────────────────────────────────────────
  // Page-level tests
  // ─────────────────────────────────────────────────────────────────────────

  group
  (
    'Context analysis page-level tests: \n', 
    () 
    {         
      // 'Information modal:\n'
      // 'A newly installed app should display the information modal,\n'
      // 'before starting the first context analysis.'
      testWidgets
      (
        // skip: true,
        'Information modal: \n'
        'A newly installed app should display the information modal,\n'
        'before starting the first context analysis.', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Setting value for modal to appear,
            'isInformationModalAcknowledged': false,
            // and to have the context analysis page, without the dashboard.
            'wasSessionDataSaved': false
          });

          // Widget wrapped in a MaterialApp because the page uses Scaffold, 
          // showDialog (Navigator), and AppLocalizations
          await tester.pumpWidget(const MaterialApp(home: CAPage()));

          // getPreferences is async and calls setState. 
          // Need to pump and wait for the microtasks to finish.
          await tester.pumpAndSettle();
          // "Repeatedly calls pump with the given duration 
          // until there are no longer any frames scheduled."
          // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html

          // Verifying that the modal is present
          final modalTextFinder = find.byKey(const Key('information-modal'));
          expect(modalTextFinder, findsOneWidget);

          // Verifying the modal's behavior
          await tester.tap(modalTextFinder);
          await tester.pumpAndSettle();
          // Verifying that the modal is gone
          expect(modalTextFinder, findsNothing);

          // Verifying the dashboard absent
          final dashboardFinder = find.byType(SessionsDashboardPage);
          expect(dashboardFinder, findsNothing);

          // Verifying the presence of the context analysis form
          final caFormFinder = find.byType(CAProcess);
          expect(caFormFinder, findsOneWidget);
        }
      );

      // 'Information modal: \n'
      // 'Information modal is not displayed when already acknowledged.', 
      testWidgets
      (
        // skip: true, 
        'Information modal: \n'
        'Information modal is not displayed when already acknowledged', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // To not have the modal at startup
            'isInformationModalAcknowledged': true,
            // To have the context analysis page, without the dashboard
            'wasSessionDataSaved': false,
          });

          // Widget wrapped in a MaterialApp because the page uses Scaffold, 
          // showDialog (Navigator), and AppLocalizations
          await tester.pumpWidget(const MaterialApp(home: CAPage()));

          // getPreferences is async and calls setState. 
          // Need to pump and wait for the microtasks to finish.
          await tester.pumpAndSettle();

          // Verifying the modal is absent
          final modalTextFinder = find.byKey(const Key('information-modal'));
          expect(modalTextFinder, findsNothing);

          // Verifying the dashboard absent
          final dashboardFinder = find.byType(SessionsDashboardPage);
          expect(dashboardFinder, findsNothing);

          // Verifying the presence of the context analysis form
          final caFormFinder = find.byType(CAProcess);
          expect(caFormFinder, findsOneWidget);
        }
      );

      // 'No session data stored: \n'
      // 'When no session data is stored, the context analysis page should be displayed,\n'
      // 'without the dashboard.', 
      testWidgets
      ( 
        // skip: true,        
        'No session data stored: \n'
        'When no session data is stored, the context analysis page should be displayed,\n'
        'without the dashboard.', 
        (tester) async 
        {  
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({            
            'isInformationModalAcknowledged': true,
            'wasSessionDataSaved': false,
          });
          
          // Widget wrapped in a MaterialApp because the page uses Scaffold, 
          // showDialog (Navigator), and AppLocalizations
          await tester.pumpWidget(const MaterialApp(home: CAPage()));

          // getPreferences is async and calls setState. 
          // Need to pump and wait for the microtasks to finish.
          await tester.pumpAndSettle();

          // Testing that the context analysis page is present 
          // GlobalKeys are different objects, 
          // and are not compared by labels, even if with the same label.
          // final formWidget = find.byKey(GlobalKey(debugLabel:'context-analysis-process'));
          final caFormFinder = find.byType(CAProcess);
          expect(caFormFinder, findsOneWidget);

          // Verifying the dashboard absent
          final dashboardFinder = find.byType(SessionsDashboardPage);
          expect(dashboardFinder, findsNothing);          
        }
      );
    
      // 'Data stored: New context analysis button: \n'
      // 'The dashboard page should have a button to start a new context analysis.',
      testWidgets
      (
        // skip: true, 
        'Data stored: New context analysis button: \n'
        'The dashboard page should have a button to start a new context analysis.',
        (WidgetTester tester) async 
        { 
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            'isInformationModalAcknowledged': true, 
            'wasSessionDataSaved': true,
          });
          
          await tester.pumpWidget(const MaterialApp(home: CAPage()));

          // Waiting for async preferences and rebuild
          await tester.pumpAndSettle();

          // Verifying the new analysis button present
          final buttonWidget = find.byKey(const Key('analyses-new-session-button'));
          expect(buttonWidget, findsOneWidget); 

          // Verifying the dashboard present  
          final dashboardFinder = find.byType(SessionsDashboardPage);
          expect(dashboardFinder, findsOneWidget);  
        },
      );
    }
  );  


  // ─────────────────────────────────────────────────────────────────────────
  // Form: Structure
  // ─────────────────────────────────────────────────────────────────────────

  group
  (
    'Form: Structure\n',
    ()
    {
      // 'Both perspective expansion tiles are present'
      testWidgets
      (
        // skip: true,
        'Both perspective expansion tiles are present',
        (tester) async
        {
          await pumpFormPage(tester);

          // One tile for the individual perspective, one for the group perspective
          expect(find.byType(ExpansionTile), findsNWidgets(2));
        },
      );

      // 'Individual and group tiles carry the correct heading text'
      testWidgets
      (
        // skip: true,
        'Individual and group tiles carry the correct heading text',
        (tester) async
        {
          final q = CAFormQuestions();
          await pumpFormPage(tester);

          // TODO: using keys
          expect(find.text(q.level2TitleIndividual), findsOneWidget);
          expect(find.text(q.level2TitleGroup),      findsOneWidget);
        },
      );
    },
  );


  // ─────────────────────────────────────────────────────────────────────────
  // Form: Individual perspective
  // ─────────────────────────────────────────────────────────────────────────

  group
  (
    'Form: Individual perspective\n',
    ()
    {
      // 'Expanding the tile reveals all four level-3 section headings'
      testWidgets
      (
        // skip: true,
        'Expanding the tile reveals all four level-3 section headings',
        (tester) async
        {
          final q = CAFormQuestions();
          await pumpFormPage(tester);
          await expandIndividualTile(tester);

          expect(find.text(q.level3TitleBalanceIssue),   findsOneWidget);
          expect(find.text(q.level3TitleWorkplaceIssue), findsOneWidget);
          expect(find.text(q.level3TitleLegacyIssue),    findsOneWidget);
          expect(find.text(q.level3TitleAnotherIssue),   findsOneWidget);
        },
      );

      // 'Expanding the tile reveals the correct total number of checkbox items\n'
      // '(4 balance + 2 workplace + 1 legacy = 7)'
      testWidgets
      (
        // skip: true,
        'Expanding the tile reveals the correct total number of checkbox items\n'
        '(4 balance + 2 workplace + 1 legacy = 7)',
        (tester) async
        {
          await pumpFormPage(tester);
          await expandIndividualTile(tester);

          expect(find.byType(CheckboxWithTextField), findsNWidgets(7));
        },
      );

      // 'Balance issue: all four item labels are present after expansion',
      testWidgets
      (
        // skip: true,
        'Balance issue: all four item labels are present after expansion',
        (tester) async
        {
          final q = CAFormQuestions();
          await pumpFormPage(tester);
          await expandIndividualTile(tester);

          expect(find.text(q.level3TitleBalanceIssueItem1), findsOneWidget);
          expect(find.text(q.level3TitleBalanceIssueItem2), findsOneWidget);
          expect(find.text(q.level3TitleBalanceIssueItem3), findsOneWidget);
          expect(find.text(q.level3TitleBalanceIssueItem4), findsOneWidget);
        },
      );

      // 'Workplace issue: both item labels are present after expansion',
      testWidgets
      (
        // skip: true,
        'Workplace issue: both item labels are present after expansion',
        (tester) async
        {
          final q = CAFormQuestions();
          await pumpFormPage(tester);
          await expandIndividualTile(tester);

          expect(find.text(q.level3TitleWorkplaceIssueItem1), findsOneWidget);
          expect(find.text(q.level3TitleWorkplaceIssueItem2), findsOneWidget);
        },
      );

      // 'Balance issue: the first checkbox is unchecked on initial render',
      testWidgets
      (
        // skip: true,
        'Balance issue: the first checkbox is unchecked on initial render',
        (tester) async
        {
          await pumpFormPage(tester);
          await expandIndividualTile(tester);

          final firstCustomCheckbox = find.descendant(
            of:       find.byType(CheckboxWithTextField).first,
            matching: find.byType(Checkbox),
          );
          await tester.ensureVisible(firstCustomCheckbox);

          expect(tester.widget<Checkbox>(firstCustomCheckbox).value, isFalse);
        },
      );

      // 'Balancing studies and household life: \n'
      // 'the note text field accepts and retains input after checkbox unselection'
      testWidgets
      (
        // skip: true,
        'Balancing studies and household life: \n'
        'the note text field accepts and retains input after checkbox unselection',
        (tester) async
        {
          const testNote = 'Need more time to help at home';
          await pumpFormPage(tester);
          await expandIndividualTile(tester);

          final firstCustomCheckbox = find.byType(CheckboxWithTextField).first;
          await tester.ensureVisible(firstCustomCheckbox);

          // Checking the checkbox to reveal the note field
          await tester.tap(firstCustomCheckbox);
          await tester.pumpAndSettle();

          // Verifying the checkbox checked          
          // Returns false: 
          // expect(tester.widget<CheckboxWithTextField>(firstCustomCheckbox).checkboxIsChecked, isTrue);
          var firstCheckbox = find.descendant(of: firstCustomCheckbox, matching: find.byType(Checkbox));
          expect(tester.widget<Checkbox>(firstCheckbox).value, isTrue);
          
          // Adding note to text field
          var noteTextField = find.descendant(of: firstCustomCheckbox, matching: find.byType(TextField),
          );
          
          await tester.tap(noteTextField);
          await tester.enterText(noteTextField, testNote);
          await tester.pumpAndSettle();
          expect(find.text(testNote), findsOneWidget);

          // Unchecking the checkbox. The text field should be hidden.
          await tester.tap(firstCheckbox);
          await tester.pumpAndSettle();
          expect(tester.widget<Checkbox>(firstCheckbox).value, isFalse);

          // Checking that the text field is hidden
          expect(find.text(testNote), findsNothing);

          // Re-setting the selection
          await tester.tap(firstCheckbox);
          await tester.pumpAndSettle();

          // Verifying the text present
          noteTextField = find.descendant(of: firstCustomCheckbox, matching: find.byType(TextField),
          );
          await tester.ensureVisible(noteTextField);
          await tester.tap(noteTextField);
          await tester.enterText(noteTextField, testNote);
          await tester.pumpAndSettle();

          expect(find.text(testNote), findsOneWidget);
        },
      );  
    },
  );


  // ─────────────────────────────────────────────────────────────────────────
  // Form: Group/Teams perspective
  // ─────────────────────────────────────────────────────────────────────────

  group
  (
    'Form: Group/Teams perspective\n',
    ()
    {
      // 'Expanding the tile reveals all five level-3 section headings',
      testWidgets
      (
        // skip: true,
        'Expanding the tile reveals all five level-3 section headings',
        (tester) async
        {
          final q = CAFormQuestions();
          await pumpFormPage(tester);
          await expandGroupTile(tester);

          expect(find.text(q.level3TitleGroupsProblematics),   findsOneWidget);
          expect(find.text(q.level3TitleSameProblem),          findsOneWidget);
          expect(find.text(q.level3TitleHarmonyAtHome),        findsOneWidget);
          expect(find.text(q.level3TitleAppreciabilityAtWork), findsOneWidget);
          expect(find.text(q.level3TitleIncomeEarningAbility), findsOneWidget);
        },
      );

      // 'Expanding the tile reveals exactly four segmented-button widgets\n'
      // '(same problems / harmony at home / appreciability / earning ability)',
      testWidgets
      (
        // skip: true,
        'Expanding the tile reveals exactly four segmented-button widgets\n'
        '(same problems / harmony at home / appreciability / earning ability)',
        (tester) async
        {
          await pumpFormPage(tester);
          await expandGroupTile(tester);

          expect(find.byType(SegmentedButtonWithTextField), findsNWidgets(4));
        },
      );

      // 'Same problems: the note text field is hidden before a selection is made\n'
      // 'and appears after one is made'
      testWidgets
      (
        // skip: true,
        'Same problems: the note text field is hidden before a selection is made\n'
        'and appears after one is made',
        (tester) async
        {
          await pumpFormPage(tester);
          await expandGroupTile(tester);

          final firstCustomSegmentedButton =
              find.byType(SegmentedButtonWithTextField).first;
          await tester.ensureVisible(firstCustomSegmentedButton);

          // No TextField inside the segmented button widget before any selection
          expect(
            find.descendant(of: firstCustomSegmentedButton, matching: find.byType(TextField)),
            findsNothing,
          );

          // After a selection the note field should appear
          await tester.tap(
            find.descendant(of: firstCustomSegmentedButton, matching: find.text('Yes')),
          );
          await tester.pumpAndSettle();

          expect(
            find.descendant(of: firstCustomSegmentedButton, matching: find.byType(TextField)),
            findsOneWidget,
          );
        },
      );

      testWidgets
      (
        // skip: true,
        'Same problems: the note text field accepts and retains input after segmented button unselection',
        (tester) async
        {
          const testNote = 'Everyone is dealing with overtime stress';
          await pumpFormPage(tester);
          await expandGroupTile(tester);

          final firstCustomSegmentedButton =
              find.byType(SegmentedButtonWithTextField).first;
          await tester.ensureVisible(firstCustomSegmentedButton);

          // Making a selection to reveal the note field
          await tester.tap(
            find.descendant(of: firstCustomSegmentedButton, matching: find.text('Yes')),
          );
          await tester.pumpAndSettle();

          var noteTextField = find.descendant(of: firstCustomSegmentedButton, matching: find.byType(TextField));
          await tester.tap(noteTextField);
          await tester.enterText(noteTextField, testNote);
          await tester.pumpAndSettle();

          expect(find.text(testNote), findsOneWidget);

          // Removing the selection. The text field should be hidden.
          await tester.tap(
            find.descendant(of: firstCustomSegmentedButton, matching: find.text('Yes')),
          );
          await tester.pumpAndSettle();

          // Checking that the text field is hidden
          expect(find.text(testNote), findsNothing);

          // Re-setting the selection
          await tester.tap(
            find.descendant(of: firstCustomSegmentedButton, matching: find.text('Yes')),
          );
          await tester.pumpAndSettle();

          // Verifying the text present
          noteTextField = find.descendant(of: firstCustomSegmentedButton, matching: find.byType(TextField));
          await tester.tap(noteTextField);
          await tester.enterText(noteTextField, testNote);
          await tester.pumpAndSettle();

          expect(find.text(testNote), findsOneWidget);
        },
      );
    },
  );


  // ─────────────────────────────────────────────────────────────────────────
  // Form: Cross-section interactions
  // ─────────────────────────────────────────────────────────────────────────

  group
  (
    'Form: Cross-section interactions\n',
    ()
    {
      testWidgets
      (
        // skip: true,
        'Form state is preserved across tile collapse and re-expansion',
        (tester) async
        {
          await pumpFormPage(tester);
          await expandIndividualTile(tester);

          // Checking the first balance checkbox
          final firstCustomCheckbox = find.descendant(
            of:       find.byType(CheckboxWithTextField).first,
            matching: find.byType(Checkbox)
          );
          await tester.ensureVisible(firstCustomCheckbox);
          await tester.tap(firstCustomCheckbox);
          await tester.pumpAndSettle();
          expect(tester.widget<Checkbox>(firstCustomCheckbox).value, isTrue);

          // Collapsing the tile then re-expand it
          // maintainState: true keeps widget state alive between collapses
          final q = CAFormQuestions();
          await tester.tap(find.text(q.level2TitleIndividual), warnIfMissed: false);
          await tester.pumpAndSettle();
          await tester.tap(find.text(q.level2TitleIndividual), warnIfMissed: false);
          await tester.pumpAndSettle();

          // Checkbox should still be checked
          await tester.ensureVisible(firstCustomCheckbox);
          expect(tester.widget<Checkbox>(firstCustomCheckbox).value, isTrue);
        },
      );
    },
  );
}
