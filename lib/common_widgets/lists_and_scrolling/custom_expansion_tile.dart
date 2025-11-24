import 'package:flutter/material.dart';

import '../../app_themes.dart';
import '../interaction_and_inputs/custom_icon_button.dart';

/// A customizable expansion tile

class CustomExpansionTile extends StatefulWidget 
{
  /// The text to display when the tile is not expanded
  final String headerText;
  /// The font for the text to display when the tile is not expanded
  final FontWeight headerFontWeight;
  /// The icon used to suggest that the tile is expandable
  final Icon actionIconToExpand;
  /// The horizontal padding for the expanded content
  final double expandedContentPaddingHorizontal;
  /// The vertical padding for the expanded content
  final double expandedContentPaddingVertical;
  /// The horizontal location of the expanded content
  final CrossAxisAlignment expandedTextCrossAxisAlignment;
  /// The text displayed in the expanded content
  final String expandedAdditionalText;
  /// The height of a divider under the additional text
  final double dividerHeight;
  /// A list of  [iconData, toolTipLabel, callBackFunction] values
  final List<List<dynamic>> listActionsIconsData;
  /// The horizontal location of the icon(s)
  final MainAxisAlignment listActionsIconsMainAxisAlignment;

  const CustomExpansionTile
  ({
    super.key,
    this.headerText = "Default tile text",
    this.headerFontWeight = FontWeight.w600,
    this.actionIconToExpand = const Icon(Icons.expand_more),
    this.expandedContentPaddingHorizontal = 16.0,
    this.expandedContentPaddingVertical = 8.0,
    this.expandedTextCrossAxisAlignment = CrossAxisAlignment.start,
    this.expandedAdditionalText = "Default expanded additional text",
    this.listActionsIconsMainAxisAlignment = MainAxisAlignment.end,
    this.dividerHeight = 20.5,
    this.listActionsIconsData = const
    [
      [Icons.edit, 'Edit', null],
      [Icons.delete, 'Delete',null],
      [Icons.share, 'Share', null],
    ],
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile
    (
      title: Text
      (
        widget.headerText,
        style: TextStyle(fontWeight: widget.headerFontWeight),
      ),
      trailing: widget.actionIconToExpand,
      children: <Widget>
      [
        Padding
        (padding: EdgeInsets.symmetric(horizontal: widget.expandedContentPaddingHorizontal, vertical: widget.expandedContentPaddingVertical),
        child: Column
        (
          crossAxisAlignment: widget.expandedTextCrossAxisAlignment,
          children: 
          [
            Text
            (
              widget.expandedAdditionalText,
              style: appTheme.textTheme.bodyMedium,
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
                  final onPressedFunction = actionIconData[2] as VoidCallback?;

                  return CustomIconButton(icon: Icon(iconData), toolTipLabel: toolTipLabel, onPressedFunction: onPressedFunction ?? (){} );
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