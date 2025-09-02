import 'dart:io';
import 'dart:math';
import 'package:dart_midi_pro/dart_midi_pro.dart';

import 'models/mono_pattern.dart';
import 'utilities/midi_event_helpers.dart';
import 'utilities/midi_to_pattern_converter.dart';

final class MonoPatternImporter {
  static const _minimumStepCount = 8;
  static const _defaultTicksPerStep = 24;

  static Future<MonoPattern> importPattern(File file) async {
    final bytes = await file.readAsBytes();

    final midi = MidiParser().parseMidiFromBuffer(bytes);
    final ticksPerStep = (midi.header.ticksPerBeat ?? 96) ~/ 4;

    // Find the first track with NoteOn events
    int trackIndex = midi.tracks.indexWhere((track) => track.any((event) => event is NoteOnEvent));
    if (trackIndex == -1) trackIndex = 0;

    int length = max(MidiEventHelpers.getTrackLength(midi.tracks[trackIndex]), ticksPerStep * _minimumStepCount);

    List<MidiEvent> midiEvents = midi.tracks[trackIndex];

    if (ticksPerStep != _defaultTicksPerStep) {
      midiEvents = MidiEventHelpers.retimeMidiEvents(midiEvents, _defaultTicksPerStep, ticksPerStep);
      length = (length * _defaultTicksPerStep / ticksPerStep).ceil();
    }

    final notes = MidiEventHelpers.notesFromMidiEvents(midiEvents, ticksPerStep: ticksPerStep);
    final pattern = MidiToPatternConverter.createMonoPatternFrom(notes, length);

    return pattern;
  }
}
