import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/utils/generic/dev/placeholder_functions.dart";

/// {@category Utils - Generic}
/// Method building an overlay used to add elements to a set, for example to a set of keywords.
void showAddToSetOverlay
({
  required BuildContext context,
  appBarBackgroundColor = white,
  appBarForegroundColor = black,
  required String overlayTitle,
  required TextStyle overlayTitleStyle,
  required String overlayCloseIconButtonToolTip,
  Color overlayCloseIconButtonColor = black,
  required TextEditingController textEditingController,
  required Key textEditingControllerKey,  
  required TextStyle textFieldStyle,
  required String textFieldHintText,
  required TextStyle textFieldHintStyle,
  required void Function(String value, StateSetter stateSetter) onSubmittedCallbackFunction,
  required Set<String> setToUpdate,
  Color inputChipDeleteIconColor = black,
  required void Function(String tag, StateSetter stateSetter) onDeletedCallbackFunction
}) 
{
    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          // APPBAR SECTION
          appBar: AppBar(
            centerTitle: true, 
            backgroundColor: appBarBackgroundColor,
            foregroundColor: appBarForegroundColor,
            title: 
              Padding
              (
                padding: const EdgeInsets.all(16.0), 
                child: Text(
                  // Title
                  overlayTitle,
                  // Title style
                  style: overlayTitleStyle,
                  textAlign: TextAlign.center,
                  maxLines: 20,
                  overflow: TextOverflow.visible,
                  softWrap: true,                  
                ),
              ),
            actions: [
              // Close button
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: overlayCloseIconButtonToolTip,
                color: overlayCloseIconButtonColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          // BODY SECTION
          body: SafeArea(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) {
                return 
                Column
                (
                  children: 
                  [                     
                    Padding
                    (
                      padding: const EdgeInsets.only(left:20, right:20, top:10, bottom:0),
                      child: TextField
                      (
                        key: textEditingControllerKey,
                        controller: textEditingController,
                        decoration: InputDecoration
                        (
                          hint: Center
                          (
                            child: Text
                            (
                              textFieldHintText,
                              textAlign: TextAlign.center, 
                              style: textFieldHintStyle
                            )
                          )
                        ),
                        textAlign: TextAlign.center,
                        style: textFieldStyle,
                        onSubmitted: (value) => onSubmittedCallbackFunction(value, setLocalState),
                      ),
                    ),
                    // Display of the set elements
                    Center
                    (
                      child: Padding
                      (
                        padding: const EdgeInsets.only(bottom: 0),
                        child: Wrap
                        (
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: 
                          [
                            ...setToUpdate.map
                            (
                              (tag) => InputChip
                                      (
                                        label: Text(tag),
                                        deleteIcon: const Icon(Icons.close),
                                        deleteIconColor: inputChipDeleteIconColor,
                                        onDeleted: () => onDeletedCallbackFunction(tag, setLocalState)
                                      )
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ); 
              },
            ),
          ),
        );
      },
    );
  }

/// {@category Utils - Generic}
/// Method building a modal bottom sheet used to edit, keywords for example.
void showEditSheet
({
  required BuildContext context,
  required TextEditingController textEditingController,
  required Key textFieldKey,
  required String textFieldStartValue,
  required String textFieldLabelText,
  required TextStyle textFieldLabelStyle,
  required String? textFieldErrorText,
  Future<bool> Function({required String value}) errorTextTriggerFunction = placeHolderErrorTextTriggerFunctionReturningFalse,
  String? errorTextTriggerFunctionParameter,
  required Future<void> Function(String value)? onConfirmSuccessfulCallbackFunction,
  required String elevatedButtonText,
  required TextStyle elevatedButtonStyle
})
{
    // Adding a start value to the tec
    textEditingController.text = textFieldStartValue; 

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), 
      builder: (BuildContext context)  
      {
        // The text field error text
        String? errorText;

        // StatefulBuilder gives a local setState scoped to this sheet
        return       
        StatefulBuilder
        (
          builder: (context, setLocalState) 
          { 
            // Method used to verify the data before submitting
            Future<void> onConfirm
            ({
              required TextEditingController textEditingController,
              required String? enteredValue,
            }) async 
            {
              // if reason to show an error message
              if (await errorTextTriggerFunction(value: enteredValue!)) {
                setLocalState(() {
                  errorText = textFieldErrorText;
                });
                return;
              }

              setLocalState(() {
                // Clearing error on valid input
                errorText = null; 
              });

              // Callback function on updating edited value
              await onConfirmSuccessfulCallbackFunction!(textEditingController.text.trim());
            }
                
            return Padding
            (
              padding: EdgeInsets.only
              (
                bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard padding
                left: 20, right: 20, top: 10,
              ),
              child: Column
              (
                mainAxisSize: MainAxisSize.min,
                children: 
                [
                  TextField
                  (
                    key: textFieldKey,
                    controller: textEditingController,
                    autofocus: true,
                    decoration: InputDecoration
                    (
                      labelText: textFieldLabelText, 
                      labelStyle: textFieldLabelStyle,
                      errorText: errorText
                    ),
                    onSubmitted:(value) async => await onConfirm
                                (
                                  textEditingController: textEditingController, 
                                  enteredValue: value,
                                ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton
                  (
                    key: const Key("overlay-edit-save-button"),
                    onPressed:  () async
                                {
                                  await onConfirm
                                  (
                                    textEditingController: textEditingController, 
                                    enteredValue: textEditingController.text.trim(),
                                  );
                                },               
                    child: Text
                    (
                      elevatedButtonText,
                      style: elevatedButtonStyle,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          });
        
      }
    );
  }