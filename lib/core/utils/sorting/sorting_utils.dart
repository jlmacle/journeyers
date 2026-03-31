
import 'package:intl/intl.dart';

import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';

/// {@category Utils}
/// A utility related to sorting.
// Method used to sort by date
List<dynamic> sortByDateAddJm
({required List<dynamic> list, required String dateFormat, required bool byAscendingDate})
{
  list.sort((a, b) 
    {
      DateTime dateA = DateFormat(dateFormat).add_jm().parse(a[DashboardUtils.keyDate]);
      DateTime dateB = DateFormat(dateFormat).add_jm().parse(b[DashboardUtils.keyDate]);
      return byAscendingDate ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

  return list;   
}