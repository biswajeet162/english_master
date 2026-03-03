import '../entities/conversation_message.dart';
import '../repositories/speech_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/audio_repository.dart';

class GenerateResponseUseCase extends UseCase<String, GenerateResponseParams> {
  final SpeechRepository repository;

  GenerateResponseUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GenerateResponseParams params) async {
    return await repository.generateResponse(
      params.userMessage,
      params.conversationHistory,
    );
  }
}

class GenerateResponseParams {
  final String userMessage;
  final List<ConversationMessage> conversationHistory;

  GenerateResponseParams({
    required this.userMessage,
    required this.conversationHistory,
  });
}
