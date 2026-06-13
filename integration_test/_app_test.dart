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
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/pages/homepage.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_const_strings.dart' show gpsTitleSuffix;
import 'package:journeyers/widgets/utility/lists/list_process_loading_const_strings.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/4_list_of_lists_item.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/list_dashboard_const_strings.dart';

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
  // https://api.flutter.dev/flutter/flutter_test/tearDown.html
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
          await enterNewCAProcessData
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
          await gpsProcessPageFromHomePage(tester);          

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
          var newSolutionTextFieldFinder = find.ancestor
          (
            of: find.text(newIdeaTextFieldHint), 
            matching: find.byType(TextField)
          );

          // Adding the ideas
          for (var idea in ideasList1)
          {
            await tester.enterText(newSolutionTextFieldFinder, idea);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));  

            await tester.tap(newSolutionTextFieldFinder); 
          }

          // Submitting the GPS data
          await enterFileNameAndSubmitDataOnMobile(tester: tester, fileNameWithoutExtension: fileName1WithoutExtension);

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

  group('Participants Tests: \n', () 
  {
    var name1 = "Bob";
    var name2 = "Alice";
    var name3 = "Ben";
    var name4 = "Jane";
    List<String> names1 = [name1, name2];
    List<String> names2 = [name2, name4];
    List<String> names3 = [name1, name3];
    var list1 = "List1";
    var list2 = "List2";
    var list3 = "List3";
    var listLabelsSorted = [list1, list2, list3];
    var keywords1 = [kwCompanionship];
    var keywords2 = [kwWorkplace];
    var titlesCompanionship = [list1];
    var titlesWorkplace = [list2, list3];

    group('Participants Loading: \n', () 
    {
      // "Participants can be added, saved in a list, and the participants' names are loaded in the GPS process page"
      testWidgets("Participants can be added, saved in a list, and the participants' names are loaded in the GPS process page", 
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
            await gpsProcessPageFromHomePage(tester);

            // ── CLICKING TO DISPLAY THE PARTICIPANTS PAGE  ──────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────
            // Adding the names
            await addParticipantsFromGPSprocessPage(tester, names1, keywords1);   

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
            await tester.enterText(listNameSavingTextFieldFinder, list1);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();

            // Verifying the names on the GPS process

            // Verifying the GPS process page present
            expect(find.text(checkListTitle), findsOne);

            // Verifying the names present
            expect(find.text(name1), findsOne);    
            expect(find.text(name2), findsOne);  
          });
    
      // Had a multi-list issue at manual testing time
      // "Multi-list: Participants can be added, saved in a list, and the participants' names are loaded in the GPS process page"
      testWidgets("Multi-list: Participants can be added, saved in a list, and the participants' names are loaded in the GPS process page", 
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
          await gpsProcessPageFromHomePage(tester);

          // ── ADDING SEVERAL LISTS OF PARTICIPANTS   ──────────────────────────────────
          // ────────────────────────────────────────────────────────────────────────────
          List< Map<String,Map<String, dynamic>> > listDataMapsList =
          [
            {list1:{"names":names1,"keywords":[]}},
            {list2:{"names":names2,"keywords":[]}},
          ];
          await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);
        });

      // 'Participants can be loaded from an existing list'
      testWidgets('Participants can be loaded from an existing list', 
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
        await gpsProcessPageFromHomePage(tester);

        // ── ADDING PARTICIPANTS   ──────────────────────────────────
        // ───────────────────────────────────────────────────────────
        List< Map<String,Map<String, dynamic>> > listDataMapsList =
        [
          {list1:{"names":names1,"keywords":[]}},
        ];
        await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);
      
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
        var optionsPageFinder = find.text(optionsIntroductionLabel);
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

        // Verifying the names on the GPS process

        // Verifying the GPS process present
        expect(find.text(checkListTitle), findsOne);

        // Verifying the names present
        for (var name in names1)
        {
          expect(find.text(name), findsOne);    
        }  
    });  
    });

    group('Participants List Saving: \n', () 
    {
      // 'Participants lists names must be unique
      testWidgets('Participants lists names must be unique', 
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
        await gpsProcessPageFromHomePage(tester);

        // ── ADDING PARTICIPANTS   ──────────────────────────────────
        // ───────────────────────────────────────────────────────────
        List< Map<String,Map<String, dynamic>> > listDataMapsList =
        [
          {list1:{"names":names1,"keywords":[]}},            
        ];
        await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);      
    
        // ── ADDING MORE PARTICIPANTS TO SAVE UNDER THE SAME LIST NAME ────────────────────────────────
        // ─────────────────────────────────────────────────────────────────────────────────────────────
        // Loading the new list page from the GPS process page
        await newListPageFromGPSprocessPage(tester);
        
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
        await tester.enterText(listNameSavingTextFieldFinder, list1);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Searching for the error message
        var listAlreadySavedErrorFinder = find.textContaining(listAlreadySavedErrorEndPart);
        expect(listAlreadySavedErrorFinder, findsOne);

        // Verifying transition to GPS process page absent
        expect(find.text(checkListTitle), findsNothing);
      });            
    
      // 'List content must be unique'
      testWidgets('List content must be unique', 
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
        await gpsProcessPageFromHomePage(tester);

        // ── ADDING PARTICIPANTS   ──────────────────────────────────
        // ───────────────────────────────────────────────────────────
        List< Map<String,Map<String, dynamic>> > listDataMapsList =
        [
          {list1:{"names":names1,"keywords":[]}},            
        ];
        await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);      
    
        // ── ADDING THE SAME PARTICIPANTS TO SAVE UNDER ANOTHER LIST NAME ────────────────────────────────
        // ─────────────────────────────────────────────────────────────────────────────────────────────
        // Loading the new list page from the GPS process page
        await newListPageFromGPSprocessPage(tester);
        
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
    
      // 'List label must be non empty'
      testWidgets('List label must be non empty', 
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
        await gpsProcessPageFromHomePage(tester);

        // ── ADDING PARTICIPANTS ──────────────────────────────────────────────────────────────────────
        // ─────────────────────────────────────────────────────────────────────────────────────────────
        // Loading the new list page from the GPS process page
        await newListPageFromGPSprocessPage(tester);
        
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
    
    }); 

     group('Participants Lists: \n', () 
    {
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
            await gpsProcessPageFromHomePage(tester);

            // ── ADDING A LIST OF PARTICIPANTS   ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {list1:{"names":names1,"keywords":[]}},
            ];
            await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);

            // ── REACHING THE LISTS PAGE   ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────
            await listLoadingDashboardFromGPSprocessPage(tester);

            // ── TESTING THE DELETION ────────────────────────────────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────────────            
            // Searching for the tooltip 
            var deleteIconFinder = find.byTooltip(deleteTooltipLabel);

            // Tapping the icon
            await tester.tap(deleteIconFinder);
            await tester.pumpAndSettle();

            // Verifying the list item absent
            var sessionListItemFinder = await getSessionListItemFinderByTitle(tester: tester, title: list1);
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
            await gpsProcessPageFromHomePage(tester);

            // ── ADDING 3 LISTS OF PARTICIPANTS   ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {list1:{"names":names1,"keywords":[]}},
              {list2:{"names":names2,"keywords":[]}},
              {list3:{"names":names3,"keywords":[]}},
            ];
            await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);

            // ── REACHING THE LISTS PAGE   ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────
            await listLoadingDashboardFromGPSprocessPage(tester);

            // ── SEARCHING FOR THE ITEMS with listName1 and listName2 TO CHECK ON THE DASHBOARD  ─
            // ────────────────────────────────────────────────────────────────────────────────────
            var checkbox1Finder = find.descendant
            (
              of: find.ancestor(of: find.text(list1), matching: find.byType(ListOfListsItem)), 
              matching: find.byType(Checkbox)
            );
            await tester.ensureVisible(checkbox1Finder);
            await tester.tap(checkbox1Finder);
            await tester.pumpAndSettle();

           var checkbox2Finder = find.descendant
            (
                of: find.ancestor(of: find.text(list2), matching: find.byType(ListOfListsItem)), 
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
            var textFinder = find.text(list3);
            Text textWidget = tester.widget(textFinder);
            expect(textWidget.data, list3);            
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
            await gpsProcessPageFromHomePage(tester);

            // ── ADDING 3 LISTS OF PARTICIPANTS (non alphabetical order)  ──────────────────────────────────
            // ────────────────────────────────────────────────────────────────────────────
            List< Map<String,Map<String, dynamic>> > listDataMapsList =
            [
              {list3:{"names":names3,"keywords":[]}},
              {list1:{"names":names1,"keywords":[]}},
              {list2:{"names":names2,"keywords":[]}},                          
            ];
            await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);

            // ── REACHING THE LISTS PAGE   ──────────────────────────────────
            // ───────────────────────────────────────────────────────────────
            await listLoadingDashboardFromGPSprocessPage(tester);
            
            // ── SORTING BY LABEL ──────────────────────────────────
            // ────────────────────────────────────────────────────────
            // Triggering the sort
            var sortByTitleFinder = find.textContaining(sortByTitleLabel);
            await tester.tap(sortByTitleFinder);
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));

            // Searching the list labels          
            var titlesFinder = await getAllSessionsTitles(tester);
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
            titlesFinder = await getAllSessionsTitles(tester); 

            // Verifying the alphabetical order 
            for (var index = 0; index < totalTitles; index++)
            {
              expect((tester.widget<Text>(titlesFinder.at(index)).data), listLabelsSorted.reversed.toList()[index]);
            }       
          }
        );        
      });

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
          await gpsProcessPageFromHomePage(tester);

          // ── ADDING 3 LISTS OF PARTICIPANTS ──────────────────────────────────
          // ────────────────────────────────────────────────────────────────────
          List< Map<String,Map<String, dynamic>> > listDataMapsList =
          [            
            {list1:{"names":names1,"keywords":keywords1}},
            {list2:{"names":names2,"keywords":keywords2}},
            {list3:{"names":names3,"keywords":keywords2}},                          
          ];
          await addParticipantsListsFromGPSprocessPage(tester: tester, listDataMapsList: listDataMapsList);

          // ── REACHING THE LISTS PAGE   ──────────────────────────────────
          // ───────────────────────────────────────────────────────────────
          await listLoadingDashboardFromGPSprocessPage(tester);
        
          // ── FILTERING BY KEYWORDS ────────────────────────────
          // ─────────────────────────────────────────────────────
          // 1. Filtering by kwCompanionship
          var kwCompanionshipFinder = await getKwFilterChip(tester, kwCompanionship);
          await tester.tap(kwCompanionshipFinder);
          await tester.pumpAndSettle();

          // Verifying the titles present
          var titlesFinder = await getAllSessionsTitles(tester);
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
          var kwWorkplaceFinder = await getKwFilterChip(tester, kwWorkplace);
          await tester.tap(kwWorkplaceFinder);
          await tester.pumpAndSettle();

          // Verifying the titles present
          titlesFinder = await getAllSessionsTitles(tester);
          totalTitles = titlesFinder.evaluate().length;
          if (testingDebug) pu.printd('Testing Debug: totalTitles for $kwWorkplace: $totalTitles');

          for (var index = 0; index < totalTitles; index++)
          {
            expect((tester.widget<Text>(titlesFinder.at(index)).data), titlesWorkplace.reversed.toList()[index]);
          }         

          await tester.pump(const Duration(seconds: 2));

        });      
    });
    
  });
}