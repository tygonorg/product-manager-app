import 'dart:io';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  final String accessToken;
  final http.Client _client;

  GoogleDriveService(this.accessToken, {http.Client? client})
      : _client = client ?? http.Client();

  Future<void> uploadFile(File file, {String name = 'report.xlsx'}) async {
    final uri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['name'] = name;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await _client.send(request);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }
}
