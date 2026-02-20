import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async
{
  // This initializes the bridge between the app and the test runner
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group
  (
    'Context analysis page tests\n', 
    () 
    {         

      testWidgets
      (
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
          final modalTextFinder = find.byKey(const Key('information_modal'));
          expect(modalTextFinder, findsOneWidget);

          // Verifying the modal's behavior
          await tester.tap(modalTextFinder);
          await tester.pumpAndSettle();

          // Verifying the modal is gone
          expect(modalTextFinder, findsNothing);
      }
    );

    testWidgets
    (
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
        final modalTextFinder = find.byKey(const Key('information_modal'));
        expect(modalTextFinder, findsNothing);
      }
    );

      // Testing the presence of the context form, without the dashboard, when no session data is stored
      testWidgets
      ( 
        // skip:true,        
        'No session data stored:\n'
        'When no session data is stored, the context form should be displayed,\n'
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

          // Testing that the dashboard is not present
          final dashboardWidget = find.byKey(const Key('analyses_dashboard'));
          expect(dashboardWidget, findsNothing);

          // Testing that the context form is present 
          final formWidget = find.byKey(const Key('form'));
          // await tester.pump(const Duration(seconds: 3));
          expect(formWidget, findsOne);
        }
      );
    
      // Testing for the presence of the button starting a new context analysis
      testWidgets
      ( 
        // skip:true,
        'Data stored: New context analysis button:\n'
        'The dashboard page should have a button to start a new context analysis.',
        (tester) async 
        { 
          // Setting mock values for SharedPreferences
          SharedPreferences.setMockInitialValues
          ({
            // Prevents the modal from blocking the UI
            'isInformationModalAcknowledged': true, 
            'wasSessionDataSaved': true,
          });
          
          // Widget wrapped in a MaterialApp because the page uses Scaffold, 
          // showDialog (Navigator), and AppLocalizations
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

          // getPreferences is async and calls setState. 
          // Need to pump and wait for the microtasks to finish.
          await tester.pumpAndSettle();

          // Testing for the presence of the button
          final buttonWidget = find.byKey(const Key('analyses_new_session_button'));
          expect(buttonWidget, findsOne);
          
        }
      );
    }
  );
}
