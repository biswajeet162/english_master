import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

class ApiConfig {
  static bool _isInitialized = false;

  /// Initialize the API configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      AppLogger.info('API configuration loaded successfully');
    } catch (e) {
      AppLogger.error('Failed to load API configuration: $e');
      throw ConfigurationException('Failed to load environment variables: ${e.toString()}');
    }
  }

  /// Get OpenAI API key
  static String get openAIApiKey {
    _ensureInitialized();
    final apiKey = dotenv.env[ApiKeys.openAI];
    if (apiKey == null || apiKey.isEmpty) {
      throw ConfigurationException('OpenAI API key not found in environment variables');
    }
    return apiKey;
  }

  /// Get ElevenLabs API key
  static String get elevenLabsApiKey {
    _ensureInitialized();
    final apiKey = dotenv.env[ApiKeys.elevenLabs];
    if (apiKey == null || apiKey.isEmpty) {
      throw ConfigurationException('ElevenLabs API key not found in environment variables');
    }
    return apiKey;
  }

  /// Get ElevenLabs voice ID
  static String get elevenLabsVoiceId {
    _ensureInitialized();
    final voiceId = dotenv.env[ApiKeys.elevenLabsVoiceId];
    if (voiceId == null || voiceId.isEmpty) {
      throw ConfigurationException('ElevenLabs voice ID not found in environment variables');
    }
    return voiceId;
  }

  /// Check if all required API keys are configured
  static bool get isConfigured {
    try {
      _ensureInitialized();
      openAIApiKey;
      elevenLabsApiKey;
      elevenLabsVoiceId;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get configuration status
  static Map<String, bool> get configurationStatus {
    _ensureInitialized();
    return {
      'openai': dotenv.env[ApiKeys.openAI]?.isNotEmpty == true,
      'elevenlabs': dotenv.env[ApiKeys.elevenLabs]?.isNotEmpty == true,
      'voice_id': dotenv.env[ApiKeys.elevenLabsVoiceId]?.isNotEmpty == true,
    };
  }

  /// Ensure configuration is initialized
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw ConfigurationException('API configuration not initialized. Call initialize() first.');
    }
  }

  /// Reset configuration (for testing purposes)
  static void reset() {
    _isInitialized = false;
  }
}
