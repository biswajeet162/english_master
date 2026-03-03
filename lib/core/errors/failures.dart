/// Base class for all failures in the app
abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
  
  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code}) : super(message, code: code);
}

/// Server related failures
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code);
}

/// Audio recording failures
class AudioFailure extends Failure {
  const AudioFailure(String message, {String? code}) : super(message, code: code);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {String? code}) : super(message, code: code);
}

/// Configuration failures
class ConfigurationFailure extends Failure {
  const ConfigurationFailure(String message, {String? code}) : super(message, code: code);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, {String? code}) : super(message, code: code);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? code}) : super(message, code: code);
}
