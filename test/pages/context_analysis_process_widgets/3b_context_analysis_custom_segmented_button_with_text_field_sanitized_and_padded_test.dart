// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart";

void main() 
{
  const segButtonTextOption1 = "Yes";

  // Method used to pump the CASegmentedButtonWithSanitizedAndPaddedTextField widget
  Future<void> pumpCASegmentedButtonWithSanitizedAndPaddedTextField(WidgetTester tester) async
  {
    return await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body:  CASegmentedButtonWithSanitizedAndPaddedTextField
          (            
            textFieldHint: "", 
            segButtonTextOption1: segButtonTextOption1, 
            segButtonTextOption2: "",
          )
        )
      )
    );
  }


  group("CASegmentedButtonWithSanitizedAndPaddedTextField Tests: \n", 
  () 
  {  
    group("Presence/Absence of the text field: \n", 
    () 
    { 
        // "At start, no selection is made with the segmented button, and the textfield is absent"
        testWidgets(
          "At start, no selection is made with the segmented button, and the textfield is absent", 
          (WidgetTester tester) async 
          {
            // Pumping the widget 
            await pumpCASegmentedButtonWithSanitizedAndPaddedTextField(tester);

            // Searching for the SegmentedButton widget
            final segmentedButtonFinder = find.descendant(
              of:       find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
              // Important: find.byType(SegmentedButton) would find no widget
              matching: find.byType(SegmentedButton<String>),
            );

            // Verifying no selection made with the segmented button
            expect(tester.widget<SegmentedButton>(segmentedButtonFinder).selected, <String>{});

            // Verifying the text field absent
            expect(find.byType(TextField), findsNothing);
          }
        );       

        // "If a selection is made with the segmented button, the textfield is present"
        testWidgets(
          "If a selection is made with the segmented button, the textfield is present", 
          (WidgetTester tester) async 
          {
            // Pumping the widget 
            await pumpCASegmentedButtonWithSanitizedAndPaddedTextField(tester);

            // Selecting the first option
            await tester.tap(find.text(segButtonTextOption1));
            await tester.pumpAndSettle();

            // Verifying the text field present
            expect(find.byType(TextField), findsOne);
          }
        );       
    });    
 
    group("Text field state maintained: \n", 
    () 
    { 
      // "Text maintained if text was present, and selections are unselected/re-selected: \n"
        testWidgets(
          "Text maintained if text was present, and selections are unselected/re-selected: \n", 
          (WidgetTester tester) async 
          {
            var someText = "someText";

            // Pumping the widget 
            await pumpCASegmentedButtonWithSanitizedAndPaddedTextField(tester);

            // Selecting the first option
            await tester.tap(find.text(segButtonTextOption1));
            await tester.pumpAndSettle();

            // Searching the text field
            final textFieldFinder = find.byType(TextField);

            // Adding text to the text field, without any tester.testTextInput.receiveAction
            await tester.enterText(textFieldFinder, someText);

            // Unselecting the first option
            await tester.tap(find.text(segButtonTextOption1));
            await tester.pumpAndSettle();

            // Verifying the text field absent
            expect(textFieldFinder, findsNothing);

            // Re-selecting the first option
            await tester.tap(find.text(segButtonTextOption1));
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