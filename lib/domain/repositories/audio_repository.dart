import 'dart:typed_data';
import '../../../core/errors/failures.dart';

abstract class AudioRepository {
  /// Records audio and returns the recorded bytes
  Future<Either<Failure, Uint8List>> startRecording();

  /// Stops recording and returns the final audio bytes
  Future<Either<Failure, Uint8List>> stopRecording();

  /// Plays audio from bytes
  Future<Either<Failure, void>> playAudio(Uint8List audioBytes);

  /// Stops audio playback
  Future<Either<Failure, void>> stopPlayback();

  /// Checks if recording is currently active
  bool isRecording();

  /// Checks if audio is currently playing
  bool isPlaying();

  /// Disposes audio resources
  void dispose();
}

// Either implementation for error handling
class Either<L, R> {
  final L? _left;
  final R? _right;

  Either.left(L value) : _left = value, _right = null;
  Either.right(R value) : _left = null, _right = value;

  bool isLeft() => _left != null;
  bool isRight() => _right != null;

  L? get left => _left;
  R? get right => _right;

  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight) {
    if (isLeft()) {
      return ifLeft(_left as L);
    }
    return ifRight(_right as R);
  }

  R? getOrElse(R Function() defaultValue) {
    if (isRight()) {
      return _right;
    }
    return defaultValue();
  }
}
