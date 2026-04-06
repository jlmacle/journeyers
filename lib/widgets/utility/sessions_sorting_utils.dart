
import 'package:intl/intl.dart';

import 'package:journeyers/utils/project_specific/dashboard/dashboard_utils.dart';

/// {@category Utils}
/// A utility related to sorting.

// Method used to sort sessions by date
// The list parameter is assumed to be a list of sessions, 
// with a key DashboardUtils.keyDate for the date values
// https://api.flutter.dev/flutter/package-intl_intl/DateFormat-class.html 
Future<List<dynamic>> sortSessionByDateAddJm
({required List<dynamic> list, required String dateFormat, required bool byAscendingDate}) async 
{
  list.sort((a, b) 
    {
      DateTime dateA = DateFormat(dateFormat).add_jm().parse(a[DashboardUtils.keyDate]);
      DateTime dateB = DateFormat(dateFormat).add_jm().parse(b[DashboardUtils.keyDate]);
      return byAscendingDate ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

  return list;   
}

// Method used to sort by title
// The list parameter is assumed to be a list of sessions,
// with a key DashboardUtils.keyTitle for the title values
Future<List<dynamic>> sortByTitle
({required List<dynamic> list, required bool byAscendingTitle}) async 
{
  list.sort((a, b) 
  {
    String titleA = (a[DashboardUtils.keyTitle]).toString().toLowerCase();
    String titleB = (b[DashboardUtils.keyTitle]).toString().toLowerCase();
    
    return byAscendingTitle 
        ? titleA.compareTo(titleB) 
        : titleB.compareTo(titleA);
  });

  return list;
}
