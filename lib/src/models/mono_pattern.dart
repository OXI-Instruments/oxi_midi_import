import 'dart:math';
import 'package:oxi_midi_import/src/models/poly_pattern.dart';

class MonoPatternStep {
  int note;
  double gate;
  double offset;
  int velocity;

  MonoPatternStep({required this.note, required this.gate, required this.offset, required this.velocity});

  factory MonoPatternStep.empty() {
    return MonoPatternStep(note: -1, gate: 0, offset: 0, velocity: 100);
  }
}

/// A model to represent a monophonic pattern.
class MonoPattern {
  static const _kMidiNoteMin = 0;
  static const _kMidiNoteMax = 127;

  final List<MonoPatternStep> steps;

  const MonoPattern({required this.steps});

  factory MonoPattern.empty() {
    return MonoPattern(steps: List.generate(128, (index) => MonoPatternStep.empty()));
  }

  @override
  String toString() {
    final List<String> lines = [];

    for (int j = 0; j < 8; j++) {
      String line = '';

      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        final note = step.note;
        line += note == -1 ? ' ' : '[]';
      }
      lines.add(line);
    }

    return lines.join('\n');
  }

  int get minNote => steps.fold(_kMidiNoteMax, (a, b) {
    if (b.note < 0) return a;
    return min(a, b.note);
  });

  int get minNoteInFirstBar {
    final firstBarNotes = steps.sublist(0, min(16, steps.length));
    if (firstBarNotes.isEmpty) return 48;
    return firstBarNotes.fold(_kMidiNoteMax, (a, b) {
      if (b.note < 0) return a;
      return min(a, b.note);
    });
  }

  int get maxNote => steps.fold(_kMidiNoteMin, (a, b) => max(a, b.note + 1));

  PolyPattern toPolyPattern(int sequenceLength) {
    final polySteps = steps.map((step) {
      final notes = List.generate(sequenceLength, (index) => -1);
      notes[0] = step.note;
      final gates = List.generate(sequenceLength, (index) => 0.0);
      gates[0] = step.gate;
      final offsets = List.generate(sequenceLength, (index) => 0.0);
      offsets[0] = step.offset;
      final velocities = List.generate(sequenceLength, (index) => 0);
      velocities[0] = step.velocity;

      return PolyPatternStep(notes: notes, gates: gates, offsets: offsets, velocities: velocities);
    }).toList();

    return PolyPattern(steps: polySteps);
  }
}
