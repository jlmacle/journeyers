import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart';

void main() 
{
  // Method used to pump the CACheckboxWithSanitizedAndPaddedTextField widget
  Future<void> pumpCACheckboxWithSanitizedAndPaddedTextField(WidgetTester tester) async
  {
    return await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body:  CACheckboxWithSanitizedAndPaddedTextField
          (
            checkboxText: '', 
            textFieldHint: ''
          )
        )
      )
    );
  }

 
  // 'CACheckboxWithSanitizedAndPaddedTextField Tests: \n'
  group('CACheckboxWithSanitizedAndPaddedTextField Tests: \n', 
  () 
  {  
    // 'Presence/Absence of the text field: \n'
    group('Presence/Absence of the text field: \n', 
    () 
    { 
        // 'If the checkbox is unchecked, the textfield is absent'
        testWidgets(
          'If the checkbox is unchecked, the textfield is absent', 
          (WidgetTester tester) async 
          {
            // Pumping the widget 
            await pumpCACheckboxWithSanitizedAndPaddedTextField(tester);

            // Searching for the Checkbox widget
            final checkboxFinder = find.descendant(
              of:       find.byType(CACheckboxWithSanitizedAndPaddedTextField),
              matching: find.byType(Checkbox),
            );

            // Verifying the checkbox unchecked
            expect(tester.widget<Checkbox>(checkboxFinder).value, false);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);
          }
        );
    });

  });
}