import 'package:test/test.dart';
import 'package:oxi_midi_import/src/utilities/midi_event_helpers.dart';
import 'package:oxi_midi_import/src/models/note.dart';
import 'package:oxi_midi_import/src/utilities/notes_to_groove_converter.dart';

import 'utilities/file_loader.dart';

void main() {
  test('Groove conversion', () {
    const notes = [
      Note(timestamp: 0, note: 60, velocity: 100, duration: 10),
      Note(timestamp: 26, note: 60, velocity: 64, duration: 10),
    ];
    final groove = NotesToGrooveConverter.convertNotesToGroove(notes, 24, 384);

    expect(groove.timing, [0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(groove.accents, [36, 0, -64, -64, -64, -64, -64, -64, -64, -64, -64, -64, -64, -64, -64, -64]);
  });

  test('Groove conversion for drum beats', () {
    final midiFile = loadMidiFile('test/assets/Life 1.mid');
    final notes = MidiEventHelpers.notesFromMidiEvents(midiFile.tracks[0]);
    final length = MidiEventHelpers.getTrackLength(midiFile.tracks.first);

    final groove = NotesToGrooveConverter.convertNotesToGroove(notes, midiFile.header.ticksPerBeat! ~/ 4, length);

    expect(groove.timing.length, 32);
    expect(groove.accents.length, 32);
    expect(groove.timing.every((element) => element >= -40 && element <= 40), isTrue);
    expect(groove.accents.every((element) => element >= -64 && element <= 64), isTrue);
    expect(groove.timing, [
      0, 10, -4, 6, 0, 0, -4, 6, //
      0, 10, -4, 6, 0, 10, -4, 6,
      0, 10, -4, 6, 0, 0, -4, 6,
      0, 10, -4, 6, 0, 10, -4, 6,
    ]);
    expect(groove.accents, [
      63, -37, -14, 44, -25, -64, 61, -50, //
      63, -36, 15, -41, 35, -19, 43, -50,
      25, -55, 57, 44, -14, -64, -24, -50,
      46, 59, 62, -41, 3, -36, -50, -60,
    ]);
  });
}
