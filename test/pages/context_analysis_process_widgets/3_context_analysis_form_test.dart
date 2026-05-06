import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3_context_analysis_form.dart';
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
      
    }
  );

  
  });

}