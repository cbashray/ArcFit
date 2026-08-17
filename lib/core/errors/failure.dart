// Failure models for FitX

abstract class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred', int? code])
      : super(message: message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
      : super(message: message);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required this.fieldErrors,
    super.message = 'Validation failed',
  });

  String getFieldError(String field) => fieldErrors[field] ?? 'Invalid input';
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message: message, code: -1);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Not found'])
      : super(message: message);
}
