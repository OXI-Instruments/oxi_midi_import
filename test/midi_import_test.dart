import 'dart:io';

import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:oxi_midi_import/oxi_midi_import.dart';
import 'package:oxi_midi_import/src/utilities/midi_event_helpers.dart';
import 'package:oxi_midi_import/src/utilities/midi_to_pattern_converter.dart';
import 'package:test/test.dart';

import 'utilities/file_loader.dart';

void main() {
  test('MIDI import for poly pattern', () async {
    final data = loadTestAsset('test/assets/chords.mid');

    final midi = MidiParser().parseMidiFromBuffer(data);
    final length = MidiEventHelpers.getTrackLength(midi.tracks[0]);
    final notes = MidiEventHelpers.notesFromMidiEvents(midi.tracks[0]);

    final pattern = await MidiToPatternConverter.createPolyPatternFrom(notes, length);

    expect(pattern.steps.length, 16);
  });

  test('MIDI import for Reason pattern with one note', () async {
    final file = File('test/assets/reason-export-test1.mid');
    final pattern = await MonoPatternImporter.importPattern(file);

    expect(pattern.steps.length, equals(16));
    expect(pattern.steps[0].gate, 1);
    expect(pattern.steps[1].gate, 1);
    expect(pattern.steps[2].gate, 1);
    expect(pattern.steps[3].gate, closeTo(1, 0.05));
    for (int i = 4; i < 16; i++) {
      expect(pattern.steps[i].gate, 0);
    }
  });

  test('MIDI import for Reason 8 bar on grid poly pattern with different velocities', () async {
    final file = File('test/assets/reason-export-test5.mid');
    final pattern = await PolyPatternImporter.importPattern(file);

    // 8 bars with 16 steps each
    expect(pattern.steps.length, equals(8 * 16));

    verifyNotes(pattern, startStep: 0, endStep: 32, notes: [0, 60, 63, 67, 72, 76, 127]);
    verifyTiedNoteGates(pattern, startStep: 0, endStep: 32, gates: [1, 1, 1, 1, 1, 1, 1]);
    verifyNoteOffsets(pattern, startStep: 0, endStep: 32, offsets: [0, 0, 0, 0, 0, 0, 0]);
    verifyNoteVelocities(
      pattern,
      startStep: 0,
      endStep: 32,
      velocities: [1, 100, 100, 100, 100, 100, 127],
    );

    verifyNotes(pattern, startStep: 32, endStep: 64, notes: [46, 60, 64, 67, 71, 76, 82]);
    verifyTiedNoteGates(pattern, startStep: 32, endStep: 64, gates: [1, 1, 1, 1, 1, 1, 1]);
    verifyNoteOffsets(pattern, startStep: 32, endStep: 64, offsets: [0, 0, 0, 0, 0, 0, 0]);
    verifyNoteVelocities(
      pattern,
      startStep: 32,
      endStep: 64,
      velocities: [100, 80, 100, 100, 100, 100, 100],
    );

    verifyNotes(pattern, startStep: 64, endStep: 80, notes: [46, 57, 62, 67, 69]);
    verifyTiedNoteGates(pattern, startStep: 64, endStep: 80, gates: [1, 1, 1, 1, 1]);
    verifyNoteOffsets(pattern, startStep: 64, endStep: 80, offsets: [0, 0, 0, 0, 0]);
    verifyNoteVelocities(pattern, startStep: 64, endStep: 80, velocities: [100, 100, 100, 100, 100]);

    verifyNotes(pattern, startStep: 80, endStep: 96, notes: [46, 57, 62, 67, 75]);
    verifyTiedNoteGates(pattern, startStep: 80, endStep: 96, gates: [1, 1, 1, 1, 1]);
    verifyNoteOffsets(pattern, startStep: 80, endStep: 96, offsets: [0, 0, 0, 0, 0]);
    verifyNoteVelocities(pattern, startStep: 80, endStep: 96, velocities: [100, 100, 100, 100, 20]);

    verifyNotes(pattern, startStep: 96, endStep: 112, notes: [54, 65, 70, 75, 83]);
    verifyTiedNoteGates(pattern, startStep: 96, endStep: 112, gates: [1, 1, 1, 1, 1]);
    verifyNoteOffsets(pattern, startStep: 96, endStep: 112, offsets: [0, 0, 0, 0, 0]);
    verifyNoteVelocities(pattern, startStep: 96, endStep: 112, velocities: [100, 100, 100, 100, 100]);

    verifyNotes(pattern, startStep: 112, endStep: 128, notes: [0, 70, 75, 80, 127]);
    verifyTiedNoteGates(pattern, startStep: 112, endStep: 128, gates: [1, 1, 1, 1, 1]);
    verifyNoteOffsets(pattern, startStep: 112, endStep: 128, offsets: [0, 0, 0, 0, 0]);
    verifyNoteVelocities(pattern, startStep: 112, endStep: 128, velocities: [1, 100, 100, 100, 127]);
  });

  // Formula to calculate offset in Reason: positionTicks / 240
  // gate length in step for overlapping note: (240 - positionTicks) / 240
  // gate length remainder in next step for overlapping note: ((lengthInTicks - (240 - positionTicks)) / 240
  // gate length for non overlapping note: lengthInTicks / 240
  test('MIDI import for Reason 8 bar poly pattern with off grid offsets and gate lengths', () async {
    final file = File('test/assets/reason-export-test8.mid');
    final pattern = await PolyPatternImporter.importPattern(file);

    // 1 bar with 16 steps each
    expect(pattern.steps.length, equals(8 * 16));

    verifyNotes(pattern, startStep: 0, endStep: 1, notes: [60, 60, -1, -1, -1, -1, -1]);
    verifyNoteOffsets(pattern, startStep: 0, endStep: 1, offsets: [0.1, 0.95]);
    verifyTiedNoteGates(pattern, startStep: 0, endStep: 1, gates: [0.5, 0.05]);
    verifyNoteVelocities(pattern, startStep: 0, endStep: 1, velocities: [100, 100]);

    verifyNotes(pattern, startStep: 1, endStep: 2, notes: [60, 64, -1, -1, -1, -1, -1]);
    verifyNoteOffsets(pattern, startStep: 1, endStep: 2, offsets: [0, 0.47]);
    verifyTiedNoteGates(pattern, startStep: 1, endStep: 2, gates: [0.08, 0.52]);
    verifyNoteVelocities(pattern, startStep: 1, endStep: 2, velocities: [100, 100]);

    verifyNotes(pattern, startStep: 2, endStep: 3, notes: [64, 60, -1, -1, -1, -1, -1]);
    verifyNoteOffsets(pattern, startStep: 2, endStep: 3, offsets: [0, 0.725]);
    verifyTiedNoteGates(pattern, startStep: 2, endStep: 3, gates: [0.23, 0.225]);
    verifyNoteVelocities(pattern, startStep: 1, endStep: 2, velocities: [100, 100]);
  });

  test('Chords per beat', () async {
    final file = File('test/assets/Ableton_chords_per_beat.mid');
    final pattern = await PolyPatternImporter.importPattern(file);

    expect(pattern.steps.length, 13);

    verifyNotes(pattern, startStep: 0, endStep: 1, notes: [60, 63, 66]);
    verifyTiedNoteGates(pattern, startStep: 0, endStep: 1, gates: [1, 1, 1]);
    verifyNoteVelocities(pattern, startStep: 0, endStep: 1, velocities: [100, 100, 100]);

    verifyNoNotes(pattern, startStep: 1, endStep: 3);

    verifyNotes(pattern, startStep: 4, endStep: 5, notes: [60, 64, 66]);
    verifyTiedNoteGates(pattern, startStep: 4, endStep: 5, gates: [1, 1, 1]);
    verifyNoteVelocities(pattern, startStep: 4, endStep: 5, velocities: [100, 100, 100]);

    verifyNoNotes(pattern, startStep: 5, endStep: 7);

    verifyNotes(pattern, startStep: 8, endStep: 9, notes: [60, 63, 66]);
    verifyTiedNoteGates(pattern, startStep: 8, endStep: 9, gates: [1, 1, 1]);
    verifyNoteVelocities(pattern, startStep: 8, endStep: 9, velocities: [100, 100, 100]);

    verifyNoNotes(pattern, startStep: 9, endStep: 11);

    verifyNotes(pattern, startStep: 12, endStep: 13, notes: [60, 64, 66]);
    verifyTiedNoteGates(pattern, startStep: 12, endStep: 13, gates: [1, 1, 1]);
    verifyNoteVelocities(pattern, startStep: 12, endStep: 13, velocities: [100, 100, 100]);
  });

  test('Notes with offset', () async {
    final file = File('test/assets/notes_with_offset.mid');
    final pattern = await PolyPatternImporter.importPattern(file);

    expect(pattern.steps.length, 8);

    expect(pattern.steps[0].notes[0], 60);
    expect(pattern.steps[0].offsets[0], closeTo(0.16, 0.01));
    expect(pattern.steps[0].velocities[0], 100);

    expect(pattern.steps[4].notes[0], 60);
    expect(pattern.steps[4].offsets[0], closeTo(0.5, 0.01));
    expect(pattern.steps[4].velocities[0], 100);

    verifyNote(pattern, start: 0.166666, length: 0.58, note: 60, velocity: 100, noteIndex: 0);
    verifyNote(pattern, start: 4.5, length: 1.5, note: 60, velocity: 100, noteIndex: 0);
  });

}

// -------------------------------------------
// Helpers
// -------------------------------------------

// Verify that in the step range of [startStep, endStep) all notes are -1 in value.
void verifyNoNotes(PolyPattern pattern, {required int startStep, required int endStep}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].notes[i], -1);
    }
  }
}

// Verify that in the step range of [startStep, endStep] all notes are equal to the given [notes]
// and all other notes are -1.
void verifyNotes(
  PolyPattern pattern, {
  required int startStep,
  required int endStep,
  required List<int> notes,
}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < notes.length; i++) {
      expect(pattern.steps[j].notes[i], notes[i]);
    }
    for (int i = notes.length; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].notes[i], -1);
    }
  }
}

// Verify that in the step range of [startStep, endStep], each note's gate value matches
// the corresponding value in [gates]. For all steps except the last one, gates are checked
// for exact equality. For the last step, gates are checked with a 0.05 tolerance.
void verifyTiedNoteGates(
  PolyPattern pattern, {
  required int startStep,
  required int endStep,
  required List<double> gates,
}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < gates.length; i++) {
      final isLastStep = j == (endStep - 1);
      expect(pattern.steps[j].gates[i], isLastStep ? closeTo(gates[i], 0.05) : equals(gates[i]));
    }
    for (int i = gates.length; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].notes[i], -1);
    }
  }
}

// Verify that in the step range of [startStep, endStep], notes at indices [0..offsets.length]
// match the given offsets (with 0.005 tolerance), and all remaining notes have 0 offset.
void verifyNoteOffsets(
  PolyPattern pattern, {
  required int startStep,
  required int endStep,
  required List<double> offsets,
}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < offsets.length; i++) {
      expect(pattern.steps[j].offsets[i], closeTo(offsets[i], 0.005));
    }
    for (int i = offsets.length; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].offsets[i], 0);
    }
  }
}

// Verify that in the step range of [startStep, endStep], notes at indices [0..velocities.length]
// match the given velocities exactly, and all remaining notes have the default velocity of 100.
void verifyNoteVelocities(
  PolyPattern pattern, {
  required int startStep,
  required int endStep,
  required List<int> velocities,
}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < velocities.length; i++) {
      expect(pattern.steps[j].velocities[i], velocities[i]);
    }
    for (int i = velocities.length; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].velocities[i], 100);
    }
  }
}

/// Verify that in the given [pattern] at the given [start] step there is a note with the given parameters.
/// [start] and [length] units are in steps and are doubles.
void verifyNote(
  PolyPattern pattern, {
  required double start,
  required double length,
  int note = 60,
  int velocity = 100,
  int noteIndex = 0,
  double threshold = 0.05,
}) {
  int startStep = start.floor();
  int endStep = (start + length).ceil();

  for (int j = startStep; j < endStep; j++) {
    final isFirst = j == startStep;
    final isLast = j == (endStep - 1);

    if (isFirst && isLast) {
      final offset = start - startStep;
      final gate = length;
      expect(pattern.steps[j].notes[noteIndex], note);
      expect(pattern.steps[j].velocities[noteIndex], velocity);
      expect(pattern.steps[j].offsets[noteIndex], closeTo(offset, threshold));
      expect(pattern.steps[j].gates[noteIndex], closeTo(gate, threshold));
    } else {
      final offset = isFirst ? start - startStep : 0;
      final gate = isLast
          ? (start + length - endStep + 1)
          : isFirst
          ? (1 - start + startStep)
          : 1;
      expect(pattern.steps[j].notes[noteIndex], note);
      expect(pattern.steps[j].velocities[noteIndex], velocity);
      expect(pattern.steps[j].offsets[noteIndex], closeTo(offset, threshold));
      expect(pattern.steps[j].gates[noteIndex], closeTo(gate, threshold));
    }
  }
}
