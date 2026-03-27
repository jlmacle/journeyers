import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

class ProblemToSolve extends StatefulWidget {
  const ProblemToSolve({super.key});

  @override
  State<ProblemToSolve> createState() => _ProblemToSolveState();
}

class _ProblemToSolveState extends State<ProblemToSolve> {
  final TextEditingController _controller = TextEditingController(text: 'Problem to solve');
  bool _isEditing = false;

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: _isEditing 
          ? TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check, color: greenShade900),
                  onPressed: () => setState(() => _isEditing = false),
                ),
              ),
              onSubmitted: (_) => setState(() => _isEditing = false),
            )
          : 
          Flex(
          direction: Axis.horizontal, 
          children: [
            // Widget 1: Left side
            Container(width: 50),
            
            // Widget 2: The Centered Text
            // Expanded fills the middle gap so Center can work effectively
            Expanded(
              child: Center(
                child: Text(
                _controller.text, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ),
            ),
            
            // Widget 3: Right side
            Container(
              width: 50,
              child: GestureDetector
              (
                child: const Text("✏️"),
                onTap: () => setState(() => _isEditing = true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}