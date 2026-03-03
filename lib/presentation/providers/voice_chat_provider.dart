import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conversation_message.dart';
import '../../domain/usecases/process_voice_conversation_usecase.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../core/utils/logger.dart';
import '../../core/dependency_injection.dart';

enum VoiceChatState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

class VoiceChatNotifier extends StateNotifier<VoiceChatState> {
  final ProcessVoiceConversationUseCase processVoiceConversation;
  final AudioRepository audioRepository;

  VoiceChatNotifier({
    required this.processVoiceConversation,
    required this.audioRepository,
  }) : super(VoiceChatState.idle);

  List<ConversationMessage> _conversationHistory = [];
  String _errorMessage = '';

  List<ConversationMessage> get conversationHistory => List.unmodifiable(_conversationHistory);
  String get errorMessage => _errorMessage;

  /// Start recording user speech
  Future<void> startRecording() async {
    try {
      if (state == VoiceChatState.listening || state == VoiceChatState.speaking) {
        return;
      }

      state = VoiceChatState.listening;
      AppLogger.info('Starting voice recording');

      await audioRepository.startRecording();
    } catch (e) {
      AppLogger.error('Failed to start recording: $e');
      _setError('Failed to start recording: ${e.toString()}');
    }
  }

  /// Stop recording and process the conversation
  Future<void> stopRecording() async {
    try {
      if (state != VoiceChatState.listening) {
        return;
      }

      state = VoiceChatState.processing;
      AppLogger.info('Stopping voice recording and processing');

      // Stop recording and get audio data
      final audioResult = await audioRepository.stopRecording();
      
      final audioData = audioResult.fold(
        (failure) => throw failure,
        (audio) => audio,
      );

      // Process the voice conversation
      final result = await processVoiceConversation(
        ProcessVoiceConversationParams(
          audioData: audioData,
          conversationHistory: _conversationHistory,
        ),
      );

      final conversationResult = result.fold(
        (failure) => throw failure,
        (result) => result,
      );

      // Add messages to conversation history
      _conversationHistory.add(conversationResult.userMessage);
      _conversationHistory.add(conversationResult.assistantMessage);

      // Keep only last 20 messages to prevent memory issues
      if (_conversationHistory.length > 20) {
        _conversationHistory = _conversationHistory.sublist(_conversationHistory.length - 20);
      }

      state = VoiceChatState.speaking;
      AppLogger.info('Playing AI response');

      // Play the AI response audio
      final playResult = await audioRepository.playAudio(conversationResult.audioBytes);
      
      playResult.fold(
        (failure) => AppLogger.error('Failed to play audio: ${failure.message}'),
        (_) => AppLogger.info('Audio playback completed'),
      );

      state = VoiceChatState.idle;
    } catch (e) {
      AppLogger.error('Failed to process voice conversation: $e');
      _setError('Failed to process conversation: ${e.toString()}');
    }
  }

  /// Toggle recording - start if not recording, stop if recording
  Future<void> toggleRecording() async {
    if (state == VoiceChatState.listening) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  /// Stop audio playback
  Future<void> stopPlayback() async {
    try {
      if (state == VoiceChatState.speaking) {
        await audioRepository.stopPlayback();
        state = VoiceChatState.idle;
        AppLogger.info('Audio playback stopped');
      }
    } catch (e) {
      AppLogger.error('Failed to stop playback: $e');
      _setError('Failed to stop playback: ${e.toString()}');
    }
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
    AppLogger.info('Conversation history cleared');
  }

  /// Retry last failed operation
  Future<void> retry() async {
    if (state == VoiceChatState.error) {
      state = VoiceChatState.idle;
      _errorMessage = '';
      AppLogger.info('Retrying last operation');
    }
  }

  /// Set error state
  void _setError(String message) {
    _errorMessage = message;
    state = VoiceChatState.error;
    AppLogger.error('Voice chat error: $message');
  }

  /// Check if currently recording
  bool get isRecording => audioRepository.isRecording();

  /// Check if currently playing
  bool get isPlaying => audioRepository.isPlaying();

  @override
  void dispose() {
    AppLogger.info('Disposing VoiceChatNotifier');
    audioRepository.dispose();
    super.dispose();
  }
}

final voiceChatProvider = StateNotifierProvider<VoiceChatNotifier, VoiceChatState>((ref) {
  return VoiceChatNotifier(
    processVoiceConversation: ref.watch(processVoiceConversationUseCaseProvider),
    audioRepository: ref.watch(audioRepositoryProvider),
  );
});
