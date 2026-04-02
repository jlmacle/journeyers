import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyers/widgets/utility/sessions_dashboard_page.dart';

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

            // Setting value for modal to appear
            'isInformationModalAcknowledged': false,
            // To have the context analysis page, without the dashboard
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
          // "Repeatedly calls pump with the given duration 
          // until there are no longer any frames scheduled."
          // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html

          // Verifying that the modal is present
          final modalTextFinder = find.byKey(const Key('information-modal'));
          expect(modalTextFinder, findsOneWidget);

          // Verifying the modal's behavior
          await tester.tap(modalTextFinder);
          await tester.pumpAndSettle();
            // Verifying the modal is gone
          expect(modalTextFinder, findsNothing);

          // Verifying the dashboard absent
          final dashboardFinder = find.byType(SessionsDashboardPage);
          expect(dashboardFinder, findsNothing);

          // Verifying the presence of the context analysis form
          final contextAnalysisFormFinder = find.byType(ContextAnalysisProcess);
          expect(contextAnalysisFormFinder, findsOne);
      }
    );

    // 'Information modal:\n'
    // 'Information modal is not displayed when already acknowledged', 
    testWidgets
    (
      skip:true, 
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

      // 'No session data stored:\n'
      // 'When no session data is stored, the context analysis page should be displayed,\n'
      // 'without the dashboard.', 
      // Testing the presence of the context form, without the dashboard, when no session data is stored
      testWidgets
      ( 
        skip:true,        
        'No session data stored:\n'
        'When no session data is stored, the context analysis page should be displayed,\n'
        'without the dashboard.', 
        (tester) async 
        {  
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            'wasSessionDataSaved': false,
          });
          
          // Widget wrapped in a MaterialApp because the page uses Scaffold, 
          // showDialog (Navigator), and AppLocalizations
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

          // getPreferences is async and calls setState. 
          // Need to pump and wait for the microtasks to finish.
          await tester.pumpAndSettle();

          // Testing that the context analysis page is present 
          // GlobalKeys are different objects, 
          // and are not compared by labels, even if with the same label.
          // final formWidget = find.byKey(GlobalKey(debugLabel:'context-analysis-process'));
          final formWidget = find.byType(ContextAnalysisProcess);
          // await tester.pump(const Duration(seconds: 3));
          expect(formWidget, findsOne);

          // Testing that the dashboard is not present
          final dashboardWidget = find.byKey(const Key('analyses-dashboard'));
          expect(dashboardWidget, findsNothing);
        }
      );
    }
  );
}
