// lib/services/vision_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/vision_config.dart';
import '../config/groq_config.dart';

class VisionService {
  static const List<String> validDepartments = [
    'Cardiology',
    'Pathology',
    'Radiology',
    'Neurology',
    'Orthopedics',
    'Endocrinology',
    'Gastroenterology',
    'Pulmonology',
    'Dermatology',
    'Ophthalmology',
    'ENT',
    'Urology',
    'Nephrology',
    'Oncology',
    'Gynecology',
    'Pediatrics',
    'Psychiatry',
    'General Medicine',
    'General Surgery',
    'Dentistry',
  ];

  static Future<String?> extractTextFromImage(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final response = await http.post(
        Uri.parse('${VisionConfig.apiUrl}?key=${VisionConfig.apiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION',          'maxResults': 1},
                {'type': 'DOCUMENT_TEXT_DETECTION', 'maxResults': 1},
              ],
            }
          ]
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data      = jsonDecode(response.body) as Map<String, dynamic>;
        final responses = data['responses'] as List<dynamic>;
        if (responses.isEmpty) return null;

        final first = responses[0] as Map<String, dynamic>;

        final fullAnnotation = first['fullTextAnnotation'];
        if (fullAnnotation != null) {
          final text = fullAnnotation['text'] as String?;
          if (text != null && text.trim().isNotEmpty) return text.trim();
        }

        final textAnnotations = first['textAnnotations'] as List<dynamic>?;
        if (textAnnotations != null && textAnnotations.isNotEmpty) {
          return (textAnnotations[0]['description'] as String?)?.trim();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> detectDepartmentFromText(String extractedText) async {
    if (extractedText.trim().isEmpty) return null;
    try {
      final departmentList = validDepartments.join(', ');

      final response = await http.post(
        Uri.parse(GroqConfig.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${GroqConfig.apiKey}',
        },
        body: jsonEncode({
          'model': GroqConfig.model,
          'messages': [
            {
              'role': 'system',
              'content':
              'You are a medical document classifier. '
                  'When given extracted text from a medical report, '
                  'reply with ONLY the department name from the provided list. '
                  'No explanation. No punctuation. Just the department name.',
            },
            {
              'role': 'user',
              'content':
              'Based on the following extracted text from a medical report or prescription, '
                  'identify which medical department it belongs to.\n\n'
                  'Choose ONLY from this list:\n$departmentList\n\n'
                  'Extracted text:\n"""\n'
                  '${extractedText.length > 1500 ? extractedText.substring(0, 1500) : extractedText}'
                  '\n"""\n\n'
                  'Reply with ONLY the department name from the list above. Nothing else.',
            },
          ],
          'max_tokens': 20,
          'temperature': 0.1,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data  = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = data['choices'][0]['message']['content']
            .toString()
            .trim();

        for (final dept in validDepartments) {
          if (reply.toLowerCase().contains(dept.toLowerCase())) {
            return dept;
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> detectDepartmentFromFile(Uint8List fileBytes) async {
    final extractedText = await extractTextFromImage(fileBytes);
    if (extractedText == null || extractedText.trim().isEmpty) return null;
    return detectDepartmentFromText(extractedText);
  }
}