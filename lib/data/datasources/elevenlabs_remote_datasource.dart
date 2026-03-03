import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

class ElevenLabsRemoteDataSource {
  final http.Client client;
  final String apiKey;
  final String voiceId;

  ElevenLabsRemoteDataSource({
    required this.client,
    required this.apiKey,
    required this.voiceId,
  });

  /// Transcribes audio to text using OpenAI Whisper API
  Future<String> transcribeSpeech(Uint8List audioData) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $apiKey',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioData,
          filename: 'audio.wav',
        ),
      );

      // Add model field (required by OpenAI Whisper API)
      request.fields['model'] = 'whisper-1';

      final streamedResponse = await request.send().timeout(
        AppConstants.requestTimeout,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('text')) {
          final transcribedText = responseData['text'] as String;
          final displayText = transcribedText.length > 50 
              ? '${transcribedText.substring(0, 50)}...' 
              : transcribedText;
          AppLogger.info('Successfully transcribed speech: $displayText');
          return transcribedText;
        } else {
          throw ServerException('Invalid response format: missing text field');
        }
      } else {
        final errorMessage = 'Whisper API Error: ${response.statusCode} - ${response.body}';
        AppLogger.error(errorMessage);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error in speech transcription: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Failed to transcribe speech: ${e.toString()}');
    }
  }

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
        AppLogger.info('Successfully converted text to speech: ${text.substring(0, 50)}...');
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
