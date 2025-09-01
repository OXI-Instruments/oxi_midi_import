import 'dart:io';
import 'dart:math';
import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:oxi_midi_import/oxi_midi_import.dart';
import 'package:oxi_midi_import/src/models/note.dart' show Note;
import 'package:oxi_midi_import/src/utilities/midi_event_helpers.dart';
import 'package:oxi_midi_import/src/utilities/midi_to_pattern_converter.dart';

final class PolyPatternImporter {
  static const _maxPatternLength = 1000000;

  static Future<PolyPattern> importPattern(File file) async {
    final bytes = await file.readAsBytes();

    final midi = MidiParser().parseMidiFromBuffer(bytes);
    final ticksPerStep = (midi.header.ticksPerBeat ?? 96) ~/ 4;

    final List<Note> notes = [];
    int length = _maxPatternLength; // NOTE: some big number
    for (final track in midi.tracks) {
      notes.addAll(MidiEventHelpers.notesFromMidiEvents(track));
      final trackLength = max(
        MidiEventHelpers.getTrackLength(track),
        ticksPerStep * 8, // 8 steps minimum
      );
      length = min(length, trackLength);
    }
    if (length == _maxPatternLength) {
      throw Exception('MIDI clip is too long or invalid.');
    }
    final pattern = await MidiToPatternConverter.createPolyPatternFrom(notes, length);

    return pattern;
  }
}
