// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart';

void main() 
{
  Future<void> pumpGPSChecklist(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GPSChecklist(),
        ),
      ),
    );
  }

  // 'GPSChecklist Tests: \n'
  group('GPSChecklist Tests: \n', 
  () 
  {  
    // "GPSChecklist default aspect: \n"
    group("GPSChecklist default aspect: \n", 
    () 
    { 
      // 'The default rectangle color is orange'
      testWidgets('The default rectangle color is orange', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSChecklist(tester);

        // Verifying the default rectangle color is orange
        var containerFinder = find.byType(Container);

        Container container = tester.widget<Container>(containerFinder);
        var boxDecoration = container.decoration as BoxDecoration;
        var border = boxDecoration.border as Border;

        var orangeShade = orangeShade900;

        expect(
          border.top.color,
          orangeShade,
        );

        expect(
          border.bottom.color,
          orangeShade,
        );

        expect(
          border.right.color,
          orangeShade,
        );

        expect(
          border.left.color,
          orangeShade,
        );
      });          
    });
  
  });
}