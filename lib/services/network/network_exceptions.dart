import 'package:equatable/equatable.dart';

enum NetworkExceptions { SOCKET, TYPE_ERROR, OTHER }

class AppNetworkException extends Equatable {
  final NetworkExceptions networkExceptionType;
  final String message;
  final Object? error;
  final StackTrace? stack;

  AppNetworkException({
    required this.networkExceptionType,
    required this.message,
    this.error,
    this.stack,
  });

  @override
  List<Object> get props => [networkExceptionType, message];
}

class SendOtpException extends Equatable {
  final String message;

  const SendOtpException(this.message);

  @override
  List<Object> get props => [message];
}

class EMailNotFoundException extends Equatable {
  final String message;

  const EMailNotFoundException(this.message);

  @override
  List<Object> get props => [message];
}

class SystemEventException extends Equatable {
  final Object error;

  const SystemEventException(this.error);

  @override
  List<Object> get props => [error];
}

// class GoogleAuthNullException implements Exception {
//   final String message;
//   GoogleAuthNullException(this.message);
// }
