import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String baseUrl = 'http://localhost:11434';

  /// Default for heavier tasks (e.g. Personal Safety autofill).
  static const String defaultModel = 'qwen2.5:7b';

  /// Smaller/faster model for the home-page AI Insight overview.
  /// Pull with: ollama pull qwen2.5:3b
  static const String fastModel = 'qwen2.5:3b';

  /// Asks Ollama with `format: 'json'`, forcing the model to return a valid
  /// JSON string. Caller is responsible for parsing/validating the shape.
  ///
  /// If [schema] is provided, Ollama's structured-outputs feature (v0.5.0+)
  /// constrains the model's output to that JSON schema at the token level.
  Future<String> askJson(
    String message, {
    String model = defaultModel,
    Map<String, dynamic>? schema,
    Map<String, dynamic>? options,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'prompt': message,
      'stream': false,
      'format': schema ?? 'json',
      'keep_alive': '10m',
      'options': {
        // Cap output length — long replies are the main latency cost.
        'num_predict': 700,
        'temperature': 0.2,
        'top_p': 0.9,
        ...?options,
      },
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Ollama error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return (data['response'] as String?) ?? '';
  }
}
