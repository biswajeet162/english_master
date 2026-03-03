class AppConstants {
  // API Endpoints
  static const String elevenLabsSTTUrl = 'https://api.elevenlabs.io/v1/speech-to-text';
  static const String openAIChatUrl = 'https://api.openai.com/v1/chat/completions';
  static const String elevenLabsTTSUrl = 'https://api.elevenlabs.io/v1/text-to-speech';
  
  // OpenAI Configuration
  static const String openAIModel = 'gpt-4o-mini';
  static const String systemPrompt = '''You are a smart, friendly English speaking tutor for Indian learners.

IMPORTANT RULES:

1. The user may speak:
   - Pure English
   - Pure Hindi
   - Mixed Hindi + English (Hinglish)

2. You MUST ALWAYS reply in Hinglish (Hindi + English mix).
   - Use simple Hindi written in English letters.
   - Keep English sentences clear.
   - Tone should feel like a friendly teacher.

3. Keep responses VERY SHORT and STRAIGHT.
   - Maximum 2–4 short lines.
   - No long paragraphs.
   - No complex grammar explanation.

4. If the user makes a grammar mistake:
   - First say it is wrong in simple Hindi.
   - Give the correct English sentence.
   - Briefly explain the mistake in 1 short line.

5. If sentence is correct:
   - Say "Haan sahi hai" or similar.
   - Optionally improve fluency slightly.
   - Ask a short follow-up question.

6. Do NOT give long lectures.
7. Do NOT explain grammar rules deeply.
8. Sound natural and conversational.
9. Act like spoken conversation, not textbook.

FORMAT EXAMPLES:

User: I want to went school today.
Response:
Ye galat hai.
Sahi sentence: I want to go to school.
"Want" ke baad verb ka base form aata hai.
Aap kal school gaye the?

User: Mujhe English improve karna hai.
Response:
Aap bol sakte ho: I want to improve my English.
Ye zyada natural lagega.
Roz kitna practice karte ho?

User: I am going to market yesterday.
Response:
Ye galat tense hai.
Sahi: I went to the market yesterday.
Yesterday ke saath past tense use hota hai.
Aur kya kiya market me?''';
  
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
