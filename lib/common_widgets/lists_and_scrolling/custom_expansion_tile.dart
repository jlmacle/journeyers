import 'package:flutter/material.dart';

import '../../app_themes.dart';
import '../interaction_and_inputs/custom_icon_button.dart';

class CustomExpansionTile extends StatefulWidget {
  final String tileText;
  final FontWeight fontWeightHeader;
  final Color colorBackgroundCollapsed;
  final Color colorBackgroundExpanded;
  final Color colorTextCollapsed;
  final Color colorTextExpanded;
  final Color colorIconCollapsed;
  final Color colorIconExpanded;
  final Icon trailingIcon;
  final double paddingHorizontal;
  final double paddingVertical;
  final CrossAxisAlignment crossAxisAlignment;
  final String expandedAdditionalText;
  final double dividerHeight;
  final List<List<dynamic>> listActionsIconsData;

  const CustomExpansionTile
  ({
    super.key,
    this.tileText = "Default tile text",
    this.fontWeightHeader = FontWeight.w600,
    this.colorBackgroundCollapsed = Colors.white,
    this.colorBackgroundExpanded = Colors.white,
    this.colorTextCollapsed = Colors.black,
    this.colorTextExpanded = Colors.black,
    this.colorIconCollapsed = Colors.purple,
    this.colorIconExpanded = Colors.purple,
    this.trailingIcon = const Icon(Icons.expand_more),
    this.paddingHorizontal = 16.0,
    this.paddingVertical = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.expandedAdditionalText = "Default expanded additional text",
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
        widget.tileText,
        style: TextStyle(fontWeight: widget.fontWeightHeader),
      ),
      trailing: widget.trailingIcon,
      children: <Widget>
      [
        Padding
        (padding: EdgeInsets.symmetric(horizontal: widget.paddingHorizontal, vertical: widget.paddingVertical),
        child: Column
        (
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