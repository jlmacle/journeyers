import 'package:flutter/material.dart';

import '../../app_themes.dart';
import '../interaction_and_inputs/custom_icon_button.dart';


/// {@category Custom widgets}
/// A customizable expansion tile.
class CustomExpansionTile extends StatefulWidget 
{
  /// The text to display when the tile is not expanded.
  final String text;
  /// The font weight for the text to display when the tile is not expanded.
  final FontWeight textFontWeight;
  /// The icon used to suggest that the tile is expandable.
  final Icon actionIconSuggestingExpansion;
  /// The horizontal padding for the expanded content.
  final double expandedContentPaddingHorizontal;
  /// The vertical padding for the expanded content.
  final double expandedContentPaddingVertical;
  /// The horizontal location of the expanded content.
  final CrossAxisAlignment expandedContentCrossAxisAlignment;
  /// The text displayed in the expanded content.
  final String expandedContentText;
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
    this.textFontWeight = FontWeight.w600,
    this.actionIconSuggestingExpansion = const Icon(Icons.expand_more),
    this.expandedContentPaddingHorizontal = 16.0,
    this.expandedContentPaddingVertical = 8.0,
    this.expandedContentCrossAxisAlignment = CrossAxisAlignment.start,
    this.expandedContentText = "Default expanded additional text",
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
  @override
  Widget build(BuildContext context) 
  {
    FocusNode expandedAdditionalTextFocusNode = FocusNode();
    return ExpansionTile
    (
      title: Focus
      (
        focusNode: expandedAdditionalTextFocusNode,
        child: Text
        (
          widget.text,
          style: TextStyle(fontWeight: widget.textFontWeight),
        ),
      ),
      trailing: widget.actionIconSuggestingExpansion,
      children: <Widget>
      [
        Padding
        (
          padding: EdgeInsets.symmetric(horizontal: widget.expandedContentPaddingHorizontal, vertical: widget.expandedContentPaddingVertical),
          child: Column
          (
            crossAxisAlignment: widget.expandedContentCrossAxisAlignment,
            children: 
            [
              Focus
              (
                focusNode: expandedAdditionalTextFocusNode,
                child: Text
                (
                  widget.expandedContentText,
                  style: appTheme.textTheme.bodyMedium,
                ),
              ),
              Divider(height: widget.expandedContentDividerHeight),

              // Action icons
              Row
              (
                mainAxisAlignment : widget.listActionIconsMainAxisAlignment,
                children:               
                widget.listActionIconsData.map
                (
                  (actionIconData) 
                  {
                    final iconData = actionIconData[0] as IconData;
                    final toolTipLabel = actionIconData[1] as String;
                    final VoidCallback onPressedFunction;
                    if (toolTipLabel == CustomExpansionTile.toolTipEdit) 
                    {
                      onPressedFunction = widget.parentWidgetOnEditPressedCallBackFunction;
                    }
                    else if (toolTipLabel == CustomExpansionTile.toolTipDelete)
                    {
                      onPressedFunction = widget.parentWidgetOnDeletePressedCallBackFunction;
                    }
                    else if (toolTipLabel == CustomExpansionTile.toolTipShare)
                    {
                      onPressedFunction = widget.parentWidgetOnSharePressedCallBackFunction;
                    }
                    else {onPressedFunction = (){};}

                    return CustomIconButton(icon: Icon(iconData), toolTipLabel: toolTipLabel, parentWidgetOnPressedCallBackFunction: onPressedFunction);
                  }
                )
                .toList(),              
              )
            ],
          ),
        )
      ],
    );
  }
}