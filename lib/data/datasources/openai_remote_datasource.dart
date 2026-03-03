import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/conversation_message.dart';

class OpenAIRemoteDataSource {
  final http.Client client;
  final String apiKey;

  OpenAIRemoteDataSource({
    required this.client,
    required this.apiKey,
  });

  /// Generates AI response using OpenAI Chat Completion API
  Future<String> generateResponse(
    String userMessage,
    List<ConversationMessage> conversationHistory,
  ) async {
    try {
      final messages = _buildMessages(userMessage, conversationHistory);

      final response = await client.post(
        Uri.parse(AppConstants.openAIChatUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': AppConstants.openAIModel,
          'messages': messages,
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      ).timeout(
        AppConstants.requestTimeout,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('choices') && 
            responseData['choices'].isNotEmpty) {
          final choice = responseData['choices'][0];
          if (choice.containsKey('message') && 
              choice['message'].containsKey('content')) {
            final aiResponse = choice['message']['content'] as String;
            final displayText = aiResponse.length > 50 
                ? '${aiResponse.substring(0, 50)}...' 
                : aiResponse;
            AppLogger.info('Successfully generated AI response: $displayText');
            return aiResponse;
          }
        }
        
        throw ServerException('Invalid response format from OpenAI');
      } else {
        final errorMessage = 'OpenAI API Error: ${response.statusCode} - ${response.body}';
        AppLogger.error(errorMessage);
        throw ServerException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error in AI response generation: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException('Failed to generate AI response: ${e.toString()}');
    }
  }

  /// Builds the messages array for OpenAI API
  List<Map<String, String>> _buildMessages(
    String userMessage,
    List<ConversationMessage> conversationHistory,
  ) {
    final messages = <Map<String, String>>[];
    
    // Add system prompt
    messages.add({
      'role': 'system',
      'content': AppConstants.systemPrompt,
    });

    // Add conversation history (last 10 messages to avoid token limits)
    final recentHistory = conversationHistory.length > 10
        ? conversationHistory.sublist(conversationHistory.length - 10)
        : conversationHistory;

    for (final message in recentHistory) {
      messages.add({
        'role': message.type == MessageType.user ? 'user' : 'assistant',
        'content': message.text,
      });
    }

    // Add current user message
    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    return messages;
  }
}
