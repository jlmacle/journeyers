// Line for automated processing
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d chrome
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d linux
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d macos
// flutter run -t ./test/pages/context_analyses_preview_visual_testing.dart -d windows
// Line for automated processing

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';


void main() 
{
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatelessWidget 
{
  const MyTestingApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      theme: appTheme,
      home: MyTestingAppPreview(),
    );
  }
}

class MyTestingAppPreview extends StatelessWidget 
{
  MyTestingAppPreview({super.key});

  final Map<String, dynamic> sectionsIndividual = 
  {
    "title": "As an individual: What problem am I trying to solve?",
    "questions": 
    [
      {
        "title": "A Balance Issue?",
        "items": 
        [
          {"text": "To balance studies and household life?", "note": "", "checked":"yes"},
          {"text": "To balance accessing income and household life?", "note": "", "checked":""},
          {"text": "To balance earning an income and household life?", "note": "A note about balancing earning an income and household life", "checked":"yes"},
          {"text": "To balance helping others and household life?", "note": "", "checked":""},
        ]
      },
      {
        "title": "A Workplace Issue?",
        "items": 
        [
          {"text": "To solve a need to be more appreciated at work?", "note": "", "checked":""},
          {"text": "To solve a need to remain appreciated at work?", "note": "", "checked":""},
        ]
      },
      {
        "title": "A Legacy Issue?",
        "items": 
        [
          {"text": "To have better legacies to our children/others?", "note": "", "checked":"yes"},
        ]
      },
      {
        "title": "Is the issue of another type?",
        "items": 
        [
          {"noteTextField": "A note about the other type of issue"},
        ]
      }
    ]
  };


  final Map<String, dynamic> sectionsGroup = 
  {
  "title": "As a member of groups/teams: What problem(s) are we trying to solve?",
  "questions": 
  [
    {
      "title": "What problem(s) are the groups/teams trying to solve?",
      "items": 
      {
        "note": "",           
      }
    },
    {
      "title": "Am I trying to solve the same problem(s) as my groups/teams?",
      "items": 
      {
        "answer": "Yes",
        "note": "A note about if I'm trying to solve the same problem(s) as my groups/teams",           
      }
    },
    {
      "title": "Is entering the group problem-solving process consistent with harmony at home?",
      "items": 
      {
        "answer": "Yes",
        "note": "A note about the consistency of entering the group problem-solving process with harmony at home",           
      }
    },
    {
      "title": "Is entering the group problem-solving process consistent with appreciability at work?",
      "items": 
      {
        "answer": "Yes",
        "note": "",           
      }
    },        
    {
      "title": "Is entering the group problem-solving process consistent with my income earning ability?",
      "items": 
      {
        "answer": "",
        "note": "",           
      }
    },
  ]
};


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: const Text("MyTestingApp")),
      body: SingleChildScrollView
      (
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
              Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Padding
                  (
                    padding: const EdgeInsets.all(16.0),
                    child: Text
                    (
                      sectionsIndividual['title'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),

                  // Questions and potential answers for the individual perspective
                  ...
                  [
                    // "questions": list of maps with "title" and "items" as keys
                    // If no checkbox checked and no value for the text field only, a message to display
                    if 
                    (
                      sectionsIndividual['questions'].where
                      (
                        (question) => 
                          (question['items'] as List).any((item) => item['checked'] == "yes") 
                          ||
                          (question['items'] as List).any((item) => item['noteTextField'] != null && item['noteTextField'] != "")
                      ).isEmpty
                    )
                      const Padding
                      (
                        padding: EdgeInsets.only(left:16, top:8, bottom:8),
                        child: Text
                        (
                          'No question checked and no data in the last text field.',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                        ),
                      )
                    else
                      // Otherwise, an expansion tile for each title level 3 with a checked checkbox or a text field answer
                      for 
                      (
                        var question in sectionsIndividual['questions'].where
                        (
                          (question) => 
                            (question['items'] as List).any((item) => item['checked'] == 'yes') 
                            ||
                            (question['items'] as List).any((item) => item['noteTextField'] != null && item['noteTextField'] != "")
                        )
                     
                      )
                        ExpansionTile
                        (
                          // to remove the borders
                          shape: Border.all(color: Colors.transparent, width: 0),
                          initiallyExpanded: true,
                          title: Text
                          (
                            question['title'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: 
                          [
                            // "items" in the individual perspective: list of maps with "checked", "note" and "noteTextField" as keys
                            for 
                            (var item in (question['items'] as List).where
                              (
                                (item) => item['checked'] == 'yes' 
                                ||
                                item['noteTextField'] != null && item['noteTextField'] != ""                          
                              )
                            )
                              ListTile
                              (
                                leading: Icon
                                (
                                  item['checked'] != null
                                  ? Icons.check_box
                                  : Icons.text_snippet
                                ),
                                title: Text
                                (
                                  item['text'] != null 
                                  ? item['text']
                                  :(item['noteTextField'] != null && item['noteTextField'] != "")
                                  ? "Notes: ${item['noteTextField']}"
                                  : "",
                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                ),
                                subtitle: (item['note'] != null)
                                  ? Text("Notes: ${item['note']}")
                                  : null,
                              ),
                          ],
                        ),
                    ],
                ],
              ),
              Divider(thickness: 3, color: Colors.black),
              Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Padding
                  (
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom:8),
                    child: Text
                    (
                      sectionsGroup['title'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Questions and potential answers for the group perspective
                  for (var question in sectionsGroup['questions'])
                    ExpansionTile
                    (
                      // to remove the borders
                      shape: Border.all(color: Colors.transparent, width: 0),                      
                      initiallyExpanded: true, 
                      title: Text
                      (
                        question['title'], 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      children: 
                      [
                        ListTile
                        (
                          leading: Icon(Icons.text_snippet),
                          title: Text                            
                          ( 
                            question["items"]["answer"] == null
                            ?
                            'Notes: ${question["items"]["note"] ?? ""}'
                            :
                            'Answer: ${question["items"]["answer"] ?? ""}'
                            '\nNotes: ${question["items"]["note"] ?? ""}'
                          ),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}