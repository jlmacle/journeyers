import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:integration_test/integration_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';



// Mock class creation
class MockPathProviderPlatform extends PathProviderPlatform 
{
  @override
  Future<String?> getApplicationSupportPath() async => '.'; // Returns current directory
}

void main() async
{
  // This initializes the bridge between the app and the test runner
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mock class declaration before running tests
  PathProviderPlatform.instance = MockPathProviderPlatform();

  group
  (
    'Context analysis page tests\n', 
    () 
    {         

      // 'Information modal:\n'
      // 'A newly installed app should display the information modal,\n'
      // 'before starting the first context analysis.'
      testWidgets
      (
        // skip:true,
        'Information modal:\n'
        'A newly installed app should display the information modal,\n'
        'before starting the first context analysis.', 
        (WidgetTester tester) async 
        {
          // Setting mock values for SharedPreferences
          // 'isInformationModalAcknowledged' set to false to trigger the modal
          SharedPreferences.setMockInitialValues
          ({
            'isInformationModalAcknowledged': false,
            // Avoids interferences from the dashboard
            'wasSessionDataSaved': false
          });

          // Widget wrapped in a MaterialApp because the page uses Scaffold, 
          // showDialog (Navigator), and AppLocalizations
          await tester.pumpWidget
          (
            const MaterialApp
            (
              home: ContextAnalysisPage()
            )
          );

          // getPreferences is async and calls setState. 
          // Need to pump and wait for the microtasks to finish.
          await tester.pumpAndSettle();

          // Verifying the modal is present
          final modalTextFinder = find.byKey(const Key('information-modal'));
          expect(modalTextFinder, findsOneWidget);

          // Verifying the modal's behavior
          await tester.tap(modalTextFinder);
          await tester.pumpAndSettle();

          // Verifying the modal is gone
          expect(modalTextFinder, findsNothing);
      }
    );

    // 'Information modal:\n'
    // 'Information modal is not displayed when already acknowledged', 
    testWidgets
    (
      // skip:true, 
      'Information modal:\n'
      'Information modal is not displayed when already acknowledged', 
      (WidgetTester tester) async 
      {
        // Setting mock values for SharedPreferences
        SharedPreferences.setMockInitialValues
        ({
          'isInformationModalAcknowledged': true,
          // Avoids interferences from the dashboard
          'wasSessionDataSaved': false,
        });

        // Widget wrapped in a MaterialApp because the page uses Scaffold, 
        // showDialog (Navigator), and AppLocalizations
        await tester.pumpWidget
        (
          const MaterialApp
          (
            home: ContextAnalysisPage()
          )
        );

        // getPreferences is async and calls setState. 
        // Need to pump and wait for the microtasks to finish.
        await tester.pumpAndSettle();

        // Verifying the modal is absent
        final modalTextFinder = find.byKey(const Key('information-modal'));
        expect(modalTextFinder, findsNothing);
      }
    );
  });
}
