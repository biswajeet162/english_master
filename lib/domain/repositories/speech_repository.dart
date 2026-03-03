import 'dart:typed_data';
import '../entities/conversation_message.dart';
import '../../core/errors/failures.dart';
import 'audio_repository.dart';

abstract class SpeechRepository {
  /// Transcribes audio to text using ElevenLabs STT
  Future<Either<Failure, String>> transcribeSpeech(Uint8List audioData);

  /// Generates AI response using OpenAI Chat API
  Future<Either<Failure, String>> generateResponse(String userMessage, List<ConversationMessage> conversationHistory);

  /// Converts text to speech using ElevenLabs TTS
  Future<Either<Failure, Uint8List>> convertTextToSpeech(String text);
}
