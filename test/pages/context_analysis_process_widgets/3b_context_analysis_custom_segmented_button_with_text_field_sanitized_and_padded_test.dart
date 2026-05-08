// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart';

void main() 
{
  // Method used to pump the CASegmentedButtonWithSanitizedAndPaddedTextField widget
  Future<void> pumpCASegmentedButtonWithSanitizedAndPaddedTextField(WidgetTester tester) async
  {
    return await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body:  CASegmentedButtonWithSanitizedAndPaddedTextField
          (            
            textFieldHint: '', 
            segButtonTextOption1: '', 
            segButtonTextOption2: '',
          )
        )
      )
    );
  }

 
  // 'CASegmentedButtonWithSanitizedAndPaddedTextField Tests: \n'
  group('CASegmentedButtonWithSanitizedAndPaddedTextField Tests: \n', 
  () 
  {  
    // 'Presence/Absence of the text field: \n'
    group('Presence/Absence of the text field: \n', 
    () 
    { 
        // 'If no selection is made with the segmented button, the textfield is absent'
        testWidgets(
          'If no selection is made with the segmented button, the textfield is absent', 
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
    });    
  });
}