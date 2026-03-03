import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

class AndroidTTSDataSource {
  final FlutterTts flutterTts;
  bool _isInitialized = false;

  AndroidTTSDataSource({
    required this.flutterTts,
  });

  /// Initialize the TTS engine
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing Android TTS...');
      
      // Set language to English (US)
      await flutterTts.setLanguage("en-US");
      
      // Set speech rate (0.0 to 1.0)
      await flutterTts.setSpeechRate(0.5);
      
      // Set volume (0.0 to 1.0)
      await flutterTts.setVolume(1.0);
      
      // Set pitch (0.5 to 2.0)
      await flutterTts.setPitch(1.0);
      
      _isInitialized = true;
      AppLogger.info('Android TTS initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Android TTS: $e');
      throw TTSException('Failed to initialize TTS: ${e.toString()}');
    }
  }

  /// Converts text to speech using Android TTS
  Future<Uint8List> convertTextToSpeech(String text) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (text.isEmpty) {
        throw TTSException('Text cannot be empty');
      }

      AppLogger.info('Converting text to speech: ${text.length > 50 ? '${text.substring(0, 50)}...' : text}');
      
      // For Android TTS, we need to speak directly rather than return audio bytes
      // But to maintain compatibility with existing interface, we'll speak and return empty bytes
      // In a future implementation, we could capture the audio if needed
      
      await flutterTts.speak(text);
      
      // Return empty bytes for now since Android TTS speaks directly
      // The existing architecture expects audio bytes, but Android TTS works differently
      AppLogger.info('Text-to-speech conversion completed');
      return Uint8List(0);
      
    } catch (e) {
      AppLogger.error('Error in text-to-speech conversion: $e');
      if (e is TTSException) {
        rethrow;
      }
      throw TTSException('Failed to convert text to speech: ${e.toString()}');
    }
  }

  /// Stop any ongoing speech
  Future<void> stop() async {
    try {
      await flutterTts.stop();
      AppLogger.info('TTS speech stopped');
    } catch (e) {
      AppLogger.error('Error stopping TTS: $e');
    }
  }

  /// Check if TTS is available
  Future<bool> isAvailable() async {
    try {
      final languages = await flutterTts.getLanguages;
      return languages != null && languages.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking TTS availability: $e');
      return false;
    }
  }

  /// Set voice parameters
  Future<void> setVoiceSettings({
    double? speechRate,
    double? volume,
    double? pitch,
    String? language,
  }) async {
    try {
      if (speechRate != null) {
        await flutterTts.setSpeechRate(speechRate);
      }
      if (volume != null) {
        await flutterTts.setVolume(volume);
      }
      if (pitch != null) {
        await flutterTts.setPitch(pitch);
      }
      if (language != null) {
        await flutterTts.setLanguage(language);
      }
      AppLogger.info('TTS voice settings updated');
    } catch (e) {
      AppLogger.error('Error setting TTS voice parameters: $e');
    }
  }
}
