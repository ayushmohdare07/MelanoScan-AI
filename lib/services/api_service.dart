import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  // Backend URL
  // For now, use your current laptop IP for phone testing.
  // Later, this will be replaced with the permanent online API URL.
  static const String baseUrl = 'http://10.83.188.203:5000';

  static Future<bool> checkServer() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> analyzeImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final uri = Uri.parse('$baseUrl/predict');

      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        try {
          final errorData = jsonDecode(response.body);

          throw Exception(errorData['error'] ?? 'Image analysis failed.');
        } catch (_) {
          throw Exception('Server error: ${response.statusCode}');
        }
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Analysis failed.');
      }

      return Map<String, dynamic>.from(data['result']);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
