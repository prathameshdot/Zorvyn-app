class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Session expired. Please login again.'])
      : super(statusCode: 401);
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No internet connection. Please check your network.']);
}

class ServerException extends AppException {
  ServerException([super.message = 'Something went wrong. Please try again later.'])
      : super(statusCode: 500);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(super.message, {this.fieldErrors, super.statusCode});
}
