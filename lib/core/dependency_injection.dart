import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../data/datasources/elevenlabs_remote_datasource.dart';
import '../data/datasources/elevenlabs_tts_datasource.dart';
import '../data/datasources/openai_remote_datasource.dart';
import '../data/repositories/audio_repository_impl.dart';
import '../data/repositories/speech_repository_impl.dart';
import '../domain/repositories/audio_repository.dart';
import '../domain/repositories/speech_repository.dart';
import '../domain/usecases/transcribe_speech_usecase.dart';
import '../domain/usecases/generate_response_usecase.dart';
import '../domain/usecases/convert_text_to_speech_usecase.dart';
import '../domain/usecases/process_voice_conversation_usecase.dart';
import '../core/config/api_config.dart';
import '../core/utils/logger.dart';

// Service providers
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// HTTP client provider
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// Remote data source providers
final elevenLabsDataSourceProvider = Provider<ElevenLabsRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return ElevenLabsRemoteDataSource(
    client: client,
    apiKey: ApiConfig.openAIApiKey, // Use OpenAI API key for Whisper
    voiceId: ApiConfig.elevenLabsVoiceId,
  );
});

final elevenLabsTTSDataSourceProvider = Provider<ElevenLabsTTSDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return ElevenLabsTTSDataSource(
    client: client,
    apiKey: ApiConfig.elevenLabsApiKey, // Use ElevenLabs API key for TTS
    voiceId: ApiConfig.elevenLabsVoiceId,
  );
});

final openaiDataSourceProvider = Provider<OpenAIRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return OpenAIRemoteDataSource(
    client: client,
    apiKey: ApiConfig.openAIApiKey,
  );
});

// Repository providers
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioRepositoryImpl(audioService: audioService);
});

final speechRepositoryProvider = Provider<SpeechRepository>((ref) {
  final elevenLabsDataSource = ref.watch(elevenLabsDataSourceProvider);
  final elevenLabsTTSDataSource = ref.watch(elevenLabsTTSDataSourceProvider);
  final openaiDataSource = ref.watch(openaiDataSourceProvider);
  return SpeechRepositoryImpl(
    elevenLabsDataSource: elevenLabsDataSource,
    elevenLabsTTSDataSource: elevenLabsTTSDataSource,
    openaiDataSource: openaiDataSource,
  );
});

// Use case providers
final transcribeSpeechUseCaseProvider = Provider<TranscribeSpeechUseCase>((ref) {
  final speechRepository = ref.watch(speechRepositoryProvider);
  return TranscribeSpeechUseCase(speechRepository);
});

final generateResponseUseCaseProvider = Provider<GenerateResponseUseCase>((ref) {
  final speechRepository = ref.watch(speechRepositoryProvider);
  return GenerateResponseUseCase(speechRepository);
});

final convertTextToSpeechUseCaseProvider = Provider<ConvertTextToSpeechUseCase>((ref) {
  final speechRepository = ref.watch(speechRepositoryProvider);
  return ConvertTextToSpeechUseCase(speechRepository);
});

final processVoiceConversationUseCaseProvider = Provider<ProcessVoiceConversationUseCase>((ref) {
  final audioRepository = ref.watch(audioRepositoryProvider);
  final transcribeSpeech = ref.watch(transcribeSpeechUseCaseProvider);
  final generateResponse = ref.watch(generateResponseUseCaseProvider);
  final convertTextToSpeech = ref.watch(convertTextToSpeechUseCaseProvider);
  
  return ProcessVoiceConversationUseCase(
    audioRepository: audioRepository,
    transcribeSpeech: transcribeSpeech,
    generateResponse: generateResponse,
    convertTextToSpeech: convertTextToSpeech,
  );
});

// Update the voice chat provider to use the actual implementation
// This is now defined in voice_chat_provider.dart

// Initialize all services
Future<void> initializeDependencies() async {
  try {
    AppLogger.info('Initializing dependencies...');
    
    // Initialize API configuration
    await ApiConfig.initialize();
    
    // Initialize audio service
    final audioService = AudioService();
    await audioService.initialize();
    
    AppLogger.info('Dependencies initialized successfully');
  } catch (e) {
    AppLogger.error('Failed to initialize dependencies: $e');
    rethrow;
  }
}
