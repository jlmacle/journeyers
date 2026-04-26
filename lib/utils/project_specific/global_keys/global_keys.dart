import 'package:flutter/material.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2c_dashboard_filtering_by_keywords.dart';

// Pages
final GlobalKey<CAPageState> caPageKey = GlobalKey<CAPageState>(debugLabel:'context-analyses-page');
final GlobalKey<GPSPageState> gpsPageKey = GlobalKey<GPSPageState>(debugLabel:'group-problem-solvings-page');

// Process pages
GlobalKey<CAProcessState> caProcessKey = GlobalKey(debugLabel:'context-analysis-process');
GlobalKey<GPSProcessState> gpsProcessKey = GlobalKey(debugLabel:'group-problem-solving-process');

// Dashbooard widgets
GlobalKey<DashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKeyCA = GlobalKey(debugLabel: 'context-analyses-dashboard-sorting-by-keywords');
GlobalKey<DashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKeyGPS = GlobalKey(debugLabel: 'group-problem-solvings-dashboard-sorting-by-keywords');

// Global key for the context forms
final GlobalKey<CAFormState> formKeyCA = GlobalKey(debugLabel:'context-analysis-form');

// CA Headings

final GlobalKey<CustomHeadingState> balanceIssueHeadingKey   = GlobalKey();
final GlobalKey<CustomHeadingState> workplaceIssueHeadingKey = GlobalKey();
final GlobalKey<CustomHeadingState> legacyIssueHeadingKey    = GlobalKey();
final GlobalKey<CustomHeadingState> anotherIssueHeadingKey   = GlobalKey();