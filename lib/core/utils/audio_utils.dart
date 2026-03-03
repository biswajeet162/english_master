import 'dart:typed_data';

class AudioUtils {
  /// Converts audio bytes to a format suitable for playback
  static Uint8List? convertAudioBytes(List<int> bytes) {
    try {
      return Uint8List.fromList(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Validates audio data format
  static bool isValidAudioFormat(Uint8List audioData) {
    return audioData.isNotEmpty && audioData.length > 1024;
  }

  /// Gets audio duration estimate based on file size
  /// This is a rough estimation for MP3 format
  static Duration estimateAudioDuration(int fileSizeInBytes) {
    // Rough estimate: 1MB ≈ 1 minute for 128kbps MP3
    const int bytesPerSecond = 16000; // 128kbps = 16KB/s
    final int estimatedSeconds = fileSizeInBytes ~/ bytesPerSecond;
    return Duration(seconds: estimatedSeconds);
  }

  /// Formats duration to human readable string
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  /// Creates a visual representation of audio levels
  static List<double> generateWaveformData(int sampleCount, {double amplitude = 1.0}) {
    final List<double> waveform = List.generate(
      sampleCount,
      (index) => (index % 2 == 0 ? amplitude : -amplitude) * 
                  (0.3 + (index % 10) / 10.0) * 
                  (1 - (index % 20) / 20.0),
    );
    return waveform;
  }

  /// Checks if audio recording is within acceptable limits
  static bool isRecordingDurationValid(Duration duration) {
    const Duration minDuration = Duration(seconds: 1);
    const Duration maxDuration = Duration(minutes: 5);
    return duration >= minDuration && duration <= maxDuration;
  }
}
