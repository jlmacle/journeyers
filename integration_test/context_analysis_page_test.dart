import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:integration_test/integration_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/widgets/utility/sessions_dashboard_page.dart';


class PathProviderPlatformRedirectForTesting extends PathProviderPlatform {
  @override
  // Test folder for I/O operations
  Future<String?> getApplicationSupportPath() async {
    // This points to a system-valid temporary folder with write access
    return Directory.systemTemp.path;
  }  
}

void main() async
{
  // "A subclass of [LiveTestWidgetsFlutterBinding] that reports tests results
  // on a channel to adapt them to native instrumentation test format.""
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // "Platform-specific plugins should set this with their own platform-specific
  // class that extends [PathProviderPlatform] when they register themselves.""
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
            // Returns a plausible empty list
            return <String>["file.csv"];
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
            // Returns a plausible empty list
            return <String>["file.csv"];
          default:
            return null;
        }
      },
    );

  group
  (
    'Context analysis page tests: \n', 
    () 
    {         

      // 'Information modal:\n'
      // 'A newly installed app should display the information modal,\n'
      // 'before starting the first context analysis.'
      testWidgets
      (
        // skip:true,
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
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

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
          final contextAnalysisFormFinder = find.byType(ContextAnalysisProcess);
          expect(contextAnalysisFormFinder, findsOneWidget);
      }
    );

      // 'Information modal: \n'
      // 'Information modal is not displayed when already acknowledged.', 
      testWidgets
      (
        // skip:true, 
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
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

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
          final contextAnalysisFormFinder = find.byType(ContextAnalysisProcess);
          expect(contextAnalysisFormFinder, findsOneWidget);
        }
      );

      // 'No session data stored: \n'
      // 'When no session data is stored, the context analysis page should be displayed,\n'
      // 'without the dashboard.', 
      testWidgets
      ( 
        // skip:true,        
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
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

          // getPreferences is async and calls setState. 
          // Need to pump and wait for the microtasks to finish.
          await tester.pumpAndSettle();

          // Testing that the context analysis page is present 
          // GlobalKeys are different objects, 
          // and are not compared by labels, even if with the same label.
          // final formWidget = find.byKey(GlobalKey(debugLabel:'context-analysis-process'));
          final contextAnalysisFormFinder = find.byType(ContextAnalysisProcess);
          expect(contextAnalysisFormFinder, findsOneWidget);

          // Verifying the dashboard absent
          final dashboardFinder = find.byType(SessionsDashboardPage);
          expect(dashboardFinder, findsNothing);          
        }
      );
    
      // 'Data stored: New context analysis button: \n'
      // 'The dashboard page should have a button to start a new context analysis.',
      testWidgets
      (
        // skip:true, 
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
          
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

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
}
