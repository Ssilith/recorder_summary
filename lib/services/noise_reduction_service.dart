import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:recorder_summary/services/network_service.dart';

class NoiseReductionService {
  final String _urlPrefix = NetworkService.getApiUrl();

  Map<String, String> headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<void> uploadAudioFile(String filePath, String algorithm) async {
    try {
      var uri = Uri.parse('$_urlPrefix/process_audio?algorithm=$algorithm');
      var request = http.MultipartRequest('POST', uri);

      // Attach the file to the request
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      // Sending the request
      var streamedResponse = await request.send();

      // Handling the response
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Get the directory to save the downloaded files
        Directory directory = await getApplicationDocumentsDirectory();
        File file = File(path.join(directory.path, "processed_output.wav"));

        // Write the file
        await file.writeAsBytes(response.bodyBytes);

        if (kDebugMode) {
          print('Download successful: File saved at ${file.path}');
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to download file: Server responded with status code ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
    }
  }
}
