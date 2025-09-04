import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:oxi_midi_import/src/models/note.dart';

class MidiEventHelpers {
  static const defaultTicksPerStep = 24;

  // Converts NoteOnEvent and NoteOffEvent to Notes with duration and absolute timestamp.
  static List<Note> notesFromMidiEvents(List<MidiEvent> events) {
    final List<Note> notes = [];

    int time = 0;
    Map<int, (NoteOnEvent event, int time)> runningNotes = {};
    for (final event in events) {
      time += event.deltaTime;
      switch (event) {
        case NoteOnEvent():
          runningNotes[event.noteNumber] = (event, time);
          break;
        case NoteOffEvent():
          final item = runningNotes[event.noteNumber];
          if (item != null) {
            notes.add(
              Note(
                timestamp: item.$2,
                note: item.$1.noteNumber,
                velocity: item.$1.velocity,
                duration: time - item.$2,
              ),
            );
            runningNotes.remove(event.noteNumber);
          }
          break;
        case EndOfTrackEvent():
          // End all running notes
          for (final entry in runningNotes.entries) {
            final item = entry.value;
            notes.add(
              Note(
                timestamp: item.$2,
                note: item.$1.noteNumber,
                velocity: item.$1.velocity,
                duration: time - item.$2,
              ),
            );
          }
          break;
      }
    }
    return notes;
  }

  static int getTrackLength(List<MidiEvent> events) {
    int time = 0;
    for (final event in events) {
      time += event.deltaTime;
      if (event is EndOfTrackEvent) {
        return time;
      }
    }
    return 0;
  }

  static Map<int, List<Note>> notesByNoteValue(List<Note> notes) {
    final Map<int, List<Note>> notesByValue = {};
    for (final note in notes) {
      notesByValue.putIfAbsent(note.note, () => []).add(note);
    }
    return notesByValue;
  }

  static List<MidiEvent> retimeMidiEvents(List<MidiEvent> events, int newTicksPerBeat, int oldTicksPerBeat) {
    if (newTicksPerBeat == oldTicksPerBeat) {
      return events;
    }

    final List<MidiEvent> newEvents = [];
    for (final event in events) {
      final newEvent = event;
      newEvent.deltaTime = (event.deltaTime * newTicksPerBeat / oldTicksPerBeat).round();
      newEvents.add(newEvent);
    }
    return newEvents;
  }
}
