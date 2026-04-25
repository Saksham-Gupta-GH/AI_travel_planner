import 'dart:convert';

import 'package:http/http.dart' as http;

class AiAssistantService {
  static const String _configuredEndpoint = String.fromEnvironment(
    'AI_API_ENDPOINT',
    defaultValue: '',
  );

  Uri _resolveEndpoint() {
    if (_configuredEndpoint.isNotEmpty) {
      return Uri.parse(_configuredEndpoint);
    }

    throw StateError(
      'AI assistant is not configured. Pass --dart-define=AI_API_ENDPOINT=https://your-vercel-app.vercel.app/api/gemini-chat',
    );
  }

  Future<String> sendMessage({
    required String message,
    required String role,
    required String userName,
    required List<Map<String, String>> history,
  }) async {
    final response = await http.post(
      _resolveEndpoint(),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'role': role,
        'userName': userName,
        'history': history,
      }),
    );

    final Map<String, dynamic> data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final reply = data['reply']?.toString().trim();
      if (reply != null && reply.isNotEmpty) {
        return reply;
      }
      throw Exception('The AI service returned an empty response.');
    }

    final error =
        data['error']?.toString() ??
        data['reply']?.toString() ??
        'Request failed with status ${response.statusCode}';
    throw Exception(error);
  }
}
