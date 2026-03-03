import 'dart:typed_data';
import '../repositories/speech_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/audio_repository.dart';

class TranscribeSpeechUseCase extends UseCase<String, TranscribeSpeechParams> {
  final SpeechRepository repository;

  TranscribeSpeechUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(TranscribeSpeechParams params) async {
    return await repository.transcribeSpeech(params.audioData);
  }
}

class TranscribeSpeechParams {
  final Uint8List audioData;

  TranscribeSpeechParams({required this.audioData});
}
