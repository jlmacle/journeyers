import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart";

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
            checkboxText: "", 
            textFieldHint: ""
          )
        )
      )
    );
  }

 
  group("CACheckboxWithSanitizedAndPaddedTextField Tests: \n", 
  () 
  {  
    group("Presence/Absence of the text field: \n", 
    () 
    { 
        // "At start, the checkbox is unchecked, and the textfield is absent"
        testWidgets(
          "At start, the checkbox is unchecked, and the textfield is absent", 
          (WidgetTester tester) async 
          {
            // Pumping the widget 
            await pumpCACheckboxWithSanitizedAndPaddedTextField(tester);

            // Searching for the Checkbox widget
            final checkboxFinder = find.byType(Checkbox);

            // Verifying the checkbox unchecked
            expect(tester.widget<Checkbox>(checkboxFinder).value, false);

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);
          }
        );

        // "If the checkbox is checked, the textfield is present"
        testWidgets(
          "If the checkbox is checked, the textfield is present", 
          (WidgetTester tester) async 
          {
            // Pumping the widget 
            await pumpCACheckboxWithSanitizedAndPaddedTextField(tester);

            // Searching for the Checkbox widget
            final checkboxFinder = find.byType(Checkbox);

            // Checking the checkbox
            await tester.tap(checkboxFinder);
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);
          }
        );
    });

    group("Text field state maintained: \n", 
    () 
    { 
      // "Text maintained if text was present, and the checkbox is unchecked/re-checked: \n"
        testWidgets(
          "Text maintained if text was present, and the checkbox is unchecked/re-checked: \n", 
          (WidgetTester tester) async 
          {
            var someText = "someText";

            // Pumping the widget 
            await pumpCACheckboxWithSanitizedAndPaddedTextField(tester);

            // Searching for the Checkbox widget
            final checkboxFinder = find.byType(Checkbox);

            // Checking the checkbox
            await tester.tap(checkboxFinder);
            await tester.pumpAndSettle();

            // Searching for the text field
            final textFieldFinder = find.byType(TextField);

            // Adding text to the text field, without any tester.testTextInput.receiveAction
            await tester.enterText(textFieldFinder, someText);

            // Unchecking the checkbox
            await tester.tap(checkboxFinder);
            await tester.pumpAndSettle();

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);

            // Re-checking the checkbox
            await tester.tap(checkboxFinder);
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);

            // Verifying the text present
            expect(find.text(someText), findsOne);     
          }
        );
      });
  });
}