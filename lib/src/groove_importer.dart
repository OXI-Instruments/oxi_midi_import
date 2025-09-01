import 'dart:io';
import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'models/groove.dart';
import 'utilities/midi_event_helpers.dart';
import 'utilities/notes_to_groove_converter.dart';

class GrooveException implements Exception {
  final String message;

  GrooveException(this.message);

  @override
  String toString() => message;
}

class GrooveImporter {
  static Future<Groove> importGroove(File file) async {
    final midiParser = MidiParser();
    final midiFile = midiParser.parseMidiFromFile(file);
    if (midiFile.tracks.isEmpty) return Groove.empty();

    final notes = MidiEventHelpers.notesFromMidiEvents(midiFile.tracks[0]);
    final notesByNoteValue = MidiEventHelpers.notesByNoteValue(notes);
    if (notesByNoteValue.length > 1) {
      throw GrooveException(
        'MIDI files with complex drum patterns are not supported.\n'
        'Please use a single drum track with a single note value.',
      );
    }
    final length = MidiEventHelpers.getTrackLength(midiFile.tracks.first);
    final groove = NotesToGrooveConverter.convertNotesToGroove(notes, midiFile.header.ticksPerBeat! ~/ 4, length);
    if (groove.accents.length != groove.timing.length) {
      throw GrooveException('Failed to import MIDI file');
    }
    if (groove.accents.length > 64 || groove.timing.length > 64) {
      throw GrooveException('MIDI file is too long');
    }
    return groove;
  }
}
