import 'package:flutter/material.dart';

import 'participants_lists/load_text_list_or_new_text_list.dart';

void main() => runApp(const ParticipantListsApp());

class ParticipantListsApp extends StatelessWidget {
  const ParticipantListsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Participants list',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoadTextListOrNewTextList(),
    );
  }
}
