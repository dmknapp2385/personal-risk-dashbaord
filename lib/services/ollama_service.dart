import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String baseUrl = 'http://localhost:11434';
  static const String defaultModel = 'qwen2.5:7b';

  /// Asks Ollama with `format: 'json'`, forcing the model to return a valid
  /// JSON string. Caller is responsible for parsing/validating the shape.
  ///
  /// If [schema] is provided, Ollama's structured-outputs feature (v0.5.0+)
  /// constrains the model's output to that JSON schema at the token level.
  /// This eliminates classic "model dropped one array entry" failures.
  Future<String> askJson(
    String message, {
    String model = defaultModel,
    Map<String, dynamic>? schema,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': model,
        'prompt': message,
        'stream': false,
        'format': schema ?? 'json',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ollama error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return (data['response'] as String?) ?? '';
  }
}