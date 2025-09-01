import 'dart:io';
import 'dart:typed_data';

import 'package:dart_midi_pro/dart_midi_pro.dart';

Uint8List loadTestAsset(String path) {
  final file = File(path);
  return file.readAsBytesSync();
}

MidiFile loadMidiFile(String path) {
  final midiParser = MidiParser();
  final midiFile = midiParser.parseMidiFromFile(File(path));
  return midiFile;
}
