import 'package:uuid/uuid.dart';

enum MessageType { user, assistant }

class ConversationMessage {
  final String id;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final String? audioUrl;
  final Duration? duration;

  const ConversationMessage({
    required this.id,
    required this.text,
    required this.type,
    required this.timestamp,
    this.audioUrl,
    this.duration,
  });

  factory ConversationMessage.user({
    required String text,
    String? audioUrl,
    Duration? duration,
  }) {
    return ConversationMessage(
      id: const Uuid().v4(),
      text: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
      audioUrl: audioUrl,
      duration: duration,
    );
  }

  factory ConversationMessage.assistant({
    required String text,
    String? audioUrl,
    Duration? duration,
  }) {
    return ConversationMessage(
      id: const Uuid().v4(),
      text: text,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      audioUrl: audioUrl,
      duration: duration,
    );
  }

  ConversationMessage copyWith({
    String? id,
    String? text,
    MessageType? type,
    DateTime? timestamp,
    String? audioUrl,
    Duration? duration,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
    );
  }

  @override
  String toString() {
    return 'ConversationMessage(id: $id, text: $text, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          type == other.type &&
          timestamp == other.timestamp &&
          audioUrl == other.audioUrl &&
          duration == other.duration;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      type.hashCode ^
      timestamp.hashCode ^
      audioUrl.hashCode ^
      duration.hashCode;
}
