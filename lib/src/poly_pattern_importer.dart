import 'dart:io';
import 'dart:math';

import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:oxi_midi_import/oxi_midi_import.dart';
import 'package:oxi_midi_import/src/utilities/midi_event_helpers.dart';
import 'package:oxi_midi_import/src/utilities/midi_to_pattern_converter.dart';

final class PolyPatternImporter {
  static const _minimumStepCount = 8;
  static const _defaultTicksPerStep = 24;

  static Future<PolyPattern> importPattern(File file) async {
    final bytes = await file.readAsBytes();

    final midi = MidiParser().parseMidiFromBuffer(bytes);
    final ticksPerStep = (midi.header.ticksPerBeat ?? _defaultTicksPerStep * 4) ~/ 4;

    int trackIndex = midi.tracks.indexWhere((track) => track.any((event) => event is NoteOnEvent));
    if (trackIndex == -1) {
      trackIndex = 0;
    }
    int length = max(
      MidiEventHelpers.getTrackLength(midi.tracks[trackIndex]),
      ticksPerStep * _minimumStepCount,
    );

    List<MidiEvent> midiEvents = midi.tracks[trackIndex];

    final notes = MidiEventHelpers.notesFromMidiEvents(midiEvents);
    final pattern = MidiToPatternConverter.createPolyPatternFrom(notes, length, ticksPerStep: ticksPerStep);

    return pattern;
  }
}
