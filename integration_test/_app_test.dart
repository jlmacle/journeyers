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
import 'package:journeyers/widgets/utility/lists/list_dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_or_loading_page_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/4_list_of_lists_item.dart';
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
    // 'Session data entered in the context analysis is available for the group problem-solving'
    // '(assuming an already selected path to the user session data folder)',
    testWidgets(
      'Session data entered in the context analysis is available for the group problem-solving'
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
          await caEnterNewProcessData
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

  // TODO: to move in the GPS integration tests
  group('Participants Tests: \n', () 
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
    group('Participants Lists Options Page: \n', () 
    {
      // 'Participants Lists Options Page: correct title'
      testWidgets('Participants Lists Options Page: correct title', 
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

        // Pumping the app
        await pumpApp(tester);

        // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
        // ────────────────────────────────────────────────────────────────────────
        // Reaching the GPS process page from the home page
        await gpsFromHomePageToProcessPage(tester);

        // ── LOADING PARTICIPANTS LISTS OPTIONS PAGE   ──────────────
        // ───────────────────────────────────────────────────────────
        await gpsFromProcessPageToparticipantsListsOptionsPage(tester);

        // Verifying the correct title present
        var textFinder = find.text('Participants lists');
        expect(textFinder, findsOne);

        });            
    
      // 'Participants Lists Options Page: correct subtitle'
      testWidgets('Participants Lists Options Page: correct subtitle', 
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

        // Pumping the app
        await pumpApp(tester);

        // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
        // ────────────────────────────────────────────────────────────────────────
        // Reaching the GPS process page from the home page
        await gpsFromHomePageToProcessPage(tester);

        // ── LOADING PARTICIPANTS LISTS OPTIONS PAGE   ──────────────
        // ───────────────────────────────────────────────────────────
        await gpsFromProcessPageToparticipantsListsOptionsPage(tester);

        // Verifying the correct subtitle present
        var textFinder = find.text('What would you like to do?');
        expect(textFinder, findsOne);

        });            
    
      // 'Participants Lists Options Page: correct option 1 label'
      testWidgets('Participants Lists Options Page: correct option 1 label', 
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

        // Pumping the app
        await pumpApp(tester);

        // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
        // ────────────────────────────────────────────────────────────────────────
        // Reaching the GPS process page from the home page
        await gpsFromHomePageToProcessPage(tester);

        // ── LOADING PARTICIPANTS LISTS OPTIONS PAGE   ──────────────
        // ───────────────────────────────────────────────────────────
        await gpsFromProcessPageToparticipantsListsOptionsPage(tester);

        // Verifying the correct option 1 label
        var textFinder = find.text('To load the list\nof previous groups?');
        expect(textFinder, findsOne);

        });            
    
      // 'Participants Lists Options Page: correct option 2 label'
      testWidgets('Participants Lists Options Page: correct option 2 label', 
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

        // Pumping the app
        await pumpApp(tester);

        // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
        // ────────────────────────────────────────────────────────────────────────
        // Reaching the GPS process page from the home page
        await gpsFromHomePageToProcessPage(tester);

        // ── LOADING PARTICIPANTS LISTS OPTIONS PAGE   ──────────────
        // ───────────────────────────────────────────────────────────
        await gpsFromProcessPageToparticipantsListsOptionsPage(tester);

        // Verifying the correct option 2 label
        var textFinder = find.text('To add a new group?');
        expect(textFinder, findsOne);

        });            
    
    });

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
              // to have the context analysis page, with the dashboard,
              'wasSessionDataSaved': true,
              // and to have the group problem-solving page, with the dashboard.
              'wasGPSSessionDataSaved': true,
              // Temporary test dir as application folder path
              'applicationFolderPath': testTmpDir!.path
            });

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names1,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // ── ADDING MORE PARTICIPANTS TO SAVE UNDER THE SAME LIST NAME ────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewListPage(tester);
            
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and ATTEMPTING TO SAVE THE LIST  ──────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewListPage(tester);
            
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
            }

            // Verifying the names present
            for (var name in names1)
            {
              expect(find.text(name), findsOne);    
            }      

            await tester.pump(const Duration(seconds: 5));

            
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names1,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // ── ADDING THE SAME PARTICIPANTS TO SAVE UNDER ANOTHER LIST NAME ────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewListPage(tester);
            
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
            }

            // Verifying the names present
            for (var name in names1)
            {
              expect(find.text(name), findsOne);    
            }      

            await tester.pump(const Duration(seconds: 5));

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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── ADDING PARTICIPANTS, KEYWORDS and SAVING THE LIST  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {listLabel1:{"names":names1,"keywords":[]}},            
            ];
            await gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded(tester: tester, listDataMapsList: listDataMapsList);      
        
            // ── ADDING THE SAME PARTICIPANTS TO SAVE UNDER ANOTHER LIST NAME ────────────────────────────────
            // ─────────────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewListPage(tester);
            
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

            await tester.pump(const Duration(seconds: 5));

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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

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

                // Pumping the app
                await pumpApp(tester);

                // Reaching the GPS process page from the home page
                await gpsFromHomePageToProcessPage(tester);

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

                // Pumping the app
                await pumpApp(tester);

                // Reaching the GPS process page from the home page
                await gpsFromHomePageToProcessPage(tester);

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
                // to have the context analysis page, with the dashboard,
                'wasSessionDataSaved': true,
                // and to have the group problem-solving page, with the dashboard.
                'wasGPSSessionDataSaved': true,
                // Temporary test dir as application folder path
                'applicationFolderPath': testTmpDir!.path
              });

              // Pumping the app
              await pumpApp(tester);

              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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
        // 'Participants names can be edited'
        testWidgets('Participants names can be edited', 
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── ADDING A PARTICIPANT ──────────────────────────────────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewListPage(tester);

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
        
        // 'Participants names can be deleted'
        testWidgets('Participants names can be deleted', 
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── ADDING A PARTICIPANT ──────────────────────────────────────────────────────────────
            // ──────────────────────────────────────────────────────────────────────────────────────
            // Loading the new list page from the GPS process page
            await gpsFromProcessPageToNewListPage(tester);

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

          // Pumping the app
          await pumpApp(tester);

          // Reaching the GPS process page from the home page
          await gpsFromHomePageToProcessPage(tester);

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
          await tester.pump(const Duration(seconds: 5));

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

          await tester.pump(const Duration(seconds: 2));

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
        // 'Empty dashboard: button toward adding a new list'
        testWidgets('Empty dashboard: button toward adding a new list', 
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

          // Pumping the app
          await pumpApp(tester);

          // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────
          // Reaching the GPS process page from the home page
          await gpsFromHomePageToProcessPage(tester);

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
          await tester.pump(const Duration(seconds: 5));

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

          // Verifying the list items absent
          expect(find.byType(ListOfListsItem), findsNothing);

          // Verifying the new list button present
          var newListButtonFinder = find.text(newListButton);
          await tester.tap(newListButtonFinder);
          await tester.pumpAndSettle();

          // Verifying the New List Page present
          expect (find.text(newListAppBarTitle), findsOne);
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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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
              var deleteIconFinder = find.byTooltip(deleteTooltipLabel);

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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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
              var sortByTitleFinder = find.textContaining(sortByTitleLabel);
              await tester.tap(sortByTitleFinder);
              await tester.pumpAndSettle();
              await tester.pump(const Duration(seconds: 2));

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
              await tester.pump(const Duration(seconds: 2));

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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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

              await tester.pump(const Duration(seconds: 2));

            });      
        
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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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
              var newLabelTextFieldFinder = find.byKey(const ValueKey('listEditField'));
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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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
              var listEditTextFieldFinder = find.byKey(const ValueKey('listEditField'));
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
              await tester.pump(const Duration(seconds: 5));  
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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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
              await tester.pump(const Duration(seconds: 5));  
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

              // Pumping the app
              await pumpApp(tester);

              // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
              // ────────────────────────────────────────────────────────────────────────
              // Reaching the GPS process page from the home page
              await gpsFromHomePageToProcessPage(tester);

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

  group('Ideas Tests: \n', () 
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── CLICKING ON THE IDEAS LIST TITLE  ───────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            var ideasListTitleFinder = find.text(ideasListTitle);
            await tester.tap(ideasListTitleFinder);
            await tester.pumpAndSettle();

            // ── OVERLAY  ───────────────────────────────────
            // ───────────────────────────────────────────────
            // Verifying the overlay present
            expect(find.byKey(const ValueKey('ideaOverlayField')), findsOne);
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

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
            await tester.pump(const Duration(seconds: 1));  

            // ── OVERLAY  ───────────────────────────────────
            // ───────────────────────────────────────────────
            // Tapping on the idea
            var ideaFinder = find.byKey(const ValueKey('idea-0'));
            await tester.tap(ideaFinder);
            await tester.pumpAndSettle();

            // Verifying the overlay present
            expect(find.byKey(const ValueKey('ideaOverlayField')), findsOne);

            await tester.pump(const Duration(seconds: 1)); 
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

            // ── REACHING THE OVERLAY  ──────────────────────────────────────
            // ───────────────────────────────────────────────────────────────
            await gpsFromProcessPageToIdeasOverlay(tester);

            // ── ADDING AN IDEA  ──────────────────────────────────────
            // ─────────────────────────────────────────────────────────
            // Searching the text field used to add ideas
            var newIdeaTextFieldFinder = find.byKey(const ValueKey('ideaOverlayField'));
            // Adding the idea
            await tester.ensureVisible(newIdeaTextFieldFinder);
            await tester.tap(newIdeaTextFieldFinder);
            await tester.pumpAndSettle(); 
            await tester.enterText(newIdeaTextFieldFinder, "An idea");
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));  

            // ── OVERLAY  ───────────────────────────────────
            // ───────────────────────────────────────────────
            // Searching the idea
            var ideaFinder = find.byKey(const ValueKey('idea-0'));
            await tester.ensureVisible(ideaFinder);
            await tester.pumpAndSettle();   
            // Verifying the idea present
            expect(ideaFinder, findsOne);

            await tester.pump(const Duration(seconds: 5)); 
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

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
            await tester.pump(const Duration(seconds: 1));

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

            await tester.pump(const Duration(seconds: 2)); 
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

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

            await tester.pump(const Duration(seconds: 2)); 
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

            // Pumping the app
            await pumpApp(tester);

            // ── REACHING THE GPS PROCESS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────
            // Reaching the GPS process page from the home page
            await gpsFromHomePageToProcessPage(tester);

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

            await tester.pump(const Duration(seconds: 2)); 
          });
      
      });
    });
    });

    
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

            await caEnterNewProcessData
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