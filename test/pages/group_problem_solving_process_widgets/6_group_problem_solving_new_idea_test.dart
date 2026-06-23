// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/6_group_problem_solving_new_idea.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

void main() 
{
  Future<void> pumpGPSNewIdea(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSNewIdea
          (
            newIdeaOnAddedCallbackFunction: (_){},
          ),
        ),
      ),
    );
  }

  group('GPSNewIdea Tests: \n', 
  () 
  {  
    group("GPSNewIdea default aspect: \n", 
    () 
    {      
      // 'The hint text is present'
      testWidgets('The hint text is present', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSNewIdea(tester);

        // Verifying the hint text present
        expect(find.text(newIdeaTextFieldHint), findsOne);        
      });          
    
    });
  });
}