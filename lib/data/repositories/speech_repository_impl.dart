import 'dart:typed_data';
import '../../domain/repositories/speech_repository.dart';
import '../../domain/entities/conversation_message.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../datasources/elevenlabs_remote_datasource.dart';
import '../datasources/android_tts_datasource.dart';
import '../datasources/openai_remote_datasource.dart';
import '../../domain/repositories/audio_repository.dart';

class SpeechRepositoryImpl implements SpeechRepository {
  final ElevenLabsRemoteDataSource elevenLabsDataSource;
  final AndroidTTSDataSource androidTTSDataSource;
  final OpenAIRemoteDataSource openaiDataSource;

  SpeechRepositoryImpl({
    required this.elevenLabsDataSource,
    required this.androidTTSDataSource,
    required this.openaiDataSource,
  });

  @override
  Future<Either<Failure, String>> transcribeSpeech(Uint8List audioData) async {
    try {
      AppLogger.info('Transcribing speech from ${audioData.length} bytes');
      final transcribedText = await elevenLabsDataSource.transcribeSpeech(audioData);
      
      if (transcribedText.isEmpty) {
        return Either.left(ServerFailure('Empty transcription result'));
      }
      
      return Either.right(transcribedText);
    } catch (e) {
      AppLogger.error('Error in speech transcription: $e');
      if (e is NetworkException) {
        return Either.left(NetworkFailure(e.message, code: e.code));
      } else if (e is ServerException) {
        return Either.left(ServerFailure(e.message, code: e.code));
      } else if (e is TimeoutException) {
        return Either.left(TimeoutFailure(e.message, code: e.code));
      }
      return Either.left(UnknownFailure('Transcription failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> generateResponse(
    String userMessage,
    List<ConversationMessage> conversationHistory,
  ) async {
    try {
      final displayMessage = userMessage.length > 50 
      ? '${userMessage.substring(0, 50)}...' 
      : userMessage;
  AppLogger.info('Generating AI response for: $displayMessage');
      final aiResponse = await openaiDataSource.generateResponse(
        userMessage,
        conversationHistory,
      );
      
      if (aiResponse.isEmpty) {
        return Either.left(ServerFailure('Empty AI response'));
      }
      
      return Either.right(aiResponse);
    } catch (e) {
      AppLogger.error('Error in AI response generation: $e');
      if (e is NetworkException) {
        return Either.left(NetworkFailure(e.message, code: e.code));
      } else if (e is ServerException) {
        return Either.left(ServerFailure(e.message, code: e.code));
      } else if (e is TimeoutException) {
        return Either.left(TimeoutFailure(e.message, code: e.code));
      }
      return Either.left(UnknownFailure('AI response generation failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> convertTextToSpeech(String text) async {
    try {
      final displayText = text.length > 50 
      ? '${text.substring(0, 50)}...' 
      : text;
  AppLogger.info('Converting text to speech: $displayText');
      final audioBytes = await androidTTSDataSource.convertTextToSpeech(text);
      
      // Android TTS returns empty bytes since it speaks directly
      // This is expected behavior for Android TTS
      AppLogger.info('Android TTS speech initiated');
      
      return Either.right(audioBytes);
    } catch (e) {
      AppLogger.error('Error in text-to-speech conversion: $e');
      if (e is TTSException) {
        return Either.left(ServerFailure(e.message, code: e.code));
      } else if (e is NetworkException) {
        return Either.left(NetworkFailure(e.message, code: e.code));
      } else if (e is ServerException) {
        return Either.left(ServerFailure(e.message, code: e.code));
      } else if (e is TimeoutException) {
        return Either.left(TimeoutFailure(e.message, code: e.code));
      }
      return Either.left(UnknownFailure('Text-to-speech conversion failed: ${e.toString()}'));
    }
  }
}
