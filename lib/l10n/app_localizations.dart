import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

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
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AccelStats'**
  String get appTitle;

  /// No description provided for @permission_required_title.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get permission_required_title;

  /// No description provided for @permission_required_message.
  ///
  /// In en, this message translates to:
  /// **'AccelStats needs GPS access to measure speed. Please grant location permission.'**
  String get permission_required_message;

  /// No description provided for @permission_grant_button.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get permission_grant_button;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Car Acceleration\nMeasurement'**
  String get home_title;

  /// No description provided for @home_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Mount your phone anywhere in the car.\nThe app auto-calibrates for any orientation.'**
  String get home_subtitle;

  /// No description provided for @home_startButton.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get home_startButton;

  /// No description provided for @home_viewRecordingsButton.
  ///
  /// In en, this message translates to:
  /// **'View Recordings'**
  String get home_viewRecordingsButton;

  /// No description provided for @home_default_recording_name_prefix.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get home_default_recording_name_prefix;

  /// No description provided for @home_name_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Name this recording'**
  String get home_name_dialog_title;

  /// No description provided for @home_name_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get home_name_dialog_confirm;

  /// No description provided for @recording_appbar_calibrating.
  ///
  /// In en, this message translates to:
  /// **'Calibrating...'**
  String get recording_appbar_calibrating;

  /// No description provided for @recording_appbar_recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording_appbar_recording;

  /// No description provided for @recording_appbar_saved.
  ///
  /// In en, this message translates to:
  /// **'Recording Saved'**
  String get recording_appbar_saved;

  /// No description provided for @recording_appbar_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get recording_appbar_ready;

  /// No description provided for @recording_not_found.
  ///
  /// In en, this message translates to:
  /// **'Recording not found'**
  String get recording_not_found;

  /// No description provided for @recording_calibrating_title.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone still...'**
  String get recording_calibrating_title;

  /// No description provided for @recording_calibrating_hint.
  ///
  /// In en, this message translates to:
  /// **'Calibrating orientation'**
  String get recording_calibrating_hint;

  /// No description provided for @recording_speed_label.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get recording_speed_label;

  /// No description provided for @recording_accel_label.
  ///
  /// In en, this message translates to:
  /// **'Acceleration'**
  String get recording_accel_label;

  /// No description provided for @recording_pitch_label.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get recording_pitch_label;

  /// No description provided for @recording_roll_label.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get recording_roll_label;

  /// No description provided for @recording_peak_accel_label.
  ///
  /// In en, this message translates to:
  /// **'Peak Accel'**
  String get recording_peak_accel_label;

  /// No description provided for @recording_peak_brake_label.
  ///
  /// In en, this message translates to:
  /// **'Peak Brake'**
  String get recording_peak_brake_label;

  /// No description provided for @recording_peak_lateral_label.
  ///
  /// In en, this message translates to:
  /// **'Peak Lateral'**
  String get recording_peak_lateral_label;

  /// No description provided for @recording_heading_locked.
  ///
  /// In en, this message translates to:
  /// **'Heading locked'**
  String get recording_heading_locked;

  /// No description provided for @recording_heading_calibrating.
  ///
  /// In en, this message translates to:
  /// **'Calibrating heading...'**
  String get recording_heading_calibrating;

  /// No description provided for @recording_chart_speed_vs_accel.
  ///
  /// In en, this message translates to:
  /// **'Speed vs Acceleration'**
  String get recording_chart_speed_vs_accel;

  /// No description provided for @recording_stop_button.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get recording_stop_button;

  /// No description provided for @recording_chart_waiting_gps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS data...'**
  String get recording_chart_waiting_gps;

  /// No description provided for @recording_saved_title.
  ///
  /// In en, this message translates to:
  /// **'Recording saved!'**
  String get recording_saved_title;

  /// No description provided for @recording_view_button.
  ///
  /// In en, this message translates to:
  /// **'View Recording'**
  String get recording_view_button;

  /// No description provided for @recording_back_home_button.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get recording_back_home_button;

  /// No description provided for @recording_warning_gps_lost.
  ///
  /// In en, this message translates to:
  /// **'GPS permission lost — recording saved early.'**
  String get recording_warning_gps_lost;

  /// No description provided for @recordings_title.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get recordings_title;

  /// No description provided for @recordings_import_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get recordings_import_tooltip;

  /// No description provided for @recordings_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recordings_filter_all;

  /// No description provided for @recordings_filter_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get recordings_filter_user;

  /// No description provided for @recordings_filter_dev.
  ///
  /// In en, this message translates to:
  /// **'Dev'**
  String get recordings_filter_dev;

  /// No description provided for @recordings_rename_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Rename recording'**
  String get recordings_rename_dialog_title;

  /// No description provided for @recordings_rename_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get recordings_rename_dialog_confirm;

  /// No description provided for @recordings_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Recording'**
  String get recordings_delete_title;

  /// No description provided for @recordings_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String recordings_delete_message(String name);

  /// No description provided for @recordings_delete_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get recordings_delete_cancel;

  /// No description provided for @recordings_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recordings_delete_confirm;

  /// No description provided for @recordings_import_success.
  ///
  /// In en, this message translates to:
  /// **'Recording imported'**
  String get recordings_import_success;

  /// No description provided for @recordings_import_failed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String recordings_import_failed(String error);

  /// No description provided for @recordings_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get recordings_empty_title;

  /// No description provided for @recordings_empty_filtered.
  ///
  /// In en, this message translates to:
  /// **'No recordings match this filter.'**
  String get recordings_empty_filtered;

  /// No description provided for @recordings_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to record your first run.'**
  String get recordings_empty_hint;

  /// No description provided for @recordings_empty_cta.
  ///
  /// In en, this message translates to:
  /// **'Start a recording'**
  String get recordings_empty_cta;

  /// No description provided for @detail_default_title.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get detail_default_title;

  /// No description provided for @detail_export_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get detail_export_tooltip;

  /// No description provided for @detail_export_save_csv.
  ///
  /// In en, this message translates to:
  /// **'Save as CSV'**
  String get detail_export_save_csv;

  /// No description provided for @detail_export_save_json.
  ///
  /// In en, this message translates to:
  /// **'Save as JSON'**
  String get detail_export_save_json;

  /// No description provided for @detail_export_share_csv.
  ///
  /// In en, this message translates to:
  /// **'Share as CSV'**
  String get detail_export_share_csv;

  /// No description provided for @detail_export_share_json.
  ///
  /// In en, this message translates to:
  /// **'Share as JSON'**
  String get detail_export_share_json;

  /// No description provided for @detail_export_saved_to.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String detail_export_saved_to(String path);

  /// No description provided for @detail_export_failed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String detail_export_failed(String error);

  /// No description provided for @detail_share_failed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String detail_share_failed(String error);

  /// No description provided for @detail_empty.
  ///
  /// In en, this message translates to:
  /// **'No data recorded'**
  String get detail_empty;

  /// No description provided for @detail_chart_speed_vs_accel.
  ///
  /// In en, this message translates to:
  /// **'Speed vs Acceleration'**
  String get detail_chart_speed_vs_accel;

  /// No description provided for @detail_chart_accel_time.
  ///
  /// In en, this message translates to:
  /// **'Acceleration over Time'**
  String get detail_chart_accel_time;

  /// No description provided for @detail_chart_speed_time.
  ///
  /// In en, this message translates to:
  /// **'Speed over Time'**
  String get detail_chart_speed_time;

  /// No description provided for @detail_summary_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get detail_summary_duration;

  /// No description provided for @detail_summary_max_speed.
  ///
  /// In en, this message translates to:
  /// **'Max Speed'**
  String get detail_summary_max_speed;

  /// No description provided for @detail_summary_max_accel.
  ///
  /// In en, this message translates to:
  /// **'Max Accel'**
  String get detail_summary_max_accel;

  /// No description provided for @detail_summary_max_brake.
  ///
  /// In en, this message translates to:
  /// **'Max Brake'**
  String get detail_summary_max_brake;

  /// No description provided for @detail_chart_no_gps_accel.
  ///
  /// In en, this message translates to:
  /// **'No GPS+accel data'**
  String get detail_chart_no_gps_accel;

  /// No description provided for @detail_chart_no_accel.
  ///
  /// In en, this message translates to:
  /// **'No acceleration data'**
  String get detail_chart_no_accel;

  /// No description provided for @detail_chart_no_speed.
  ///
  /// In en, this message translates to:
  /// **'No GPS speed data'**
  String get detail_chart_no_speed;

  /// No description provided for @chart_axis_speed_kmh.
  ///
  /// In en, this message translates to:
  /// **'Speed (km/h)'**
  String get chart_axis_speed_kmh;

  /// No description provided for @chart_axis_accel_g.
  ///
  /// In en, this message translates to:
  /// **'Accel (g)'**
  String get chart_axis_accel_g;

  /// No description provided for @chart_axis_time_s.
  ///
  /// In en, this message translates to:
  /// **'Time (s)'**
  String get chart_axis_time_s;

  /// No description provided for @chart_axis_kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get chart_axis_kmh;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_appearance_section.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance_section;

  /// No description provided for @settings_developer_section.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settings_developer_section;

  /// No description provided for @settings_theme_label.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme_label;

  /// No description provided for @settings_theme_picker_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get settings_theme_picker_title;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_devmode_label.
  ///
  /// In en, this message translates to:
  /// **'Dev Mode'**
  String get settings_devmode_label;

  /// No description provided for @settings_devmode_hint.
  ///
  /// In en, this message translates to:
  /// **'Show raw sensor data during recording'**
  String get settings_devmode_hint;

  /// No description provided for @settings_language_section.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language_section;

  /// No description provided for @settings_language_label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language_label;

  /// No description provided for @settings_language_picker_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settings_language_picker_title;

  /// No description provided for @settings_language_system.
  ///
  /// In en, this message translates to:
  /// **'Follow device language'**
  String get settings_language_system;

  /// No description provided for @settings_language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_language_english;

  /// No description provided for @settings_language_hebrew.
  ///
  /// In en, this message translates to:
  /// **'עברית'**
  String get settings_language_hebrew;

  /// No description provided for @settings_vehicles_section.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get settings_vehicles_section;

  /// No description provided for @settings_my_cars_label.
  ///
  /// In en, this message translates to:
  /// **'My Cars'**
  String get settings_my_cars_label;

  /// No description provided for @settings_my_cars_hint.
  ///
  /// In en, this message translates to:
  /// **'Manage reusable car profiles'**
  String get settings_my_cars_hint;

  /// No description provided for @manage_cars_title.
  ///
  /// In en, this message translates to:
  /// **'My Cars'**
  String get manage_cars_title;

  /// No description provided for @manage_cars_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No cars yet'**
  String get manage_cars_empty_title;

  /// No description provided for @manage_cars_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a car to attach to your recordings.'**
  String get manage_cars_empty_hint;

  /// No description provided for @manage_cars_add_button.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get manage_cars_add_button;

  /// No description provided for @manage_cars_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit car'**
  String get manage_cars_edit_title;

  /// No description provided for @manage_cars_new_title.
  ///
  /// In en, this message translates to:
  /// **'New car'**
  String get manage_cars_new_title;

  /// No description provided for @manage_cars_field_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get manage_cars_field_name;

  /// No description provided for @manage_cars_field_make.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get manage_cars_field_make;

  /// No description provided for @manage_cars_field_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get manage_cars_field_model;

  /// No description provided for @manage_cars_field_year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get manage_cars_field_year;

  /// No description provided for @manage_cars_field_fuel_type.
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get manage_cars_field_fuel_type;

  /// No description provided for @manage_cars_field_transmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get manage_cars_field_transmission;

  /// No description provided for @manage_cars_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get manage_cars_save;

  /// No description provided for @manage_cars_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete car'**
  String get manage_cars_delete_title;

  /// No description provided for @manage_cars_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Existing recordings will keep their values but lose the link.'**
  String manage_cars_delete_message(String name);

  /// No description provided for @manage_cars_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get manage_cars_delete_confirm;

  /// No description provided for @manage_cars_delete_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get manage_cars_delete_cancel;

  /// No description provided for @manage_cars_fuel_petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get manage_cars_fuel_petrol;

  /// No description provided for @manage_cars_fuel_diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get manage_cars_fuel_diesel;

  /// No description provided for @manage_cars_fuel_electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get manage_cars_fuel_electric;

  /// No description provided for @manage_cars_fuel_hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get manage_cars_fuel_hybrid;

  /// No description provided for @manage_cars_fuel_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get manage_cars_fuel_other;

  /// No description provided for @manage_cars_transmission_auto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get manage_cars_transmission_auto;

  /// No description provided for @manage_cars_transmission_manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manage_cars_transmission_manual;

  /// No description provided for @manage_cars_transmission_dct.
  ///
  /// In en, this message translates to:
  /// **'DCT'**
  String get manage_cars_transmission_dct;

  /// No description provided for @manage_cars_transmission_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get manage_cars_transmission_other;

  /// No description provided for @detail_metadata_add_button.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get detail_metadata_add_button;

  /// No description provided for @detail_metadata_edit_button.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get detail_metadata_edit_button;

  /// No description provided for @detail_metadata_summary_car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get detail_metadata_summary_car;

  /// No description provided for @detail_metadata_summary_no_car.
  ///
  /// In en, this message translates to:
  /// **'No car selected'**
  String get detail_metadata_summary_no_car;

  /// No description provided for @detail_metadata_summary_drive_mode.
  ///
  /// In en, this message translates to:
  /// **'Drive mode'**
  String get detail_metadata_summary_drive_mode;

  /// No description provided for @detail_metadata_summary_passengers.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get detail_metadata_summary_passengers;

  /// No description provided for @detail_metadata_summary_fuel_level.
  ///
  /// In en, this message translates to:
  /// **'Fuel level'**
  String get detail_metadata_summary_fuel_level;

  /// No description provided for @detail_metadata_summary_tyres.
  ///
  /// In en, this message translates to:
  /// **'Tyres'**
  String get detail_metadata_summary_tyres;

  /// No description provided for @detail_metadata_summary_weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get detail_metadata_summary_weather;

  /// No description provided for @detail_metadata_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Recording details'**
  String get detail_metadata_sheet_title;

  /// No description provided for @detail_metadata_field_car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get detail_metadata_field_car;

  /// No description provided for @detail_metadata_field_drive_mode.
  ///
  /// In en, this message translates to:
  /// **'Drive mode'**
  String get detail_metadata_field_drive_mode;

  /// No description provided for @detail_metadata_field_passenger_count.
  ///
  /// In en, this message translates to:
  /// **'Passenger count'**
  String get detail_metadata_field_passenger_count;

  /// No description provided for @detail_metadata_field_fuel_level.
  ///
  /// In en, this message translates to:
  /// **'Fuel level (%)'**
  String get detail_metadata_field_fuel_level;

  /// No description provided for @detail_metadata_field_tyre_type.
  ///
  /// In en, this message translates to:
  /// **'Tyre type'**
  String get detail_metadata_field_tyre_type;

  /// No description provided for @detail_metadata_field_weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get detail_metadata_field_weather;

  /// No description provided for @detail_metadata_field_free_text.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detail_metadata_field_free_text;

  /// No description provided for @detail_metadata_car_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get detail_metadata_car_none;

  /// No description provided for @detail_metadata_car_add_new.
  ///
  /// In en, this message translates to:
  /// **'+ Add new car…'**
  String get detail_metadata_car_add_new;

  /// No description provided for @detail_metadata_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get detail_metadata_save;

  /// No description provided for @detail_metadata_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get detail_metadata_cancel;

  /// No description provided for @dialog_name_field_label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dialog_name_field_label;

  /// No description provided for @dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;
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
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
