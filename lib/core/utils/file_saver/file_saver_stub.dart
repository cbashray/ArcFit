import 'dart:typed_data';

Future<void> saveAndShareFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  String? shareText,
  String? shareSubject,
}) async {
  throw UnsupportedError('Cannot save file on this platform');
}
