import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @byDeveloper.
  ///
  /// In en, this message translates to:
  /// **'by {developer}'**
  String byDeveloper(Object developer);

  /// No description provided for @bottomWallSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Wallpaper as'**
  String get bottomWallSelectorTitle;

  /// No description provided for @bottomWallSelectorSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Would you like to set this image as your wallpaper, lock screen, or both?'**
  String get bottomWallSelectorSubTitle;

  /// No description provided for @bottomWallSelectorHS.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomWallSelectorHS;

  /// No description provided for @bottomWallSelectorLS.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get bottomWallSelectorLS;

  /// No description provided for @bottomWallSelectorBS.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get bottomWallSelectorBS;

  /// No description provided for @bottomWallSelectorNative.
  ///
  /// In en, this message translates to:
  /// **'Use Android Wallpaper Picker'**
  String get bottomWallSelectorNative;

  /// No description provided for @bottomWallSelectorChooser.
  ///
  /// In en, this message translates to:
  /// **'More options...'**
  String get bottomWallSelectorChooser;

  /// No description provided for @appliedOk.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper successfully applied!'**
  String get appliedOk;

  /// No description provided for @appliedError.
  ///
  /// In en, this message translates to:
  /// **'Error when applying wallpaper :('**
  String get appliedError;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Well isn\'t this embarrassing? We can\'t seem to find what you\'re looking for'**
  String get errorMessage;

  /// No description provided for @noFunction.
  ///
  /// In en, this message translates to:
  /// **'Function not available at the moment'**
  String get noFunction;

  /// No description provided for @downloadOk.
  ///
  /// In en, this message translates to:
  /// **'Successfully downloaded'**
  String get downloadOk;

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Download Error'**
  String get downloadError;

  /// No description provided for @settingsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get settingsAppBarTitle;

  /// No description provided for @donations.
  ///
  /// In en, this message translates to:
  /// **'Help us keep the experience ad-free'**
  String get donations;

  /// No description provided for @donationsNote.
  ///
  /// In en, this message translates to:
  /// **'Donations support the continued development and open source code of Kreator Frame. Content shared on this platform is the property of their respective creators.'**
  String get donationsNote;

  /// No description provided for @donationsButton.
  ///
  /// In en, this message translates to:
  /// **'Make donation'**
  String get donationsButton;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceLT1.
  ///
  /// In en, this message translates to:
  /// **'Application theme'**
  String get settingsAppearanceLT1;

  /// No description provided for @settingsAppearanceLST1.
  ///
  /// In en, this message translates to:
  /// **'Choose a preset theme'**
  String get settingsAppearanceLST1;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutLST1.
  ///
  /// In en, this message translates to:
  /// **'About the Kustom Pack'**
  String get settingsAboutLST1;

  /// No description provided for @settingsAboutLST2.
  ///
  /// In en, this message translates to:
  /// **'About the Dashboard'**
  String get settingsAboutLST2;

  /// No description provided for @aboutDashboard.
  ///
  /// In en, this message translates to:
  /// **'Kreator Frame is the dashboard that gives you full control to customize the look and feel of your mobile device with modern, personalized widgets. \n\nWith Kreator Frame, you can create a unique experience tailored to your needs. Widgets compatible with the Kustom Widget Maker app allow you to add additional features to your mobile device, such as widgets for music, weather, activity tracking and more. \n\nThanks to its minimalist and modern design, the application integrates perfectly with the style of your mobile device. Kreator Frame gives you the fluidity and control you need to easily customize your mobile device\'s home screen. \n\nThis dashboard is completely free, ad-free and OpenSource. If you find this platform useful and would like to support its continued development, please consider making a donation. The donations you make will help maintain and improve the dashboard, but do not affect the content shared by the widget creators. We greatly appreciate your support to keep this app available to everyone.'**
  String get aboutDashboard;

  /// No description provided for @aboutPackage.
  ///
  /// In en, this message translates to:
  /// **'{packageName} is a skin pack for Kustom, the most advanced wallpaper engine for android. This pack has been created by {developerName} and we appreciate your support by downloading this app directly from Google Play Store. \n\nIn this application you can find widgets and wallpapers that you can add to your home screen to give it a nicer look, remember that widgets can be modified by you for a more pleasant and accurate experience. \n\nIf you have any questions or advice do not hesitate to contact me through any of my social networks listed below.'**
  String aboutPackage(Object developerName, Object packageName);

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal Aspects'**
  String get settingsLegal;

  /// No description provided for @settingsLegalLT1.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get settingsLegalLT1;

  /// No description provided for @settingsLegalLST1.
  ///
  /// In en, this message translates to:
  /// **'Effective as of 10/10/2024'**
  String get settingsLegalLST1;

  /// No description provided for @settingsLegalLT2.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsLegalLT2;

  /// No description provided for @settingsLegalLST2.
  ///
  /// In en, this message translates to:
  /// **'Policy effective as of 10/10/2024'**
  String get settingsLegalLST2;

  /// No description provided for @settingsLicences.
  ///
  /// In en, this message translates to:
  /// **'Software licences'**
  String get settingsLicences;

  /// No description provided for @settingsLicencesLT1.
  ///
  /// In en, this message translates to:
  /// **'Licences (OSS)'**
  String get settingsLicencesLT1;

  /// No description provided for @settingsLicencesLST1.
  ///
  /// In en, this message translates to:
  /// **'Open source licences'**
  String get settingsLicencesLST1;

  /// No description provided for @settingsVersions.
  ///
  /// In en, this message translates to:
  /// **'Current Versions'**
  String get settingsVersions;

  /// No description provided for @themeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Selector'**
  String get themeAppBarTitle;

  /// No description provided for @themeSelector.
  ///
  /// In en, this message translates to:
  /// **'Select a theme'**
  String get themeSelector;

  /// No description provided for @themeColorSelector.
  ///
  /// In en, this message translates to:
  /// **'Select a colour for the theme'**
  String get themeColorSelector;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
