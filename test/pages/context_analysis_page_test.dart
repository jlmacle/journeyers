import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/widgets/utility/dashboard_page.dart';


void main() 
{
    // 
    group('CAPage Tests: \n', 
    () 
    {  
      // 'CAPage: Runtime behavior\n'
      group('CAPage: Runtime behavior\n', 
      () 
      { 
        // 'First-run modal: \n'
        // 'A newly installed app should display the first-run modal,\n'
        // 'before starting the first context analysis.'
        testWidgets
        (        
          'First-run modal: \n'
          'A newly installed app should display the first-run modal,\n'
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
            final modalFinder = find.byType(AlertDialog);
            expect(modalFinder, findsOneWidget);

            // Verifying the modal's behavior
            await tester.tap(modalFinder);
            await tester.pumpAndSettle();

            // Verifying that the modal is absent
            expect(modalFinder, findsNothing);

            // Verifying the dashboard absent
            final dashboardFinder = find.byType(DashboardPage);
            expect(dashboardFinder, findsNothing);

            // Verifying the presence of the context analysis process page
            final caFormFinder = find.byType(CAProcess);
            expect(caFormFinder, findsOneWidget);
          }
        );
        });

    });
}