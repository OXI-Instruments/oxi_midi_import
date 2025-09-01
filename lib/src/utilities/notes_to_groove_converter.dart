import 'dart:math';
import '../models/note.dart';
import '../models/groove.dart';

class NotesToGrooveConverter {
  // Converts a list of `Note`s to a groove.
  // Accents and velocities are bipolar, timing range [-40, 40], accents range [-64,64].
  static Groove convertNotesToGroove(List<Note> notes, int ticksPer16th, int length) {
    final stepCount = min((length / ticksPer16th).ceil(), 32);
    Map<int, List<Note>> notesPerStep = {};

    for (int i = 0; i < stepCount; i++) {
      notesPerStep[i] = [];
      final startTick = i * ticksPer16th - ticksPer16th / 2;
      final endTick = startTick + ticksPer16th;
      for (final note in notes) {
        if (note.timestamp > startTick && note.timestamp <= endTick) {
          notesPerStep[i]!.add(note);
        }
      }
    }

    List<int> accents = [];
    List<int> timing = [];
    for (int i = 0; i < stepCount; i++) {
      final stepNotes = notesPerStep[i]!;
      final stepStartTick = i * ticksPer16th;
      if (stepNotes.isEmpty) {
        timing.add(0);
        accents.add(-64);
      } else {
        // pick the first note in the step
        final firstNote = stepNotes.first;
        int offset = ((firstNote.timestamp - stepStartTick) / ticksPer16th * 100).floor();
        offset = offset.clamp(-40, 40); // clamp to [-40, 40]
        timing.add(offset);
        accents.add(firstNote.velocity - 64);
      }
    }

    return Groove(timing: timing, accents: accents);
  }
}
