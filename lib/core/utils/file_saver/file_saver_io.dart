import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  String? shareText,
  String? shareSubject,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: mimeType, name: fileName)],
    text: shareText,
    subject: shareSubject,
  );
}
