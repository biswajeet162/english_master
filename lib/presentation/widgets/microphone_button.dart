import 'package:flutter/material.dart';

class MicrophoneButton extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final bool isSpeaking;
  final AnimationController pulseAnimation;
  final AnimationController waveAnimation;
  final VoidCallback onPressed;

  const MicrophoneButton({
    super.key,
    required this.isRecording,
    required this.isProcessing,
    required this.isSpeaking,
    required this.pulseAnimation,
    required this.waveAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse effect
        if (isRecording || isSpeaking)
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isRecording 
                        ? Colors.red.withOpacity(0.3 * pulseAnimation.value)
                        : Colors.blue.withOpacity(0.3 * pulseAnimation.value),
                    width: 2,
                  ),
                ),
              );
            },
          ),

        // Wave effect
        if (isRecording || isSpeaking)
          AnimatedBuilder(
            animation: waveAnimation,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isRecording 
                        ? Colors.red.withOpacity(0.2 * (1 - waveAnimation.value))
                        : Colors.blue.withOpacity(0.2 * (1 - waveAnimation.value)),
                    width: 4,
                  ),
                ),
              );
            },
          ),

        // Main button
        GestureDetector(
          onTap: isProcessing ? null : onPressed,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getButtonColor(),
              boxShadow: [
                BoxShadow(
                  color: _getButtonColor().withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Icon
                Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 32,
                ),

                // Processing indicator
                if (isProcessing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Recording indicator
        if (isRecording)
          Positioned(
            bottom: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TAP TO STOP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getButtonColor() {
    if (isRecording) {
      return Colors.red;
    } else if (isSpeaking) {
      return Colors.blue;
    } else if (isProcessing) {
      return Colors.grey;
    } else {
      return const Color(0xFF3282b8);
    }
  }

  IconData _getIcon() {
    if (isRecording) {
      return Icons.stop;
    } else if (isSpeaking) {
      return Icons.stop;
    } else if (isProcessing) {
      return Icons.hourglass_empty;
    } else {
      return Icons.mic;
    }
  }
}
