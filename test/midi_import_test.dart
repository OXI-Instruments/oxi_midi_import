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

    int barIndex = 0;
    final int stepsPerBar = 16;
    
    testChord(pattern, barIndex, 2 * stepsPerBar, new PolyPatternStep(notes: [48, 60, 63, 67, 72, 76, 80], gates: [], offsets: [], velocities: []));
    testChord(pattern, barIndex+=2 * 16, 2 * stepsPerBar, new PolyPatternStep(notes: [46, 60, 64, 67, 71, 76], gates: [], offsets: [], velocities: []));
    testChord(pattern, barIndex++ * stepsPerBar, stepsPerBar, new PolyPatternStep(notes: [46, 57, 62, 67, 69], gates: [], offsets: [], velocities: []));
    testChord(pattern, barIndex++ * stepsPerBar, stepsPerBar, new PolyPatternStep(notes: [46, 57, 62, 67, 75], gates: [], offsets: [], velocities: []));
    testChord(pattern, barIndex++ * stepsPerBar, stepsPerBar, new PolyPatternStep(notes: [46, 57, 62, 67, 75], gates: [], offsets: [], velocities: []));
    testChord(pattern, barIndex++ * stepsPerBar, stepsPerBar, new PolyPatternStep(notes: [54, 65, 70, 75], gates: [], offsets: [], velocities: []));
    testChord(pattern, barIndex++ * stepsPerBar, stepsPerBar, new PolyPatternStep(notes: [59, 70, 75, 80], gates: [], offsets: [], velocities: []));
  });
}

void testChord(PolyPattern pattern, int startStep, int chordStepCount, PolyPatternStep chord) {
  for (int j = startStep; j < chordStepCount; j++) {
    for (int i = 0; i < chord.notes.length; i++) {
      expect(pattern.steps[j].notes[i], chord.notes[i]);
      expect(pattern.steps[j].gates[i], j != chordStepCount - 1 ? 1 : closeTo(1, 0.05));
      expect(pattern.steps[j].offsets[i], 0);
      expect(pattern.steps[j].velocities[i], 100);
    }
  }
}
