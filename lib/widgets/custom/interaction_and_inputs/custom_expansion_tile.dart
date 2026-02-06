import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_icon_button.dart';

// Utility class
PrintUtils pu = PrintUtils();

/// {@category Custom widgets}
/// A customizable expansion tile.
class CustomExpansionTile extends StatefulWidget 
{
  /// The text to display when the tile is not expanded.
  final String text;

  /// The style for the text to display when the tile is not expanded.
  final TextStyle textStyle;

  /// The icon used to suggest that the tile is expandable.
  final Icon actionIconSuggestingExpansion;

  /// The horizontal padding for the expanded content.
  final double expandedContentPaddingHorizontal;

  /// The vertical padding for the expanded content.
  final double expandedContentPaddingVertical;

  /// The horizontal location of the expanded content.
  final CrossAxisAlignment expandedContentCrossAxisAlignment;

  /// The widget displayed in the expanded content.
  final Widget expandedContentWidget;

  /// The height of the divider under the additional text.
  final double expandedContentDividerHeight;

  /// The callback function called to edit from the expansion tile.
  final VoidCallback parentWidgetOnEditPressedCallBackFunction;

  /// The callback function called to delete from the expansion tile.
  final VoidCallback parentWidgetOnDeletePressedCallBackFunction;

  /// The callback function called to share from the expansion tile.
  final VoidCallback parentWidgetOnSharePressedCallBackFunction;

  /// A list of  [iconData, toolTipLabel, callBackFunction] values for the action icon(s).
  final List<List<dynamic>> listActionIconsData;

  /// The horizontal location of the icon(s).
  final MainAxisAlignment listActionIconsMainAxisAlignment;

  /// The tooltip label for the "Edit" icon.
  static const String toolTipEdit = 'Edit';

  /// The tooltip label for the "Delete" icon.
  static const String toolTipDelete = 'Delete';

  /// The tooltip label for the "Share" icon.
  static const String toolTipShare = 'Share';

  const CustomExpansionTile
  ({
    super.key,
    this.text = "Default tile text",
    this.textStyle = defaultConstHeadingStyle,
    this.actionIconSuggestingExpansion = const Icon(Icons.expand_more),
    this.expandedContentPaddingHorizontal = 16.0,
    this.expandedContentPaddingVertical = 8.0,
    this.expandedContentCrossAxisAlignment = CrossAxisAlignment.start,
    this.expandedContentWidget = const Text("Default expanded additional text"),
    this.expandedContentDividerHeight = 20.5,
    this.listActionIconsMainAxisAlignment = MainAxisAlignment.end,
    this.listActionIconsData = const 
    [
      [Icons.edit, toolTipEdit, null],
      [Icons.delete, toolTipDelete, null],
      [Icons.share, toolTipShare, null],
    ],
    required this.parentWidgetOnEditPressedCallBackFunction,
    required this.parentWidgetOnDeletePressedCallBackFunction,
    required this.parentWidgetOnSharePressedCallBackFunction,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> 
{
  FocusNode expandedAdditionalTextFocusNode = FocusNode();

  @override
  void dispose() 
  {
    expandedAdditionalTextFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return 
    ExpansionTile
    (
      title: 
      Text
      (
        widget.text,
        style: widget.textStyle,
      ),
      trailing: widget.actionIconSuggestingExpansion,
      children: <Widget>
      [
        Padding
        (
          padding: EdgeInsets.symmetric(horizontal: widget.expandedContentPaddingHorizontal,vertical: widget.expandedContentPaddingVertical,
          ),
          child: 
          Column
          (
            crossAxisAlignment: widget.expandedContentCrossAxisAlignment,
            children: 
            [
              Focus
              (
                focusNode: expandedAdditionalTextFocusNode,
                child: widget.expandedContentWidget
                
              ),
              Divider(height: widget.expandedContentDividerHeight),

              // Action icons
              Row
              (
                mainAxisAlignment: widget.listActionIconsMainAxisAlignment,
                children: //.toList()
                widget.listActionIconsData.map((actionIconData) 
                {
                  final iconData = actionIconData[0] as IconData;
                  final toolTipLabel = actionIconData[1] as String;
                  final VoidCallback onPressedFunction;
                  if (toolTipLabel == CustomExpansionTile.toolTipEdit) {onPressedFunction = widget.parentWidgetOnEditPressedCallBackFunction;} 
                  else if (toolTipLabel == CustomExpansionTile.toolTipDelete) {onPressedFunction = widget.parentWidgetOnDeletePressedCallBackFunction;} 
                  else if (toolTipLabel == CustomExpansionTile.toolTipShare) {onPressedFunction = widget.parentWidgetOnSharePressedCallBackFunction;} 
                  else {onPressedFunction = () {pu.printd("Expansion tile: unexpected toolTipLabel value: $toolTipLabel");};}

                  return 
                  CustomIconButton
                  (
                    icon: Icon(iconData),
                    toolTipLabel: toolTipLabel,
                    parentWidgetOnPressedCallBackFunction: onPressedFunction,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
