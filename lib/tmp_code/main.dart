import 'package:flutter/material.dart';

import 'screens/participants_group_declaration.dart';

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
      home: const ParticipantsGroupDeclaration(),
    );
  }
}
