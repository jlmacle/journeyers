
import 'package:intl/intl.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';

/// {@category Utils - Generic}
/// Method used to sort sessions by date
/// The list parameter is assumed to be a list of sessions, 
/// with a key DashboardUtils.keyDate for the date values.
/// https://api.flutter.dev/flutter/package-intl_intl/DateFormat-class.html 
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

/// {@category Utils - Generic}
/// Method used to sort by title
/// The list parameter is assumed to be a list of sessions,
/// with a key DashboardUtils.keyTitle for the title values.
Future<void> sortByTitle
({required List<dynamic> list, required bool byAscendingTitle}) async 
{
  if (byAscendingTitle) 
  {
    list.sort(
      (sessionItemA, sessionItemB)
      {
        // The goal is to compare the titles, not the sessions 
        var titleA = sessionItemA[DashboardUtils.keyTitle].toString();
        var titleB = sessionItemB[DashboardUtils.keyTitle].toString();      
        return titleA.compareTo(titleB);
      }
    );
  }

  else 
  {
    list.sort(
      // (b,a) => a.compareTo(b) to reverse the alphabetical order
      (sessionItemB, sessionItemA)
      {
        // The goal is to compare the titles, not the sessions 
        var titleA = sessionItemA[DashboardUtils.keyTitle].toString();
        var titleB = sessionItemB[DashboardUtils.keyTitle].toString();
        return titleA.compareTo(titleB);
      }
    );
  }
}
