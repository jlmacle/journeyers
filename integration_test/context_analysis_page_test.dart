import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';

//**************** UTILITY CLASSES ****************//
UserPreferencesUtils _upu = UserPreferencesUtils();
DashboardUtils _du = DashboardUtils();
PrintUtils _pu = PrintUtils();

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
        skip:true,
        // Testing the presence of the information modal for a newly installed app
        'A newly installed app should display the information modal,\n before starting the first context analysis.', 
        (tester) async 
        {
          // Resetting the information modal status to have the modal displayed
          _upu.resetInformationModalStatus();

          // Launching the widget
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

          // Waiting for preferences to load and the modal to appear
          await tester.pumpAndSettle();

          // Testing the presence of the information modal status
          final modalWidget = find.byKey(const Key('information_modal'));
          await tester.pumpAndSettle();
          expect(modalWidget, findsOneWidget);

          // Dismissing the modal to avoid the modal appearing at the next "flutter run"
          await tester.tap(modalWidget);
          await tester.pumpAndSettle();          
        }
      );

      testWidgets
      ( 
        skip:true,
        // Testing the presence of the context form, without the dashboard, when no session data is stored
        'When no session data is stored, the context form should be displayed,\n without the dashboard.', 
        (tester) async 
        {  
          // Setting 'wasSessionDataSaved' to false
          await _upu.saveWasSessionDataSaved(false);
          
          // Launching the widget
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));
          await tester.pumpAndSettle();

          // Testing that the dashboard is not present
          final dashboardWidget = find.byKey(const Key('analyses_dashboard'));
          expect(dashboardWidget, findsNothing);

          // Testing that the context form is present (+ pause for visual inspection)
          final formWidget = find.byKey(const Key('form'));
          // await tester.pump(const Duration(seconds: 3));
          expect(formWidget, findsOne);
           
          // Was there stored data, to reset the preferences if needed?
          // Getting the information
          final sessionData = await _du.retrieveAllDashboardSessionData
          (typeOfContextData: DashboardUtils.contextAnalysesContext);

          if (sessionData.isEmpty)
            {await _upu.saveWasSessionDataSaved(false);}
          else
            {await _upu.saveWasSessionDataSaved(true);}
        }
      );
    }
  );
}
