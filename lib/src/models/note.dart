/// Represents a musical note with its properties.
/// Used internally to represent Note On and Off events in a single note with timestamp and duration.
class Note {
  final int timestamp;
  final int note;
  final int velocity;
  final int duration;

  const Note({
    required this.timestamp,
    required this.note,
    required this.velocity,
    required this.duration,
  });

  @override
  String toString() {
    return 'Note(timestamp: $timestamp, note: $note, velocity: $velocity, duration: $duration)';
  }
}
