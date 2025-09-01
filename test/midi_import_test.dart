import 'dart:io';

import 'package:oxi_midi_import/src/mono_pattern_importer.dart';
import 'package:test/test.dart';
import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:oxi_midi_import/src/utilities/midi_event_helpers.dart';
import 'package:oxi_midi_import/src/utilities/midi_to_pattern_converter.dart';

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
}
