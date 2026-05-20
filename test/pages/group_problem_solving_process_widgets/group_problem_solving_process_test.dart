// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';

void main() 
{
  Future<void> pumpGPSProcess(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSProcess
          (
            parentCallbackFunctionToRefreshTheGPSPage: () {},
          ),
        ),
      ),
    );
  }

  // 'GPSProcess Tests: \n'
  group('GPSProcess Tests: \n', 
  () 
  {  
    // "Stakeholder identifiers: \n"
    group("Stakeholder identifiers: \n", 
    () 
    {      
      // 'Stakeholder identifiers can be added'
      testWidgets('Stakeholder identifiers can be added', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSProcess(tester);

        // Finding the add emoji    
        var emojiFinder = find.text(addEmoji);

        // Adding identifiers
        for (var i = 1; i <= 3; i++)
        {
          // Tapping to add
          await tester.tap(emojiFinder);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));
          // Verifying present
          expect(find.byType(IdentifierWidget), findsNWidgets(i));
        }

      });          
    
    });
  });
}