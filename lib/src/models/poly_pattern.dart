import 'dart:math';
import 'package:collection/collection.dart';

class PolyPatternStep {
  List<int> notes;
  List<double> gates;
  List<double> offsets;
  List<int> velocities;

  PolyPatternStep({required this.notes, required this.gates, required this.offsets, required this.velocities});

  factory PolyPatternStep.empty() {
    return PolyPatternStep(
      notes: List.generate(7, (index) => -1),
      gates: List.generate(7, (index) => 0),
      offsets: List.generate(7, (index) => 0),
      velocities: List.generate(7, (index) => 100),
    );
  }
}

/// A model to represent a polyphonic pattern internally.
class PolyPattern {
  static const kMidiNoteMin = 0;
  static const kMidiNoteMax = 127;

  final List<PolyPatternStep> steps;

  const PolyPattern({required this.steps});

  factory PolyPattern.empty() {
    return PolyPattern(steps: List.generate(128, (index) => PolyPatternStep.empty()));
  }

  @override
  String toString() {
    final List<String> lines = [];

    for (int j = 0; j < 7; j++) {
      String line = '';

      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];

        final note = step.notes[j];

        line += note == -1 ? ' ' : '[]';
      }
      lines.add(line);
    }

    return lines.join('\n');
  }

  int get minNote => steps.fold(kMidiNoteMax, (a, b) {
    final activeNotes = b.notes.where((e) => e >= 0);
    if (activeNotes.isEmpty) return a;
    return min(a, activeNotes.min);
  });

  int get minNoteInFirstBar {
    final firstBarNotes = steps.sublist(0, min(16, steps.length));
    if (firstBarNotes.isEmpty) return 48;
    return firstBarNotes.fold(kMidiNoteMax, (a, b) {
      final activeNotes = b.notes.where((e) => e >= 0);
      if (activeNotes.isEmpty) return a;
      return min(a, activeNotes.min);
    });
  }

  int get maxNote => steps.fold(kMidiNoteMin, (a, b) => max(a, b.notes.max + 1));
}
