import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dashboard/dashboard_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/database/participants_lists_db_externalized_strings.dart";

/// {@category Utils - Generic}
/// Method used to sort sessions by date.
/// The list parameter is assumed to be a list of sessions, 
/// with a key DashboardUtils.keyDateISO8601 for the date ISO 8601 values.
Future<List<dynamic>> sortSessionByDate
({
  required List<dynamic> list, 
  required bool byAscendingDate
}) async 
{  
  list.sort((a, b) 
    {
      try
      {
        
        String dateA = a[DashboardUtils.keyDateISO8601];
        String dateB = b[DashboardUtils.keyDateISO8601];

        return byAscendingDate ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      }
      catch(e, s)
      {
        pu.printd("sortSessionByDate: exception: $e: $s");      
      }  
      return 0;    
    });

  if (sessionMetadataDebug && list.isNotEmpty) pu.printd("Session Metadata: Sorted by date:");
  for (var item in list)
  {
    if (sessionMetadataDebug) pu.printd("Session Metadata: ${item[DashboardUtils.keyDateISO8601]}");
  }

  return list;   
}

/// {@category Utils - Generic}
/// Method used to sort dashboard sessions by title.
/// The list parameter is assumed to be a list of sessions,
/// with a key DashboardUtils.keyTitleLowerCase for the lower case title values.
Future<void> sortDashboardSessionsByTitle
({required List<dynamic> list, required bool byAscendingTitle}) async 
{
  if (byAscendingTitle) 
  {
    list.sort(
      (sessionItemA, sessionItemB)
      {
        // The goal is to compare the titles, not the sessions 
        var titleA = sessionItemA[DashboardUtils.keyTitleLowerCase].toString();
        var titleB = sessionItemB[DashboardUtils.keyTitleLowerCase].toString();      
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
        var titleA = sessionItemA[DashboardUtils.keyTitleLowerCase].toString();
        var titleB = sessionItemB[DashboardUtils.keyTitleLowerCase].toString();
        return titleA.compareTo(titleB);
      }
    );
  }

  if (sessionMetadataDebug) pu.printd("Session Metadata: Sorted by title:");
  for (var item in list)
  {
    if (sessionMetadataDebug) pu.printd("${item[DashboardUtils.keyTitleLowerCase]}");
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
