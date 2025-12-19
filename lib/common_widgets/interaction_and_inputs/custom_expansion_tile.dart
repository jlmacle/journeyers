import 'package:flutter/material.dart';

import '../../app_themes.dart';
import '../interaction_and_inputs/custom_icon_button.dart';

/// A customizable expansion tile

class CustomExpansionTile extends StatefulWidget 
{
  /// The text to display when the tile is not expanded
  final String text;
  /// The font for the text to display when the tile is not expanded
  final FontWeight textFontWeight;
  /// The icon used to suggest that the tile is expandable
  final Icon actionIconToExpand;
  /// The horizontal padding for the expanded content
  final double expandedContentPaddingHorizontal;
  /// The vertical padding for the expanded content
  final double expandedContentPaddingVertical;
  /// The horizontal location of the expanded content
  final CrossAxisAlignment expandedContentCrossAxisAlignment;
  /// The text displayed in the expanded content
  final String expandedAdditionalText;
  /// The height of a divider under the additional text
  final double dividerHeight;
  /// The callback function called to edit from the expansion tile
  final VoidCallback onEditPressed;
  /// The callback function called to delete from the expansion tile
  final VoidCallback onDeletePressed;
  /// The callback function called to share from the expansion tile
  final VoidCallback onSharePressed;
  /// A list of  [iconData, toolTipLabel, callBackFunction] values
  final List<List<dynamic>> listActionsIconsData;
  /// The horizontal location of the icon(s)
  final MainAxisAlignment listActionsIconsMainAxisAlignment;

  static const String editStr = 'Edit';
  static const String deleteStr = 'Delete';
  static const String shareStr = 'Share';

  const CustomExpansionTile
  ({
    super.key,
    this.text = "Default tile text",
    this.textFontWeight = FontWeight.w600,
    this.actionIconToExpand = const Icon(Icons.expand_more),
    this.expandedContentPaddingHorizontal = 16.0,
    this.expandedContentPaddingVertical = 8.0,
    this.expandedContentCrossAxisAlignment = CrossAxisAlignment.start,
    this.expandedAdditionalText = "Default expanded additional text",
    this.listActionsIconsMainAxisAlignment = MainAxisAlignment.end,
    this.dividerHeight = 20.5,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onSharePressed,
    this.listActionsIconsData = const
    [
      [Icons.edit, editStr, null],
      [Icons.delete, deleteStr,null],
      [Icons.share, shareStr, null],
    ],
    

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
      trailing: widget.actionIconToExpand,
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
                  widget.expandedAdditionalText,
                  style: appTheme.textTheme.bodyMedium,
                ),
              ),
              Divider(height: widget.dividerHeight),

              // Action icons
              Row
              (
                mainAxisAlignment : widget.listActionsIconsMainAxisAlignment,
                children:               
                widget.listActionsIconsData.map
                (
                  (actionIconData) 
                  {
                    final iconData = actionIconData[0] as IconData;
                    final toolTipLabel = actionIconData[1] as String;
                    final VoidCallback onPressedFunction;
                    if (toolTipLabel == CustomExpansionTile.editStr) 
                    {
                      onPressedFunction = widget.onEditPressed;
                    }
                    else if (toolTipLabel == CustomExpansionTile.deleteStr)
                    {
                      onPressedFunction = widget.onDeletePressed;
                    }
                    else if (toolTipLabel == CustomExpansionTile.shareStr)
                    {
                      onPressedFunction = widget.onSharePressed;
                    }
                    else {onPressedFunction = (){};}

                    return CustomIconButton(icon: Icon(iconData), toolTipLabel: toolTipLabel, onPressedFunction: onPressedFunction );
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