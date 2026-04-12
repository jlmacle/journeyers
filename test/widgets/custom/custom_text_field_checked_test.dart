import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj; 
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_checked.dart';


void main() {
  const errorKey = Key('error_msg_key');
  const textWithQuote = '"Tomorrow';
  const textValid = 'Yesterday';
  
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

    testWidgets('Should show error message when a sanitizing function returns true', (WidgetTester tester) async {
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
              blockingFunctionsErrorMessagesMapping: tfu_proj.TextFieldUtils.stringSanitizerBundlesErrorsMap
            ),
          ),
        ),
      );

      // Entering 1 character to trigger "containsStraightQuote"
      await tester.enterText(find.byType(TextField), textWithQuote);
      await tester.pumpAndSettle();

      // Verifying error message is rendered
      expect(find.text(TextFieldUtils.containsAStraightQuoteError), findsOneWidget);
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
              blockingFunctionsErrorMessagesMapping: tfu_proj.TextFieldUtils.stringSanitizerBundlesErrorsMap
            ),
          ),
        ),
      );

      // Entering valid text
      await tester.enterText(find.byType(TextField), textValid);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, equals(textValid));
    });

  });
}