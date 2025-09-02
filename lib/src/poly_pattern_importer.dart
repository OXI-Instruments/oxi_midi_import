import 'dart:io';
import 'dart:math';

import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:oxi_midi_import/oxi_midi_import.dart';
import 'package:oxi_midi_import/src/utilities/midi_event_helpers.dart';
import 'package:oxi_midi_import/src/utilities/midi_to_pattern_converter.dart';

final class PolyPatternImporter {

  static Future<PolyPattern> importPattern(File file) async {
    final bytes = await file.readAsBytes();
    //final name = FileHelpers.getFileNameWithoutExtension(result);

    final midi = MidiParser().parseMidiFromBuffer(bytes);
    final ticksPerStep = (midi.header.ticksPerBeat ?? 96) ~/ 4;

    int trackIndex = midi.tracks.indexWhere((track) => track.any((event) => event is NoteOnEvent));
    if (trackIndex == -1) {
      trackIndex = 0;
    }
    int length = max(
      MidiEventHelpers.getTrackLength(midi.tracks[trackIndex]),
      ticksPerStep * 8, // 8 steps minimum
    );

    List<MidiEvent> midiEvents = midi.tracks[trackIndex];

    if (ticksPerStep != 24) {
      midiEvents = MidiEventHelpers.retimeMidiEvents(midiEvents, 24, ticksPerStep);
      length = (length * 24 / ticksPerStep).ceil();
    }

    final notes = MidiEventHelpers.notesFromMidiEvents(midiEvents, ticksPerStep: ticksPerStep);
    final pattern = MidiToPatternConverter.createPolyPatternFrom(notes, length);

    return pattern;
  }
}
