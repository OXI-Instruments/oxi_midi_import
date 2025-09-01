import 'package:oxi_midi_import/src/models/mono_pattern.dart';
import 'package:oxi_midi_import/src/models/note.dart';
import 'package:oxi_midi_import/src/models/poly_pattern.dart';

class MidiToPatternConverter {
  static const defaultTicksPerStep = 24;

  static Future<PolyPattern> createPolyPatternFrom(List<Note> notes, int length, {int ticksPerStep = defaultTicksPerStep}) async {
    final stepLength = (length / ticksPerStep).ceil();

    if (stepLength > 128) {
      throw Exception('stepLength is too long: $stepLength');
    }

    List<PolyPatternStep> steps = List.generate(stepLength, (index) {
      return PolyPatternStep.empty();
    });

    try {
      for (final note in notes) {
        final noteStartTicks = note.timestamp;
        final noteEndTicks = note.timestamp + note.duration - 1; // make it shorter by 1 tick due to midi data convention

        final int startIndex = noteStartTicks ~/ ticksPerStep;
        final int endIndex = noteEndTicks ~/ ticksPerStep;
        final int initialOffset = noteStartTicks % ticksPerStep;
        final int endInset = ticksPerStep - noteEndTicks % ticksPerStep;

        for (int stepIndex = startIndex; stepIndex <= endIndex; stepIndex++) {
          // find the first note slot
          final noteIndex = steps[stepIndex].notes.indexOf(-1);
          if (noteIndex != -1) {
            final offsetInTicks = stepIndex == startIndex ? initialOffset : 0;
            final endInsetInTicks = stepIndex == endIndex ? endInset : 0;
            final gateInTicks = ticksPerStep - offsetInTicks - endInsetInTicks;

            steps[stepIndex].notes[noteIndex] = note.note;
            steps[stepIndex].gates[noteIndex] = gateInTicks / ticksPerStep;
            steps[stepIndex].offsets[noteIndex] = offsetInTicks / ticksPerStep;
            steps[stepIndex].velocities[noteIndex] = note.velocity;
          }
        }
      }
    } catch (e) {
      rethrow;
    }

    return PolyPattern(steps: steps);
  }

  static MonoPattern createMonoPatternFrom(List<Note> notes, int length, {int ticksPerStep = defaultTicksPerStep}) {
    // TODO: handle glides for overlapping notes

    final stepLength = (length / ticksPerStep).ceil();

    List<MonoPatternStep> steps = List.generate(stepLength, (index) {
      return MonoPatternStep.empty();
    });

    try {
      for (final note in notes) {
        final noteStartTicks = note.timestamp;
        final noteEndTicks = note.timestamp + note.duration - 1; // make it shorter by 1 tick due to midi data convention

        final int startIndex = noteStartTicks ~/ ticksPerStep;
        final int endIndex = noteEndTicks ~/ ticksPerStep;
        final int initialOffset = noteStartTicks % ticksPerStep;
        final int endInset = ticksPerStep - noteEndTicks % ticksPerStep;
        final int velocity = note.velocity;

        for (int stepIndex = startIndex; stepIndex <= endIndex; stepIndex++) {
          final offsetInTicks = stepIndex == startIndex ? initialOffset : 0;
          final endInsetInTicks = stepIndex == endIndex ? endInset : 0;
          final gateInTicks = ticksPerStep - offsetInTicks - endInsetInTicks;
          steps[stepIndex].note = note.note;
          steps[stepIndex].gate = gateInTicks / ticksPerStep;
          steps[stepIndex].offset = offsetInTicks / ticksPerStep;
          steps[stepIndex].velocity = velocity;
        }
      }
    } catch (e) {
      rethrow;
    }

    return MonoPattern(steps: steps);
  }
}
