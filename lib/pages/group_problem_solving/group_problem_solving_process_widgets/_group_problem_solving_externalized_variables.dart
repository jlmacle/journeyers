import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";

// GPSGroupMoods
const editEmoji = "✏️";
const addEmoji = "➕";
const identifierColors = [greenShade900, orange, red];

// GPSProblemToSolveDeclaration
const gpsProcessTitlePlaceholder = "Problem To Solve";
const gpsProcessTitleTextFieldHint = "Enter title or select below";

// GPSChecklist
const checkListTitle = "Checklist";
const rectangleColor = orangeShade900;
Map<String, bool> checklistItems = {
    "Can we get feedback about people’s emotions?": false,
    "Is our context analysis done?": false,
    "Is the group open to using the app for group problem-solving?": false,    
    "Is the group emotionally ready to problem-solve?": false,    
    "Did we agree on what to do if emotions become problematic?": false,
    "Do we agree on the problem that needs to be solved?": false,
    "Did we agree on the order in which to offer the ideas?":false,
    "Can we find reasons why presenting or receiving the ideas, in a neutral tone, could be important?":false,
    "Do we need to further our context analysis?": false,
  };
const checklistItemCheckedColor = Colors.green;
const closeChecklistTooltipLabel = "Close checklist";

// GPSKeywordsDeclaration
const keywordsDeclarationTitle = "Keywords";
const closeGPSKeywordsDeclarationTooltipLabel = "Please click to close the keywords declaration page";

// GPSIdeasList
const ideasListTitle = "List of ideas";
const ideasListPlaceholder = "No ideas added yet.";

// GPSNewIdea
const newIdeaTextFieldHint = "Please enter an idea.";
const overlayClosingTooltip = "Close overlay";

// GPSProcess
const editIdentifierLabel = "Edit Value";
const singleDeletionLabel = "Clear\nOne";
const bulkDeletionLabel = "Clear\nAll";

// NewParticipantsKeywordsDeclaration
const closeGroupKeywordsDeclarationTooltipLabel = "Please click to close the keywords declaration page";

