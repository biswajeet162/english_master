import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

class ElevenLabsTTSDataSource {
  final http.Client client;
  final String apiKey;
  final String voiceId;

  ElevenLabsTTSDataSource({
    required this.client,
    required this.apiKey,
    required this.voiceId,
  });

  /// Converts text to speech using ElevenLabs TTS API
  Future<Uint8List> convertTextToSpeech(String text) async {
    try {
      final url = '${AppConstants.elevenLabsTTSUrl}/$voiceId';
      
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.5,
          },
        }),
      ).timeout(
        AppConstants.requestTimeout,
      );

      if (response.statusCode == 200) {
        AppLogger.info('Successfully converted text to speech');
        return response.bodyBytes;
      } else {
        final errorMessage = 'TTS API Error: ${response.statusCode} - ${response.body}';
        AppLogger.error(errorMessage);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error in text-to-speech conversion: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Failed to convert text to speech: ${e.toString()}');
    }
  }
}
