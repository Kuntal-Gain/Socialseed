import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/constants/constants.dart';

class PostService {
  Future<String> generateCaption(List<String> topics) async {
    // Join topics with commas
    final topicsString = topics.join(',');

    // Create the request body
    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Generate a Post caption of length 100 chars with This Following Topics : $topicsString"
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$API_KEY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String generatedText =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        return generatedText;
      } else {
        throw Exception('Failed to generate caption: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating caption: $e');
    }
  }
}
