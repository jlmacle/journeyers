import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';

//**************** UTILITY CLASSES ****************/
UserPreferencesUtils up = UserPreferencesUtils();

void main() 
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
        'A newly installed app should display the information modal,\n before starting the first context analysis.', 
        (tester) async 
        {
          // Resetting the information modal status to have the modal displayed
          up.resetInformationModalStatus();

          // Launching the widget
          await tester.pumpWidget(const MaterialApp(home: ContextAnalysisPage()));

          // Waiting for preferences to load and the modal to appear
          await tester.pumpAndSettle();

          // Testing the presence of the information modal status
          final modalWidget = find.byKey(const Key('information_modal'));
          expect(modalWidget, findsOneWidget);
        }    
      );
    }
  );
}