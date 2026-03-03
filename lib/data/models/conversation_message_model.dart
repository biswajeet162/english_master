import '../../domain/entities/conversation_message.dart';

class ConversationMessageModel {
  final String id;
  final String text;
  final String type;
  final DateTime timestamp;
  final String? audioUrl;
  final Duration? duration;

  ConversationMessageModel({
    required this.id,
    required this.text,
    required this.type,
    required this.timestamp,
    this.audioUrl,
    this.duration,
  });

  factory ConversationMessageModel.fromEntity(ConversationMessage entity) {
    return ConversationMessageModel(
      id: entity.id,
      text: entity.text,
      type: entity.type.name,
      timestamp: entity.timestamp,
      audioUrl: entity.audioUrl,
      duration: entity.duration,
    );
  }

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) {
    return ConversationMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      audioUrl: json['audioUrl'] as String?,
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration'] as int)
          : null,
    );
  }

  ConversationMessage toEntity() {
    return ConversationMessage(
      id: id,
      text: text,
      type: type == 'user' ? MessageType.user : MessageType.assistant,
      timestamp: timestamp,
      audioUrl: audioUrl,
      duration: duration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'audioUrl': audioUrl,
      'duration': duration?.inMilliseconds,
    };
  }

  ConversationMessageModel copyWith({
    String? id,
    String? text,
    String? type,
    DateTime? timestamp,
    String? audioUrl,
    Duration? duration,
  }) {
    return ConversationMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
    );
  }
}
