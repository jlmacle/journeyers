import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_padded_text_field.dart';


void main() {
  group('CustomPaddedTextField Widget Tests', () {

    testWidgets('Should remove double quotes and display error message', (WidgetTester tester) async {
      String capturedValue = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaddedTextField(
              textFieldHint: 'Hint',
              parentTextFieldValueCallBackFunction: (val) => capturedValue = val,
            ),
          ),
        ),
      );

      // Entering text containing double quotes
      await tester.enterText(find.byType(TextField), 'Hello "World"');
      await tester.pump(); // Triggers frame for quoteAndLineReturnCheck

      // Verifying quotes are stripped in the UI and via callback
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.textContaining('"'), findsNothing);
      expect(capturedValue, 'Hello World');

      // Verifying the specific error message is displayed
      expect(find.textContaining('Straight double quotes'), findsOneWidget);
    });

    testWidgets('Should remove line returns and display error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPaddedTextField(textFieldHint: 'Hint'),
          ),
        ),
      );

      // Entering text with a newline
      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2');
      await tester.pump();

      // Verifying newline is stripped
      expect(find.text('Line 1 Line 2'), findsOneWidget);
      expect(find.textContaining('line returns'), findsOneWidget);
    });

    testWidgets('Should clear error message when valid text is typed after an error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPaddedTextField(textFieldHint: 'Hint'),
          ),
        ),
      );

      // Triggering error
      await tester.enterText(find.byType(TextField), '"');
      await tester.pump();
      expect(find.textContaining('Straight double quotes'), findsOneWidget);

      // Typing valid text (Note: logic requires a character deletion or change to reset)
      await tester.enterText(find.byType(TextField), 'Valid Text');
      await tester.pump();

      // Verifying error message is now gone
      expect(find.textContaining('Straight double quotes'), findsNothing);
    });
  });
}