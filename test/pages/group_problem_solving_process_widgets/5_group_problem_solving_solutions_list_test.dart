// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_solutions_list.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

void main() 
{
  Future<void> pumpGPSSolutionsList(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GPSSolutionsList
          (
            solutions: [],
          ),
        ),
      ),
    );
  }

  group('GPSSolutionsList Tests: \n', 
  () 
  {  
    group("GPSSolutionsList default aspect: \n", 
    () 
    {
      // 'The title is present'
      testWidgets('The title is present', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSSolutionsList(tester);

        // Verifying the title present
        expect(find.text(solutionsListTitle), findsOne);        
      });    

      // 'The placeholder is present'
      testWidgets('The placeholder is present', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSSolutionsList(tester);

        // Verifying the placeholder present
        expect(find.text(solutionsListPlaceholder), findsOne);        
      });          
    
    });
  });
}