// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String byDeveloper(Object developer) {
    return 'by $developer';
  }

  @override
  String get bottomWallSelectorTitle => 'Set Wallpaper as';

  @override
  String get bottomWallSelectorSubTitle =>
      'Would you like to set this image as your wallpaper, lock screen, or both?';

  @override
  String get bottomWallSelectorHS => 'Home';

  @override
  String get bottomWallSelectorLS => 'Lock';

  @override
  String get bottomWallSelectorBS => 'Both';

  @override
  String get bottomWallSelectorNative => 'Use Android Wallpaper Picker';

  @override
  String get bottomWallSelectorChooser => 'More options...';

  @override
  String get appliedOk => 'Wallpaper successfully applied!';

  @override
  String get appliedError => 'Error when applying wallpaper :(';

  @override
  String get errorMessage =>
      'Well isn\'t this embarrassing? We can\'t seem to find what you\'re looking for';

  @override
  String get noFunction => 'Function not available at the moment';

  @override
  String get downloadOk => 'Successfully downloaded';

  @override
  String get downloadError => 'Download Error';

  @override
  String get settingsAppBarTitle => 'Configuration';

  @override
  String get donations => 'Help us keep the experience ad-free';

  @override
  String get donationsNote =>
      'Donations support the continued development and open source code of Kreator Frame. Content shared on this platform is the property of their respective creators.';

  @override
  String get donationsButton => 'Make donation';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceLT1 => 'Application theme';

  @override
  String get settingsAppearanceLST1 => 'Choose a preset theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutLST1 => 'About the Kustom Pack';

  @override
  String get settingsAboutLST2 => 'About the Dashboard';

  @override
  String get aboutDashboard =>
      'Kreator Frame is the dashboard that gives you full control to customize the look and feel of your mobile device with modern, personalized widgets. \n\nWith Kreator Frame, you can create a unique experience tailored to your needs. Widgets compatible with the Kustom Widget Maker app allow you to add additional features to your mobile device, such as widgets for music, weather, activity tracking and more. \n\nThanks to its minimalist and modern design, the application integrates perfectly with the style of your mobile device. Kreator Frame gives you the fluidity and control you need to easily customize your mobile device\'s home screen. \n\nThis dashboard is completely free, ad-free and OpenSource. If you find this platform useful and would like to support its continued development, please consider making a donation. The donations you make will help maintain and improve the dashboard, but do not affect the content shared by the widget creators. We greatly appreciate your support to keep this app available to everyone.';

  @override
  String aboutPackage(Object developerName, Object packageName) {
    return '$packageName is a skin pack for Kustom, the most advanced wallpaper engine for android. This pack has been created by $developerName and we appreciate your support by downloading this app directly from Google Play Store. \n\nIn this application you can find widgets and wallpapers that you can add to your home screen to give it a nicer look, remember that widgets can be modified by you for a more pleasant and accurate experience. \n\nIf you have any questions or advice do not hesitate to contact me through any of my social networks listed below.';
  }

  @override
  String get settingsLegal => 'Legal Aspects';

  @override
  String get settingsLegalLT1 => 'Terms and Conditions';

  @override
  String get settingsLegalLST1 => 'Effective as of 10/10/2024';

  @override
  String get settingsLegalLT2 => 'Privacy Policy';

  @override
  String get settingsLegalLST2 => 'Policy effective as of 10/10/2024';

  @override
  String get settingsLicences => 'Software licences';

  @override
  String get settingsLicencesLT1 => 'Licences (OSS)';

  @override
  String get settingsLicencesLST1 => 'Open source licences';

  @override
  String get settingsVersions => 'Current Versions';

  @override
  String get themeAppBarTitle => 'Theme Selector';

  @override
  String get themeSelector => 'Select a theme';

  @override
  String get themeColorSelector => 'Select a colour for the theme';
}
