import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3_context_analysis_form.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_questions_fields.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';

void main() 
{
  // Method used to pump the widget
  Future<void> pumpCAForm(WidgetTester tester) async
  {
    return await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body:  CAForm.fromDTO
            (
              dtoCAForm: DTOCAForm(),
              parentCallbackFunctionToRefreshTheCAPage: () {},
              parentCallbackFunctionToSetFocusabilityOfBottomBarItems: (_) {},
            )
          )
        )
    );
  }

  // 'CAForm Tests: \n'
  group('CAForm Tests: \n', 
  () 
  {  
    // 'Form: Structure: \n'
    group
  (
    'Form: Structure: \n',
    ()
    {
      // 'Two perspective expansion tiles are present'
      testWidgets
      (
        'Two perspective expansion tiles are present',
        (tester) async
        {
          await pumpCAForm(tester);

          // One tile for the individual perspective, one for the group/team perspective
          expect(find.byType(ExpansionTile), findsNWidgets(2));
        },
      );

      // 'Individual and group tiles carry the correct heading text'
      testWidgets
      (
        'Individual and group tiles carry the correct heading text',
        (tester) async
        {
          final q = CAQuestionsFields();
          await pumpCAForm(tester);

          // Verifying that the first expansion tile text is correct
          var firstExpansionTileTextFinder = find.descendant
          (
            of: find.byType(ExpansionTile), 
            matching: find.byType(Text)
          ).first;
          Text firstExpansionTileTextWidget = tester.widget<Text>(firstExpansionTileTextFinder);        
          expect( firstExpansionTileTextWidget.data, q.level2TitleIndividual);

          // Verifying that the second expansion tile text is correct
          var secondExpansionTileTextFinder = find.descendant
          (
            of: find.byType(ExpansionTile), 
            matching: find.byType(Text)
          ).last;
          Text secondExpansionTileTextWidget = tester.widget<Text>(secondExpansionTileTextFinder);        
          expect(secondExpansionTileTextWidget.data, q.level2TitleGroup);
        },
      );
      
    }
  );

  
  });

}