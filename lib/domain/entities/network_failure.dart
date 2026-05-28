/// Represents a network failure with a typed reason and optional metadata.
///
/// This entity lives in the domain layer and is free from transport-specific
/// details (no Dio, no HTTP status codes). It allows the presentation layer
/// to react to different failure modes without coupling to Dio internals.
class NetworkFailure {
  final NetworkFailureType type;
  final String message;
  final int? statusCode;

  const NetworkFailure({
    required this.type,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'NetworkFailure($type, "$message")';
}

/// Categorizes network failures into actionable types.
enum NetworkFailureType {
  /// No internet connection or the server is unreachable.
  connectionError,

  /// The server took too long to respond.
  timeout,

  /// The request was cancelled (e.g. user navigated away).
  cancelled,

  /// The server returned a non-2xx status code.
  serverError,

  /// The response body could not be parsed.
  parsingError,

  /// An unexpected or unknown error occurred.
  unknown,
}
