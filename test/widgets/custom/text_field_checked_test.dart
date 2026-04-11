import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_checked.dart';


void main() {
  const errorKey = Key('error_msg_key');
  const errorMsgIsTooShort = 'Text is too short';
  const errorMsgIsEmpty = 'Text should not be empty';
  const textTooShort = 'a';
  const textNonEmpty = 'Non empty text';

  // Blocking functions examples
  bool isEmpty(String value) => value.isEmpty; // Returns true (blocked) if empty
  bool isTooShort(String value) => value.length < 3; // Returns true (blocked) if < 3 chars

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

    testWidgets('Should show error message when a blocking function returns true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldChecked(
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageKey: errorKey,
              errorMessageStyle: analysisTextFieldErrorStyle,
              valueSubmittedCallbackFunction: (_) {},
              blockingFunctionsErrorMessagesMapping: {
                isTooShort: errorMsgIsTooShort,
              },
            ),
          ),
        ),
      );

      // Entering 1 character to trigger "isTooShort"
      await tester.enterText(find.byType(TextField), textTooShort);
      await tester.pump();

      // Verifying error message is rendered
      expect(find.text(errorMsgIsTooShort), findsOneWidget);
    });

    testWidgets('Should NOT call valueSubmittedCallbackFunction if submitIsBlocked is true', (WidgetTester tester) async {
      bool callbackCalled = false;
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
              valueSubmittedCallbackFunction: (val) {
                callbackCalled = true;
                submittedValue = val;
              },
              blockingFunctionsErrorMessagesMapping: {
                isTooShort: errorMsgIsTooShort,
              },
            ),
          ),
        ),
      );

      // Entering invalid text
      await tester.enterText(find.byType(TextField), textTooShort);
      await tester.pump();

      // Attempting to submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Verifying that the callback is not called
      expect(callbackCalled, isFalse);
      // Verifying that the value didn't change
      expect(submittedValue, equals(""));
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

    testWidgets('Should call valueSubmittedCallbackFunction if the map has no blocking functions', (WidgetTester tester) async {
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
              blockingFunctionsErrorMessagesMapping: Map<StringValidator, String>(),
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