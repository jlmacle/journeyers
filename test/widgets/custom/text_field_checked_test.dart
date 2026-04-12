import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_checked.dart';


void main() {
  const errorKey = Key('error_msg_key');
  const errorMsgIsEmpty = 'Text should not be empty';
  const textNonEmpty = 'Non empty text';

  // Blocking functions examples
  bool isEmpty(String value) => value.isEmpty; // Returns true (blocked) if empty

  group('TextFieldChecked Tests', () {
    testWidgets('Should display no initial error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldChecked(
              errorMessageKey: errorKey,
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorStyle,
              valueSubmittedCallbackFunction: (_) {},
              blockingFunctionsErrorMessagesMapping: const {},
            ),
          ),
        ),
      );
      
      // Verifying that the error message starts empty
      final errorMessageFinder = find.descendant
      (
        of: find.byKey(errorKey), // Finds the Center widget by Key
        matching: find.byType(Text), // Finds the error message Text widget inside it
      );
      final errorTextWidget = tester.widget<Text>(errorMessageFinder);
      expect(errorTextWidget.data, equals(""));
    });


    testWidgets('Should call valueSubmittedCallbackFunction if input is valid', (WidgetTester tester) async {
      String submittedValue = "";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldChecked(
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageKey: errorKey,
              errorMessageStyle: analysisTextFieldErrorStyle,
              valueSubmittedCallbackFunction: (val) => submittedValue = val,
              blockingFunctionsErrorMessagesMapping: {
                isEmpty: errorMsgIsEmpty,
              },
            ),
          ),
        ),
      );

      // Entering valid text
      await tester.enterText(find.byType(TextField), textNonEmpty);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, equals(textNonEmpty));
    });

  });
}