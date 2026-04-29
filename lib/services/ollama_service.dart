import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String baseUrl = 'http://localhost:11434';

  Future<String> ask(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'llama3.2:1b',
        'prompt': message,
        'stream': false,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ollama error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['response'] ?? '';
  }
}