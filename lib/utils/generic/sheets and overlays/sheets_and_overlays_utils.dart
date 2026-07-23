import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";

/// {@category Utils - Generic}
/// Method building an overlay used to add elements to a set, for example keywords.
void showAddToSetOverlay
({
  required BuildContext context,
  required String overlayTitle,
  required TextStyle overlayTitleStyle,
  required String overlayCloseIconButtonToolTip,
  Color overlayCloseIconButtonColor = black,
  required Key textEditingControllerKey,
  required TextEditingController textEditingController,
  required TextStyle textFieldStyle,
  required String textFieldHintText,
  required TextStyle textFieldHintStyle,
  required Function onSubmittedCallbackFunction,
  required Set<String> setToUpdate,
  Color inputChipDeleteIconColor = black,
  required VoidCallback? onDeletedCallbackFunction
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
                                        onDeleted: onDeletedCallbackFunction
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
