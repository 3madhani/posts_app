/// Custom exception for API errors with user-friendly messages and status codes.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  factory ApiException.network([String message = 'Network connection failed. Please check your internet connection.']) {
    return ApiException(message, statusCode: null);
  }

  factory ApiException.notFound([String message = 'The requested resource was not found.']) {
    return ApiException(message, statusCode: 404);
  }

  factory ApiException.unauthorized([String message = 'Unauthorized request. Please check credentials.']) {
    return ApiException(message, statusCode: 401);
  }

  factory ApiException.badRequest([String message = 'Bad request sent to the server.']) {
    return ApiException(message, statusCode: 400);
  }

  factory ApiException.serverError([
    String message = 'A server error occurred. Please try again later.',
    int? statusCode = 500,
  ]) {
    return ApiException(message, statusCode: statusCode);
  }

  factory ApiException.format([String message = 'Failed to parse response from server.']) {
    return ApiException(message);
  }

  factory ApiException.unknown([
    String message = 'An unexpected error occurred.',
    dynamic details,
  ]) {
    return ApiException(message, details: details);
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$statusCode]: $message';
    }
    return 'ApiException: $message';
  }
}
