import 'package:flutter/widgets.dart';

import "package:journeyers/l10n/app_localizations.dart";

 Set<String> getLevel2Titles(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return 
  {
    l10n?.ca_process_individual_perspective_title_question
        ?? "Issue with the title question for the individual perspective",
    "As a member of groups/teams: What problem(s) are we trying to solve?"
  };
}