import 'package:intl/intl.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage_externalized_strings.dart';

/// {@category Utils - Generic}
/// Method used to sort sessions by date
/// The list parameter is assumed to be a list of sessions, 
/// with a key DashboardUtils.keyDate for the date values.
Future<List<dynamic>> sortSessionByDateAddJm
({required List<dynamic> list, required String dateFormat, required bool byAscendingDate}) async 
{  
  list.sort((a, b) 
    {
      try
      {
        DateTime dateA = DateFormat(dateFormat).add_jm().parseLoose(a[DashboardUtils.keyDate]);
        DateTime dateB = DateFormat(dateFormat).add_jm().parseLoose(b[DashboardUtils.keyDate]);

        return byAscendingDate ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      }
      catch(e, stacktrace)
      {
        pu.printd("sortSessionByDateAddJm: exception: $e");  
        pu.printd("sortSessionByDateAddJm: exception: $stacktrace");       
      }  
      return 0;    
    });

  return list;   
}

/// {@category Utils - Generic}
/// Method used to sort dashboard sessions by title.
/// The list parameter is assumed to be a list of sessions,
/// with a key DashboardUtils.keyTitle for the title values.
Future<void> sortDashboardSessionsByTitle
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


/// {@category Utils - Generic}
/// Method used to sort lists by title.
/// The list parameter is assumed to be a list of lists,
/// with a key itemTextKey for the label values.
Future<void> sortListsByLabel
({required List<dynamic> list, required bool byAscendingLabel}) async 
{
  if (listDebug) pu.printd("List debug: Lists display: sortListsByLabel: list: $list"); 

  if (byAscendingLabel) 
  {
    list.sort(
      (listDataA, listDataB)
      {
        // The goal is to compare the labels, not the lists 
        var labelA = listDataA[itemTextKey].toString();
        var labelB = listDataB[itemTextKey].toString();      
        return labelA.compareTo(labelB);
      }
    );
  }

  else 
  {
    list.sort(
      // (b,a) => a.compareTo(b) to reverse the alphabetical order
      (listDataB, listDataA)
      {
        // The goal is to compare the labels, not the lists 
        var labelA = listDataA[itemTextKey].toString();
        var labelB = listDataB[itemTextKey].toString();
        return labelA.compareTo(labelB);
      }
    );
  }
}
