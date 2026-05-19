// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/6_group_problem_solving_new_solution.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_misc_constants.dart';

void main() 
{
  Future<void> pumpGPSNewSolution(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSNewSolution
          (
            onSolutionAddedCallbackFunction: (_){},
          ),
        ),
      ),
    );
  }

  // 'GPSNewSolution Tests: \n'
  group('GPSNewSolution Tests: \n', 
  () 
  {  
    // "GPSNewSolution default aspect: \n"
    group("GPSNewSolution default aspect: \n", 
    () 
    {      
      // 'The hint text is present'
      testWidgets('The hint text is present', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSNewSolution(tester);

        // Verifying the hint text present
        expect(find.text(newSolutionTextFieldHint), findsOne);        
      });          
    
    });
  });
}