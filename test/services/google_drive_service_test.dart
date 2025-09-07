import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:product_manager_app/services/google_drive_service.dart';

void main() {
  test('uploadFile sends authorized request', () async {
    final file = File('dummy.txt');
    file.writeAsStringSync('hello');

    final service = GoogleDriveService('token',
        client: MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer token');
      expect(request.method, 'POST');
      return http.Response('{}', 200);
    }));

    await service.uploadFile(file, name: 'dummy.txt');
    file.deleteSync();
  });
}
