/// Base class for all exceptions in the app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) : super(message, code: code);
}

/// Server related exceptions
class ServerException extends AppException {
  const ServerException(String message, {String? code}) : super(message, code: code);
}

/// Audio recording exceptions
class AudioException extends AppException {
  const AudioException(String message, {String? code}) : super(message, code: code);
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(String message, {String? code}) : super(message, code: code);
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException(String message, {String? code}) : super(message, code: code);
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException(String message, {String? code}) : super(message, code: code);
}

/// Text-to-Speech exceptions
class TTSException extends AppException {
  const TTSException(String message, {String? code}) : super(message, code: code);
}
