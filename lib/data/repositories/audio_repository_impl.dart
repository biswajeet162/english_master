import 'dart:typed_data';
import '../../domain/repositories/audio_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../services/audio_service.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioService audioService;

  AudioRepositoryImpl({required this.audioService});

  @override
  Future<Either<Failure, Uint8List>> startRecording() async {
    try {
      AppLogger.info('Starting audio recording');
      await audioService.startRecording();
      
      // Return empty bytes for start recording, actual bytes come from stopRecording
      return Either.right(Uint8List(0));
    } catch (e) {
      AppLogger.error('Error starting recording: $e');
      if (e is AudioException) {
        return Either.left(AudioFailure(e.message, code: e.code));
      } else if (e is PermissionException) {
        return Either.left(PermissionFailure(e.message, code: e.code));
      }
      return Either.left(AudioFailure('Failed to start recording: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> stopRecording() async {
    try {
      AppLogger.info('Stopping audio recording');
      final audioData = await audioService.stopRecording();
      
      if (audioData.isEmpty) {
        return Either.left(AudioFailure('No audio data recorded'));
      }
      
      AppLogger.info('Successfully recorded ${audioData.length} bytes');
      return Either.right(audioData);
    } catch (e) {
      AppLogger.error('Error stopping recording: $e');
      if (e is AudioException) {
        return Either.left(AudioFailure(e.message, code: e.code));
      }
      return Either.left(AudioFailure('Failed to stop recording: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> playAudio(Uint8List audioBytes) async {
    try {
      // Handle Android TTS case - empty bytes means TTS is handled directly
      if (audioBytes.isEmpty) {
        AppLogger.info('Android TTS playback - audio bytes empty, TTS handled directly');
        return Either.right(null);
      }
      
      AppLogger.info('Playing audio (${audioBytes.length} bytes)');
      await audioService.playAudioBytes(audioBytes);
      return Either.right(null);
    } catch (e) {
      AppLogger.error('Error playing audio: $e');
      if (e is AudioException) {
        return Either.left(AudioFailure(e.message, code: e.code));
      }
      return Either.left(AudioFailure('Failed to play audio: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> stopPlayback() async {
    try {
      AppLogger.info('Stopping audio playback');
      await audioService.stopPlayback();
      return Either.right(null);
    } catch (e) {
      AppLogger.error('Error stopping playback: $e');
      if (e is AudioException) {
        return Either.left(AudioFailure(e.message, code: e.code));
      }
      return Either.left(AudioFailure('Failed to stop playback: ${e.toString()}'));
    }
  }

  @override
  bool isRecording() {
    return audioService.isRecording();
  }

  @override
  bool isPlaying() {
    return audioService.isPlaying();
  }

  @override
  void dispose() {
    AppLogger.info('Disposing audio repository');
    audioService.dispose();
  }
}
