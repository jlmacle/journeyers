import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj;
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_checked_using_a_blacklist.dart';


void main() {
  const textWithQuote = 'Perse"verance';
  const textWithDot = '.Legacy';
  const fileNameBlacklisted = "a.csv";
  const textValid = 'Context analysis';
  
  group('TextFieldChecked Tests:\n', () {
    testWidgets('Should display no initial error', (WidgetTester tester) async {
      GlobalKey errorMessageKey1 = GlobalKey(debugLabel: 'error-msg-1');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageFieldKey : errorMessageKey1,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: const {},
              blacklistingFunctionsErrorsMapping:  const {},
            ),
          ),
        ),
      );
      
      // Verifying that the error message starts empty
      final errorMessageFinder = find.descendant
      (
        of: find.byKey(errorMessageKey1), // Finds the Center widget by Key
        matching: find.byType(Text), // Finds the error message Text widget inside it
      );
      final errorTextWidget = tester.widget<Text>(errorMessageFinder);
      expect(errorTextWidget.data, equals(""));
    });

    testWidgets('Should show error message when a sanitizing function (containsAStraightQuote) returns true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
             blacklistingFunctionsErrorsMapping: const {},
            ),
          ),
        ),
      );

      // Entering text to trigger "containsStraightQuote"
      await tester.enterText(find.byType(TextField), textWithQuote);
      await tester.pumpAndSettle();

      // Verifying error message is rendered
      expect(find.text(TextFieldUtils.errorContainsAStraightQuote), findsOneWidget);
    });

    testWidgets('Should show error message when a sanitizing function (containsADot) returns true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForFileNames,
              blacklistingFunctionsErrorsMapping: const {},
            ),
          ),
        ),
      );

      // Entering text to trigger "containsADotError"
      await tester.enterText(find.byType(TextField), textWithDot);
      await tester.pumpAndSettle();

      // Verifying error message is rendered
      expect(find.text(TextFieldUtils.errorContainsADot), findsOneWidget);
    });
    
    testWidgets('Should show error message when a blacklist check is positive', (WidgetTester tester) async {
      GlobalKey errorMessageKey2 = GlobalKey(debugLabel: 'error-msg-2');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageFieldKey: errorMessageKey2,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (_) {},
              stringSanitizerBundlesErrorsMapping: const {},
              blacklistingFunctionsErrorsMapping: TextFieldUtils.simpleBlacklistingFunctionErrorMapping,
            ),
          ),
        ),
      );

      // Entering the text to search in the blacklist
      await tester.enterText(find.byType(TextField), fileNameBlacklisted);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifying error message is rendered
      expect(find.text(TextFieldUtils.errorTextBlacklisted), findsOneWidget);
    });


    testWidgets('Should call onTextFieldValueSubmittedCallbackFunction if input is valid', (WidgetTester tester) async {
      String submittedValue = "";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldSanitizedAndCheckedUsingABlackList(
              textFieldStartValue: "",
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueChangedCallbackFunction: (val) => submittedValue = val,
              stringSanitizerBundlesErrorsMapping: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
              blacklistingFunctionsErrorsMapping: const{},
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