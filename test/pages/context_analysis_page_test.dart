import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/widgets/utility/dashboard/dashboard_page.dart';
import 'package:journeyers/widgets/utility/process/new_process_button.dart';


void main() 
{
    group('CAPage Tests: \n', 
    () 
    {  
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
              // Setting value for first-run modal to be present,
              'wasFirstRunModalAcknowledged': false,
              // and to have the context analysis page, without the dashboard.
              'wasCASessionDataSaved': false
            });

            // Widget wrapped in a MaterialApp because the page uses Scaffold, 
            // showDialog (Navigator), and AppLocalizations
            await tester.pumpWidget(const MaterialApp(home: CAPage()));
            // getPreferences is async and calls setState. 
            // Need to pump and wait for the microtasks to finish.
            await tester.pumpAndSettle();
            // "Repeatedly calls pump with the given duration 
            // until there are no longer any frames scheduled."
            

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
            final caProcessFinder = find.byType(CAProcess);
            expect(caProcessFinder, findsOneWidget);
          }
        );        

        // 'First-run modal: \n'
        // 'The first-run modal is not displayed when already acknowledged.', 
        testWidgets
        (          
          'First-run modal: \n'
          'The first-run modal is not displayed when already acknowledged', 
          (WidgetTester tester) async 
          {
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              // To not have the modal at startup
              'wasFirstRunModalAcknowledged': true,
              // To have the context analysis page, without the dashboard
              'wasCASessionDataSaved': false,
            });

            // Widget wrapped in a MaterialApp because the page uses Scaffold, 
            // showDialog (Navigator), and AppLocalizations
            await tester.pumpWidget(const MaterialApp(home: CAPage()));

            // getPreferences is async and calls setState. 
            // Need to pump and wait for the microtasks to finish.
            await tester.pumpAndSettle();

            // Verifying the modal absent
            final modalTextFinder = find.byType(AlertDialog);
            expect(modalTextFinder, findsNothing);

            // Verifying the dashboard absent
            final dashboardFinder = find.byType(DashboardPage);
            expect(dashboardFinder, findsNothing);

            // Verifying the presence of the context analysis process page
            final caProcessFinder = find.byType(CAProcess);
            expect(caProcessFinder, findsOneWidget);
          }
        );

        // 'No session data stored: \n'
        // 'When no session data is stored, the context analysis process page should be displayed,\n'
        // 'without the dashboard.', 
        testWidgets
        ( 
                  
          'No session data stored: \n'
          'When no session data is stored, the context analysis process page should be displayed,\n'
          'without the dashboard.', 
          (tester) async 
          {  
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({            
              'wasFirstRunModalAcknowledged': true,
              'wasCASessionDataSaved': false,
            });
            
            // Widget wrapped in a MaterialApp because the page uses Scaffold, 
            // showDialog (Navigator), and AppLocalizations
            await tester.pumpWidget(const MaterialApp(home: CAPage()));

            // getPreferences is async and calls setState. 
            // Need to pump and wait for the microtasks to finish.
            await tester.pumpAndSettle();

            // Verifying the presence of the context analysis process page
            final caProcessFinder = find.byType(CAProcess);
            expect(caProcessFinder, findsOneWidget);

            // Verifying the dashboard absent
            final dashboardFinder = find.byType(DashboardPage);
            expect(dashboardFinder, findsNothing);          
          }
        );

        // 'Data stored: New context analysis button: \n'
        // 'The context analysis page should have a button to start a new context analysis.',
        testWidgets
        (
          
          'Data stored: New context analysis button: \n'
          'The context analysis page should have a button to start a new context analysis.',
          (WidgetTester tester) async 
          { 
            // Setting mock values for SharedPreferences
            SharedPreferences.setMockInitialValues
            ({
              'wasFirstRunModalAcknowledged': true, 
              'wasCASessionDataSaved': true,
            });
            
            // Pumping the widget
            await tester.pumpWidget(const MaterialApp(home: CAPage()));
            // Waiting for the preferences to be loaded
            // pumpAndSettle timed out
            // await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 2));

            // Verifying the new process button present
            final buttonWidget = find.byType(NewProcessButton);
            expect(buttonWidget, findsOneWidget); 

            // Verifying the dashboard present  
            final dashboardFinder = find.byType(DashboardPage);
            expect(dashboardFinder, findsOneWidget);  
          },
        );
      });
    });
}