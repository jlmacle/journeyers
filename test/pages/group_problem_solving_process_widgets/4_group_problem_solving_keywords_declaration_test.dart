// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_misc_constants.dart';

void main() 
{
  Future<void> pumpGPSKeywordsDeclaration(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSKeywordsDeclaration
          (
            currentKeywords: const {},
            onKeywordsUpdatedCallbackFunction: (_){},
          ),
        ),
      ),
    );
  }

  // 'GPSKeywordsDeclaration Tests: \n'
  group('GPSKeywordsDeclaration Tests: \n', 
  () 
  {  
    // "GPSKeywordsDeclaration default aspect: \n"
    group("GPSKeywordsDeclaration default aspect: \n", 
    () 
    {
      // 'The title is present'
      testWidgets('The title is present', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSKeywordsDeclaration(tester);

        // Verifying the title present
        expect(find.text(keywordsDeclarationTitle), findsOne);        
      });          
    
    });
  });
}