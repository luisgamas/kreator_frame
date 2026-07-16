/// Availability status returned by the Google Play in-app update API.
enum InAppUpdateAvailability {
  /// No update is available or the check has not been performed yet.
  unknown,

  /// No update is available for the application.
  notAvailable,

  /// An update is available and can be started.
  available,

  /// A developer-triggered update was started previously and is still in progress.
  inProgress,

  /// The update check or execution failed.
  failed,
}

/// Pure domain entity representing the result of an in-app update operation.
///
/// This is the single source of truth for all update-related communication
/// between the infrastructure and presentation layers. It replaces the
/// previous string-based protocol with a typed, immutable value object.
class InAppUpdateEntity {
  final InAppUpdateAvailability availability;
  final String? errorMessage;

  const InAppUpdateEntity({
    this.availability = InAppUpdateAvailability.unknown,
    this.errorMessage,
  });

  InAppUpdateEntity copyWith({
    InAppUpdateAvailability? availability,
    String? errorMessage,
  }) {
    return InAppUpdateEntity(
      availability: availability ?? this.availability,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppUpdateEntity &&
          other.availability == availability &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode => availability.hashCode ^ errorMessage.hashCode;
}
