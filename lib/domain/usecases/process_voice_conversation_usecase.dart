import 'dart:typed_data';
import '../entities/conversation_message.dart';
import '../repositories/audio_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import 'transcribe_speech_usecase.dart';
import 'generate_response_usecase.dart';
import 'convert_text_to_speech_usecase.dart';

class ProcessVoiceConversationUseCase extends UseCase<ProcessVoiceConversationResult, ProcessVoiceConversationParams> {
  final AudioRepository audioRepository;
  final TranscribeSpeechUseCase transcribeSpeech;
  final GenerateResponseUseCase generateResponse;
  final ConvertTextToSpeechUseCase convertTextToSpeech;

  ProcessVoiceConversationUseCase({
    required this.audioRepository,
    required this.transcribeSpeech,
    required this.generateResponse,
    required this.convertTextToSpeech,
  });

  @override
  Future<Either<Failure, ProcessVoiceConversationResult>> call(ProcessVoiceConversationParams params) async {
    try {
      // Step 1: Transcribe speech to text
      final transcribeResult = await transcribeSpeech(
        TranscribeSpeechParams(audioData: params.audioData),
      );

      final transcribedText = transcribeResult.fold(
        (failure) => throw failure,
        (text) => text,
      );

      // Step 2: Generate AI response
      final responseResult = await generateResponse(
        GenerateResponseParams(
          userMessage: transcribedText,
          conversationHistory: params.conversationHistory,
        ),
      );

      final aiResponse = responseResult.fold(
        (failure) => throw failure,
        (response) => response,
      );

      // Step 3: Convert AI response to speech
      final speechResult = await convertTextToSpeech(
        ConvertTextToSpeechParams(text: aiResponse),
      );

      final audioBytes = speechResult.fold(
        (failure) => throw failure,
        (bytes) => bytes,
      );

      // Step 4: Create conversation messages
      final userMessage = ConversationMessage.user(text: transcribedText);
      final assistantMessage = ConversationMessage.assistant(
        text: aiResponse,
        audioUrl: 'temp_audio_${DateTime.now().millisecondsSinceEpoch}',
      );

      return Either.right(ProcessVoiceConversationResult(
        userMessage: userMessage,
        assistantMessage: assistantMessage,
        audioBytes: audioBytes,
      ));
    } catch (e) {
      if (e is Failure) {
        return Either.left(e);
      }
      return Either.left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

class ProcessVoiceConversationParams {
  final Uint8List audioData;
  final List<ConversationMessage> conversationHistory;

  ProcessVoiceConversationParams({
    required this.audioData,
    required this.conversationHistory,
  });
}

class ProcessVoiceConversationResult {
  final ConversationMessage userMessage;
  final ConversationMessage assistantMessage;
  final Uint8List audioBytes;

  ProcessVoiceConversationResult({
    required this.userMessage,
    required this.assistantMessage,
    required this.audioBytes,
  });
}
