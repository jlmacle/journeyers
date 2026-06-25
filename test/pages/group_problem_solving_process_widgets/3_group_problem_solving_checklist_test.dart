// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

import '../../../integration_test/externalized_code/externalized_testing_code.dart';

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

  group('GPSChecklist Tests: \n', 
  () 
  {  
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
        await gpsTestChecklistTitleBorderColor(tester, rectangleColor);        
      });          
      });

      // 'The title is present'
      testWidgets('The title is present', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSChecklist(tester);

        // Verifying the title present
        expect(find.text(checkListTitle), findsOne);        
      });          
    
    });
  
}