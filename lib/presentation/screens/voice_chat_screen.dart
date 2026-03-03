import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/voice_chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/microphone_button.dart';
import '../widgets/speaking_animation.dart';
import '../../domain/entities/conversation_message.dart';

class VoiceChatScreen extends ConsumerStatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  ConsumerState<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends ConsumerState<VoiceChatScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _waveController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final voiceChatState = ref.watch(voiceChatProvider);
    final voiceChatNotifier = ref.watch(voiceChatProvider.notifier);
    final conversationHistory = voiceChatNotifier.conversationHistory;
    final errorMessage = voiceChatNotifier.errorMessage;

    // Start/stop animations based on state
    if (voiceChatState == VoiceChatState.listening) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
    } else if (voiceChatState == VoiceChatState.speaking) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.reset();
      _waveController.stop();
      _waveController.reset();
    }

    // Auto-scroll when new messages are added
    ref.listen<VoiceChatState>(voiceChatProvider, (previous, next) {
      if (previous != next && 
          (next == VoiceChatState.speaking || next == VoiceChatState.idle)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          'AI English Voice Tutor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: conversationHistory.isNotEmpty
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text('Are you sure you want to clear the conversation history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              voiceChatNotifier.clearHistory();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.clear_all, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: conversationHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildMessageList(conversationHistory),
            ),
          ),

          // Error message
          if (voiceChatState == VoiceChatState.error)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: voiceChatNotifier.retry,
                    icon: const Icon(Icons.refresh, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),

          // Speaking animation
          if (voiceChatState == VoiceChatState.speaking)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SpeakingAnimation(),
            ),

          // Control area
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF16213e),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status text
                Text(
                  _getStatusText(voiceChatState),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Microphone button
                MicrophoneButton(
                  isRecording: voiceChatState == VoiceChatState.listening,
                  isProcessing: voiceChatState == VoiceChatState.processing,
                  isSpeaking: voiceChatState == VoiceChatState.speaking,
                  pulseAnimation: _pulseController,
                  waveAnimation: _waveController,
                  onPressed: () {
                    if (voiceChatState == VoiceChatState.speaking) {
                      voiceChatNotifier.stopPlayback();
                    } else {
                      voiceChatNotifier.toggleRecording();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the microphone to start',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Practice your English with AI tutor',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ConversationMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message,
          isUser: message.type == MessageType.user,
        );
      },
    );
  }

  String _getStatusText(VoiceChatState state) {
    switch (state) {
      case VoiceChatState.idle:
        return 'Tap to start speaking';
      case VoiceChatState.listening:
        return 'Listening...';
      case VoiceChatState.processing:
        return 'Processing...';
      case VoiceChatState.speaking:
        return 'AI is speaking...';
      case VoiceChatState.error:
        return 'Something went wrong';
    }
  }
}
