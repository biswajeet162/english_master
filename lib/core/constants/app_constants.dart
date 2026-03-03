class AppConstants {
  // API Endpoints
  static const String elevenLabsSTTUrl = 'https://api.elevenlabs.io/v1/speech-to-text';
  static const String openAIChatUrl = 'https://api.openai.com/v1/chat/completions';
  static const String elevenLabsTTSUrl = 'https://api.elevenlabs.io/v1/text-to-speech';
  
  // OpenAI Configuration
  static const String openAIModel = 'gpt-4o-mini';
  static const String systemPrompt = '''You are a friendly English speaking tutor.

1. Correct grammar mistakes.
2. Briefly explain the mistake.
3. Provide improved sentence.
4. Ask a follow-up question.''';
  
  // Audio Configuration
  static const int sampleRate = 44100;
  static const int bitDepth = 16;
  static const int channels = 1;
  static const Duration maxRecordingDuration = Duration(minutes: 5);
  
  // App Configuration
  static const String appName = 'AI English Voice Tutor';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // UI Constants
  static const double buttonSize = 80.0;
  static const double buttonPadding = 16.0;
  static const double messageSpacing = 8.0;
  static const double borderRadius = 12.0;
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pulseDuration = Duration(milliseconds: 1000);
}

class ApiKeys {
  static const String openAI = 'OPENAI_API_KEY';
  static const String elevenLabs = 'ELEVENLABS_API_KEY';
  static const String elevenLabsVoiceId = 'ELEVENLABS_VOICE_ID';
}
