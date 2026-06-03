import 'package:flutter/material.dart';

import 'typedefs.dart';

// Method used to build an item of a list. 
// A function parameter produces each list item.
Widget _buildListItem
({
  required dynamic listItem, 
  required FunctionDynamicToWidget listItemBuilder
})
 {
  return listItemBuilder(dynamicParam: listItem);
 }

// Method used to build a list of items. 
// The items can have sub-items.
// The list is a map with labels as keys, and dynamic values.
Widget buildList
({
  required Map<String, dynamic> listAsAMap, 
  required FunctionDynamicToWidget listItemBuilder,
  double paddingLeft = 8,
  double paddingRight = 8,
  double paddingBottom = 8,
  double paddingTop = 8,
  double dividerHeight = 1
})
{
  return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight, bottom: paddingBottom, top: paddingTop),
      itemCount: listAsAMap.length,
      separatorBuilder: (_, __) => Divider(height: dividerHeight),
      itemBuilder: (context, index) {                
        var sortedLabels = listAsAMap.keys.toList()..sort();
        Map<String, dynamic> listItem = {sortedLabels[index]: listAsAMap[sortedLabels[index]]};

        return _buildListItem(listItem: listItem, listItemBuilder: listItemBuilder);
      }
  );
}