/// Kustom app package names and editor activity targets.
///
/// Used to launch KWGT/KLWP editors or redirect to the Play Store
/// when the apps are not installed.
class KustomConfig {
  KustomConfig._();

  // Package names
  static const String pkgKWGT = 'org.kustom.widget';
  static const String pkgKLWP = 'org.kustom.wallpaper';

  // Editor activities
  static const String activityKWGT = 'org.kustom.widget.picker.WidgetPicker';
  static const String activityKLWP = 'org.kustom.lib.editor.WpAdvancedEditorActivity';
}
