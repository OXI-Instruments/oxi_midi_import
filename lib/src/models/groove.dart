/// Represents a groove pattern with timing and accents.
class Groove {
  final List<int> timing;
  final List<int> accents;

  const Groove({required this.timing, required this.accents});

  factory Groove.empty() {
    return Groove(timing: List.filled(16, 0), accents: List.filled(16, 0));
  }

  @override
  String toString() {
    return 'Groove(timing: $timing, accents: $accents)';
  }
}
