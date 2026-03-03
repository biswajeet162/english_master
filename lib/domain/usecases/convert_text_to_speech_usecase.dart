import 'dart:typed_data';
import '../repositories/speech_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/audio_repository.dart';

class ConvertTextToSpeechUseCase extends UseCase<Uint8List, ConvertTextToSpeechParams> {
  final SpeechRepository repository;

  ConvertTextToSpeechUseCase(this.repository);

  @override
  Future<Either<Failure, Uint8List>> call(ConvertTextToSpeechParams params) async {
    return await repository.convertTextToSpeech(params.text);
  }
}

class ConvertTextToSpeechParams {
  final String text;

  ConvertTextToSpeechParams({required this.text});
}
