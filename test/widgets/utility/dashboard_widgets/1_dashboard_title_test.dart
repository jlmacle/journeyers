import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/widgets/utility/dashboard_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/1_dashboard_title.dart';

void main() {
  group('DashboardTitle Widget Tests: \n', () 
  {
    const String testTitle = dashboardTitle;

    // 'should render the correct title text'
    testWidgets('Should render the correct title text', 
    (WidgetTester tester) async 
    {
      // Building the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardTitle(title: testTitle),
          ),
        ),
      );

      // Verifying the text appears
      expect(find.text(testTitle), findsOneWidget);
    }
    );    
  }
);  

}