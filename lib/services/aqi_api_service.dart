
import 'dart:convert';
import 'package:http/http.dart' as http;

class AqiApiService {
  static const String _baseUrl = 'http://192.168.18.152:8000';

  static Future<Map<String, dynamic>> getLiveForecast() async {
    final uri = Uri.parse('$_baseUrl/predict/live-next-hour');

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'API error: ${response.statusCode} ${response.body}',
    );
  }
}
