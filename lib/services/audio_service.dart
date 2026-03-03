import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../core/utils/audio_utils.dart';

class AudioService {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isRecorderOpen = false;
  String? _recordingPath;

  /// Initialize audio service and request permissions
  Future<void> initialize() async {
    try {
      // Request microphone permission
      final microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted) {
        throw PermissionException('Microphone permission denied');
      }

      // Initialize the recorder
      await _audioRecorder.openRecorder();
      _isRecorderOpen = true;
      AppLogger.info('Audio service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize audio service: $e');
      rethrow;
    }
  }

  /// Start recording audio
  Future<void> startRecording() async {
    try {
      if (_isRecording) {
        throw AudioException('Recording is already in progress');
      }

      // Check permission
      final microphoneStatus = await Permission.microphone.status;
      if (microphoneStatus != PermissionStatus.granted) {
        throw PermissionException('Microphone permission not granted');
      }

      // Ensure recorder is open
      if (!_isRecorderOpen) {
        await _audioRecorder.openRecorder();
        _isRecorderOpen = true;
      }

      // Create recording path
      _recordingPath = 'temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start recording
      await _audioRecorder.startRecorder(
        toFile: _recordingPath,
      );

      _isRecording = true;
      AppLogger.info('Audio recording started');
    } catch (e) {
      AppLogger.error('Failed to start recording: $e');
      if (e is AudioException || e is PermissionException) {
        rethrow;
      }
      throw AudioException('Failed to start recording: ${e.toString()}');
    }
  }

  /// Stop recording and return audio bytes
  Future<Uint8List> stopRecording() async {
    try {
      if (!_isRecording) {
        throw AudioException('No recording in progress');
      }

      final audioPath = await _audioRecorder.stopRecorder();
      _isRecording = false;

      if (audioPath == null && _recordingPath == null) {
        throw AudioException('Failed to get recording path');
      }

      final finalPath = audioPath ?? _recordingPath!;
      
      // Read the recorded file
      final audioFile = File(finalPath);
      if (!audioFile.existsSync()) {
        throw AudioException('Recorded audio file not found');
      }

      final audioBytes = await audioFile.readAsBytes();
      
      // Clean up temporary file
      try {
        await audioFile.delete();
      } catch (e) {
        AppLogger.warning('Failed to delete temporary audio file: $e');
      }
      
      // Validate audio data
      if (!AudioUtils.isValidAudioFormat(audioBytes)) {
        throw AudioException('Invalid audio format recorded');
      }

      _recordingPath = null;
      AppLogger.info('Audio recording stopped, ${audioBytes.length} bytes captured');
      return audioBytes;
    } catch (e) {
      _isRecording = false;
      _recordingPath = null;
      AppLogger.error('Failed to stop recording: $e');
      if (e is AudioException) {
        rethrow;
      }
      throw AudioException('Failed to stop recording: ${e.toString()}');
    }
  }

  /// Play audio from bytes
  Future<void> playAudioBytes(Uint8List audioBytes) async {
    try {
      if (_isPlaying) {
        await stopPlayback();
      }

      if (!AudioUtils.isValidAudioFormat(audioBytes)) {
        throw AudioException('Invalid audio format for playback');
      }

      // Create a temporary file and play from bytes
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_playback_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tempFile.writeAsBytes(audioBytes);
      
      try {
        await _audioPlayer.setFilePath(tempFile.path);
        await _audioPlayer.play();
        
        _isPlaying = true;
        AppLogger.info('Audio playback started (${audioBytes.length} bytes)');
      } finally {
        // Clean up temporary file after a short delay
        Future.delayed(const Duration(seconds: 1), () async {
          try {
            if (tempFile.existsSync()) {
              await tempFile.delete();
            }
          } catch (e) {
            AppLogger.warning('Failed to delete temporary playback file: $e');
          }
        });
      }
    } catch (e) {
      AppLogger.error('Failed to play audio: $e');
      if (e is AudioException) {
        rethrow;
      }
      throw AudioException('Failed to play audio: ${e.toString()}');
    }
  }

  /// Stop audio playback
  Future<void> stopPlayback() async {
    try {
      if (!_isPlaying) {
        return;
      }

      await _audioPlayer.stop();
      _isPlaying = false;
      AppLogger.info('Audio playback stopped');
    } catch (e) {
      AppLogger.error('Failed to stop playback: $e');
      if (e is AudioException) {
        rethrow;
      }
      throw AudioException('Failed to stop playback: ${e.toString()}');
    }
  }

  /// Check if currently recording
  bool isRecording() => _isRecording;

  /// Check if currently playing
  bool isPlaying() => _isPlaying;

  /// Get recording duration (if recording)
  Duration? getRecordingDuration() {
    if (!_isRecording) return null;
    // Note: AudioRecorder doesn't expose duration directly
    // This would need to be implemented differently if needed
    return null;
  }

  /// Get playback position (if playing)
  Duration? getPlaybackPosition() {
    if (!_isPlaying) return null;
    return _audioPlayer.position;
  }

  /// Dispose audio resources
  void dispose() {
    try {
      if (_isRecording) {
        _audioRecorder.stopRecorder();
        _isRecording = false;
      }

      if (_isPlaying) {
        _audioPlayer.stop();
        _isPlaying = false;
      }

      if (_isRecorderOpen) {
        _audioRecorder.closeRecorder();
        _isRecorderOpen = false;
      }

      _audioPlayer.dispose();

      AppLogger.info('Audio service disposed');
    } catch (e) {
      AppLogger.error('Error disposing audio service: $e');
    }
  }
}
