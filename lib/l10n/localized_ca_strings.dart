import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedCAStrings
{
  AppLocalizations? _l10n;

  // CA dashboard title
  var dashboardTitle = "";

  var invitationToUnfoldExpansionTile = "";

  // Segmented button options
  var yes = "";
  var no = "";
  var iDontKnow = "";
          

  LocalizedCAStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);
    
    dashboardTitle = _l10n?.ca_dashboard_title ?? "Issue with the dashboard title";

    invitationToUnfoldExpansionTile = _l10n?.ca_process_invitation_to_unfold_expansion_tile ?? "Issue with the l10n for 'Please click to unfold'";
  
    yes =  _l10n?.segmented_button_yes ?? "Issue with the l10n for Yes";
    no = _l10n?.segmented_button_no ?? "Issue with the l10n for No";
    iDontKnow = _l10n?.segmented_button_I_don_t_know ?? "Issue with the l10n for I don't know";
          
  
  }

}
