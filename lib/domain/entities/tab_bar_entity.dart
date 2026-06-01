/// Identifies the type of content a tab represents.
///
/// Kept as a pure Dart enum so the [TabBarEntity] can stay independent
/// from any Flutter UI framework types in the domain layer.
enum TabBarType {
  /// Kustom widget pack (KWGT).
  kustomWidget,

  /// Kustom live wallpaper pack (KLWP).
  kustomLiveWallpaper,

  /// User-provided wallpapers list.
  wallpapers,
}

/// Pure data entity describing a tab in the home screen tab bar.
///
/// This entity intentionally avoids any Flutter UI types (such as [Widget]
/// or [Tab]) to keep the domain layer free of UI framework dependencies,
/// following Clean Architecture guidelines. The presentation layer is
/// responsible for mapping [type] / [label] into actual widgets.
class TabBarEntity {
  /// Type of content the tab should render.
  final TabBarType type;

  /// Display label shown in the tab bar header.
  final String label;

  const TabBarEntity({
    required this.type,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabBarEntity && other.type == type && other.label == label;

  @override
  int get hashCode => Object.hash(type, label);
}
