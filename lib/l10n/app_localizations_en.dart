// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AccelStats';

  @override
  String get permission_required_title => 'Location Permission Required';

  @override
  String get permission_required_message =>
      'AccelStats needs GPS access to measure speed. Please grant location permission.';

  @override
  String get permission_grant_button => 'Grant Permission';

  @override
  String get home_title => 'Car Acceleration\nMeasurement';

  @override
  String get home_subtitle =>
      'Mount your phone anywhere in the car.\nThe app auto-calibrates for any orientation.';

  @override
  String get home_startButton => 'Start Recording';

  @override
  String get home_viewRecordingsButton => 'View Recordings';

  @override
  String get home_default_recording_name_prefix => 'Run';

  @override
  String get home_name_dialog_title => 'Name this recording';

  @override
  String get home_name_dialog_confirm => 'Start';

  @override
  String get recording_appbar_calibrating => 'Calibrating...';

  @override
  String get recording_appbar_recording => 'Recording';

  @override
  String get recording_appbar_saved => 'Recording Saved';

  @override
  String get recording_appbar_ready => 'Ready';

  @override
  String get recording_not_found => 'Recording not found';

  @override
  String get recording_calibrating_title => 'Hold the phone still...';

  @override
  String get recording_calibrating_hint => 'Calibrating orientation';

  @override
  String get recording_speed_label => 'Speed';

  @override
  String get recording_accel_label => 'Acceleration';

  @override
  String get recording_pitch_label => 'Pitch';

  @override
  String get recording_roll_label => 'Roll';

  @override
  String get recording_peak_accel_label => 'Peak Accel';

  @override
  String get recording_peak_brake_label => 'Peak Brake';

  @override
  String get recording_peak_lateral_label => 'Peak Lateral';

  @override
  String get recording_heading_locked => 'Heading locked';

  @override
  String get recording_heading_calibrating => 'Calibrating heading...';

  @override
  String get recording_chart_speed_vs_accel => 'Speed vs Acceleration';

  @override
  String get recording_stop_button => 'Stop Recording';

  @override
  String get recording_chart_waiting_gps => 'Waiting for GPS data...';

  @override
  String get recording_saved_title => 'Recording saved!';

  @override
  String get recording_view_button => 'View Recording';

  @override
  String get recording_back_home_button => 'Back to Home';

  @override
  String get recording_warning_gps_lost =>
      'GPS permission lost — recording saved early.';

  @override
  String get recordings_title => 'Recordings';

  @override
  String get recordings_import_tooltip => 'Import';

  @override
  String get recordings_filter_all => 'All';

  @override
  String get recordings_filter_user => 'User';

  @override
  String get recordings_filter_dev => 'Dev';

  @override
  String get recordings_rename_dialog_title => 'Rename recording';

  @override
  String get recordings_rename_dialog_confirm => 'Rename';

  @override
  String get recordings_delete_title => 'Delete Recording';

  @override
  String recordings_delete_message(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get recordings_delete_cancel => 'Cancel';

  @override
  String get recordings_delete_confirm => 'Delete';

  @override
  String get recordings_import_success => 'Recording imported';

  @override
  String recordings_import_failed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get recordings_empty_title => 'No recordings yet';

  @override
  String get recordings_empty_filtered => 'No recordings match this filter.';

  @override
  String get recordings_empty_hint =>
      'Tap the button below to record your first run.';

  @override
  String get recordings_empty_cta => 'Start a recording';

  @override
  String get detail_default_title => 'Recording';

  @override
  String get detail_export_tooltip => 'Export';

  @override
  String get detail_export_save_csv => 'Save as CSV';

  @override
  String get detail_export_save_json => 'Save as JSON';

  @override
  String get detail_export_share_csv => 'Share as CSV';

  @override
  String get detail_export_share_json => 'Share as JSON';

  @override
  String detail_export_saved_to(String path) {
    return 'Saved to $path';
  }

  @override
  String detail_export_failed(String error) {
    return 'Export failed: $error';
  }

  @override
  String detail_share_failed(String error) {
    return 'Share failed: $error';
  }

  @override
  String get detail_empty => 'No data recorded';

  @override
  String get detail_chart_speed_vs_accel => 'Speed vs Acceleration';

  @override
  String get detail_chart_accel_time => 'Acceleration over Time';

  @override
  String get detail_chart_speed_time => 'Speed over Time';

  @override
  String get detail_summary_duration => 'Duration';

  @override
  String get detail_summary_max_speed => 'Max Speed';

  @override
  String get detail_summary_max_accel => 'Max Accel';

  @override
  String get detail_summary_max_brake => 'Max Brake';

  @override
  String get detail_chart_no_gps_accel => 'No GPS+accel data';

  @override
  String get detail_chart_no_accel => 'No acceleration data';

  @override
  String get detail_chart_no_speed => 'No GPS speed data';

  @override
  String get chart_axis_speed_kmh => 'Speed (km/h)';

  @override
  String get chart_axis_accel_g => 'Accel (g)';

  @override
  String get chart_axis_time_s => 'Time (s)';

  @override
  String get chart_axis_kmh => 'km/h';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appearance_section => 'Appearance';

  @override
  String get settings_developer_section => 'Developer';

  @override
  String get settings_theme_label => 'Theme';

  @override
  String get settings_theme_picker_title => 'Choose Theme';

  @override
  String get settings_theme_system => 'System default';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_devmode_label => 'Dev Mode';

  @override
  String get settings_devmode_hint => 'Show raw sensor data during recording';

  @override
  String get settings_language_section => 'Language';

  @override
  String get settings_language_label => 'Language';

  @override
  String get settings_language_picker_title => 'Choose Language';

  @override
  String get settings_language_system => 'Follow device language';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_language_hebrew => 'עברית';

  @override
  String get settings_vehicles_section => 'Vehicles';

  @override
  String get settings_my_cars_label => 'My Cars';

  @override
  String get settings_my_cars_hint => 'Manage reusable car profiles';

  @override
  String get manage_cars_title => 'My Cars';

  @override
  String get manage_cars_empty_title => 'No cars yet';

  @override
  String get manage_cars_empty_hint =>
      'Add a car to attach to your recordings.';

  @override
  String get manage_cars_add_button => 'Add car';

  @override
  String get manage_cars_edit_title => 'Edit car';

  @override
  String get manage_cars_new_title => 'New car';

  @override
  String get manage_cars_field_name => 'Name';

  @override
  String get manage_cars_field_make => 'Make';

  @override
  String get manage_cars_field_model => 'Model';

  @override
  String get manage_cars_field_year => 'Year';

  @override
  String get manage_cars_field_fuel_type => 'Fuel type';

  @override
  String get manage_cars_field_transmission => 'Transmission';

  @override
  String get manage_cars_save => 'Save';

  @override
  String get manage_cars_delete_title => 'Delete car';

  @override
  String manage_cars_delete_message(String name) {
    return 'Delete \"$name\"? Existing recordings will keep their values but lose the link.';
  }

  @override
  String get manage_cars_delete_confirm => 'Delete';

  @override
  String get manage_cars_delete_cancel => 'Cancel';

  @override
  String get manage_cars_fuel_petrol => 'Petrol';

  @override
  String get manage_cars_fuel_diesel => 'Diesel';

  @override
  String get manage_cars_fuel_electric => 'Electric';

  @override
  String get manage_cars_fuel_hybrid => 'Hybrid';

  @override
  String get manage_cars_fuel_other => 'Other';

  @override
  String get manage_cars_transmission_auto => 'Automatic';

  @override
  String get manage_cars_transmission_manual => 'Manual';

  @override
  String get manage_cars_transmission_dct => 'DCT';

  @override
  String get manage_cars_transmission_other => 'Other';

  @override
  String get detail_metadata_add_button => 'Add details';

  @override
  String get detail_metadata_edit_button => 'Edit details';

  @override
  String get detail_metadata_summary_car => 'Car';

  @override
  String get detail_metadata_summary_no_car => 'No car selected';

  @override
  String get detail_metadata_summary_drive_mode => 'Drive mode';

  @override
  String get detail_metadata_summary_passengers => 'Passengers';

  @override
  String get detail_metadata_summary_fuel_level => 'Fuel level';

  @override
  String get detail_metadata_summary_tyres => 'Tyres';

  @override
  String get detail_metadata_summary_weather => 'Weather';

  @override
  String get detail_metadata_sheet_title => 'Recording details';

  @override
  String get detail_metadata_field_car => 'Car';

  @override
  String get detail_metadata_field_drive_mode => 'Drive mode';

  @override
  String get detail_metadata_field_passenger_count => 'Passenger count';

  @override
  String get detail_metadata_field_fuel_level => 'Fuel level (%)';

  @override
  String get detail_metadata_field_tyre_type => 'Tyre type';

  @override
  String get detail_metadata_field_weather => 'Weather';

  @override
  String get detail_metadata_field_free_text => 'Notes';

  @override
  String get detail_metadata_car_none => 'None';

  @override
  String get detail_metadata_car_add_new => '+ Add new car…';

  @override
  String get detail_metadata_save => 'Save';

  @override
  String get detail_metadata_cancel => 'Cancel';

  @override
  String get dialog_name_field_label => 'Name';

  @override
  String get dialog_cancel => 'Cancel';
}
