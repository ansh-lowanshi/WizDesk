/// Base Exception class
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class CacheException extends AppException {
  const CacheException([super.message = 'A local storage error occurred.']);
}

class TaskNotFoundException extends AppException {
  const TaskNotFoundException([super.message = 'The requested task was not found.']);
}

class InvalidInputException extends AppException {
  const InvalidInputException([super.message = 'Invalid task input provided.']);
}
