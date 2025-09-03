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

  test('MIDI import for Reason pattern with test5 (poly)', () async {
    final file = File('test/assets/reason-export-test5.mid');
    final pattern = await PolyPatternImporter.importPattern(file);

    // 8 bars with 16 steps each
    expect(pattern.steps.length, equals(8 * 16));

    verifyNotes(pattern, startStep: 0, endStep: 32, notes: [0, 60, 63, 67, 72, 76, 127]);
    verifyTiedNoteGates(pattern, startStep: 0, endStep: 32, noteCount: 7);
    verifyNoteOffsets(pattern, startStep: 0, endStep: 32, noteCount: 7, offset: 0);
    verifyNoteVelocities(pattern, startStep: 0, endStep: 32, noteCount: 7, velocities: [1, 100, 100, 100, 100, 100, 127]);

    verifyNotes(pattern, startStep: 32, endStep: 64, notes: [46, 60, 64, 67, 71, 76, 82]);
    verifyTiedNoteGates(pattern, startStep: 32, endStep: 64, noteCount: 7);
    verifyNoteOffsets(pattern, startStep: 32, endStep: 64, noteCount: 7, offset: 0);
    verifyNoteVelocities(pattern, startStep: 32, endStep: 64, noteCount: 7, velocities: [100, 80, 100, 100, 100, 100, 100]);

    verifyNotes(pattern, startStep: 64, endStep: 80, notes: [46, 57, 62, 67, 69]);
    verifyTiedNoteGates(pattern, startStep: 64, endStep: 80, noteCount: 5);
    verifyNoteOffsets(pattern, startStep: 64, endStep: 80, noteCount: 5, offset: 0);
    verifyNoteVelocities(pattern, startStep: 64, endStep: 80, noteCount: 5, velocities: [100, 100, 100, 100, 100]);

    verifyNotes(pattern, startStep: 80, endStep: 96, notes: [46, 57, 62, 67, 75]);
    verifyTiedNoteGates(pattern, startStep: 80, endStep: 96, noteCount: 5);
    verifyNoteOffsets(pattern, startStep: 80, endStep: 96, noteCount: 5, offset: 0);
    verifyNoteVelocities(pattern, startStep: 80, endStep: 96, noteCount: 5, velocities: [100, 100, 100, 100, 20]);

    verifyNotes(pattern, startStep: 96, endStep: 112, notes: [54, 65, 70, 75, 83]);
    verifyTiedNoteGates(pattern, startStep: 96, endStep: 112, noteCount: 5);
    verifyNoteOffsets(pattern, startStep: 96, endStep: 112, noteCount: 5, offset: 0);
    verifyNoteVelocities(pattern, startStep: 96, endStep: 112, noteCount: 5, velocities: [100, 100, 100, 100, 100]);
    
    verifyNotes(pattern, startStep: 112, endStep: 128, notes: [0, 70, 75, 80, 127]);
    verifyTiedNoteGates(pattern, startStep: 112, endStep: 128, noteCount: 5);
    verifyNoteOffsets(pattern, startStep: 112, endStep: 128, noteCount: 5, offset: 0);
    verifyNoteVelocities(pattern, startStep: 112, endStep: 128, noteCount: 5, velocities: [1, 100, 100, 100, 127]);
  });

  test('Chords per beat', () async {
    final file = File('test/assets/Ableton_chords_per_beat.mid');
    final pattern = await PolyPatternImporter.importPattern(file);

    expect(pattern.steps.length, 13);

    verifyNotes(pattern, startStep: 0, endStep: 1, notes: [60, 63, 66]);
    verifyTiedNoteGates(pattern, startStep: 0, endStep: 1, noteCount: 3);
    verifyNoteVelocities(pattern, startStep: 0, endStep: 1, noteCount: 3, velocities: [100, 100, 100]);

    verifyNoNotes(pattern, startStep: 1, endStep: 3);

    verifyNotes(pattern, startStep: 4, endStep: 5, notes: [60, 64, 66]);
    verifyTiedNoteGates(pattern, startStep: 4, endStep: 5, noteCount: 3);
    verifyNoteVelocities(pattern, startStep: 4, endStep: 5, noteCount: 3, velocities: [100, 100, 100]);

    verifyNoNotes(pattern, startStep: 5, endStep: 7);

    verifyNotes(pattern, startStep: 8, endStep: 9, notes: [60, 63, 66]);
    verifyTiedNoteGates(pattern, startStep: 8, endStep: 9, noteCount: 3);
    verifyNoteVelocities(pattern, startStep: 8, endStep: 9, noteCount: 3, velocities: [100, 100, 100]);

    verifyNoNotes(pattern, startStep: 9, endStep: 11);

    verifyNotes(pattern, startStep: 12, endStep: 13, notes: [60, 64, 66]);
    verifyTiedNoteGates(pattern, startStep: 12, endStep: 13, noteCount: 3);
    verifyNoteVelocities(pattern, startStep: 12, endStep: 13, noteCount: 3, velocities: [100, 100, 100]);
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

// Verify that in the step range of [startStep, endStep) all notes are equal to the given [notes]
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

// Verify that in the step range of [startStep, endStep) the [noteCount] number of notes have
// gate 1 and are tied, and at the last step they are released with a gate < 1.
void verifyTiedNoteGates(PolyPattern pattern, {required int startStep, required int endStep, required int noteCount}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < noteCount; i++) {
      final isLastStep = j == (endStep - 1);
      expect(pattern.steps[j].gates[i], isLastStep ? closeTo(1, 0.05) : equals(1));
    }
    for (int i = noteCount; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].notes[i], -1);
    }
  }
}

// Verify that in the step range of [startStep, endStep) all [noteCount] notes have the given offset,
// and the rest of the notes have 0 offset.
void verifyNoteOffsets(
  PolyPattern pattern, {
  required int startStep,
  required int endStep,
  required int noteCount,
  required int offset,
}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < noteCount; i++) {
      expect(pattern.steps[j].offsets[i], offset);
    }
    for (int i = noteCount; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].offsets[i], 0);
    }
  }
}


// Verify that in the step range of [startStep, endStep) all [noteCount] notes have the given velocity,
// and the rest of the notes have 100 velocity.
void verifyNoteVelocities(
  PolyPattern pattern, {
  required int startStep,
  required int endStep,
  required int noteCount,
  required List<int> velocities,
}) {
  for (int j = startStep; j < endStep; j++) {
    for (int i = 0; i < noteCount; i++) {
      expect(pattern.steps[j].velocities[i], velocities[i]);
    }
    for (int i = noteCount; i < PolyPattern.kMaxNotesPerStep; i++) {
      expect(pattern.steps[j].velocities[i], 100);
    }
  }
}
