import 'package:flutter/material.dart';

import 'participants_group_addition.dart';
import 'participants_groups_listing.dart';


/// ParticipantsGroupDeclaration offers two choices:
///   • Loading a list of previous groups of participants
///   • Adding a new group of participants
class ParticipantsGroupDeclaration extends StatelessWidget {
  const ParticipantsGroupDeclaration({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── title ──────────────────────────────────────────────────
                Text(
                  'Participants list',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What would you like to do?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),

                // ── Option 1. Loading a saved list of participants groups ─────────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ParticipantsGroupsListing(),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Please click\nto load the list\nof previous groups', textAlign: TextAlign.center),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Option 2. Addition of a participants group ─────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ParticipantsGroupAddition(),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Please click\nto add a new group', textAlign: TextAlign.center),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
