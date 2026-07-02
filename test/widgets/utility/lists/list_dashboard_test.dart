import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dev/test_utils.dart';
import 'package:journeyers/widgets/utility/lists/list_dashboard.dart';
import 'package:journeyers/widgets/utility/lists/list_dashboard_const_strings.dart';


void main() {
  // ── TESTS PREPARATION AND CLEANUP ─────────────────────────────────────────────────────────────
  Directory? testTmpDir;
  
  setUp(() async {
    // Creating a temporary folder to store the files to save
    testTmpDir = await Directory.systemTemp.createTemp('group_problem_solving_integration_test_');
    PathProviderPlatform.instance = PathProviderPlatformRedirectForTesting(testTmpDir!.path);
    // To intercept the way the date is saved
    dateIndex = 0;
  });

  // This function will be called after each test is run. The body may be asynchronous; if so, it must return a Future.
  tearDown(() async {
    if (testTmpDir!.existsSync()) {
      // Deleting the temporary folder created to store the saved files
      await testTmpDir!.delete(recursive: true);
    }
  });

  Future<void> pumpTestableWidget(WidgetTester tester)
  {
    // Building the widget
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListDashboard
          (
            dashboardContext: '', 
            onAllSessionFilesDeletedContextPageCallbackFunction: () {}, 
            onParticipantsLoadedCallbackFunction: (_) {}, 
            onEditSessionDataCallbackFunction: 
            ({
              required String dashboardContext,
              required bool isSessionDataBeingEdited, 
              required String titleWhenEdition, 
              required Set<String> keywordsWhenEdition,
              required DTOCAForm dtoCAFormWhenEdition, 
              required String fileNameWithoutExtensionWhenEdition 
            }) {}, 
            dashboardFilteringByKeywordsKey: null,
          ),
        ),
      ),
    );    
  }

  group('ListDashboard Tests: \n', () 
  {
    // 'Empty dashboard: button toward adding a new list'
    testWidgets('Empty dashboard: button toward adding a new list', 
    (WidgetTester tester) async 
    {
      // Pumping the widget
      await pumpTestableWidget(tester);
      await tester.pumpAndSettle();

      // Verifying the new list button present
      var newListButtonFinder = find.text(newListButtonLabel);
      expect(newListButtonFinder, findsOne);
    });  
  }); 

}