// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'AccelStats';

  @override
  String get permission_required_title => 'נדרשת הרשאת מיקום';

  @override
  String get permission_required_message =>
      'AccelStats זקוק לגישה ל-GPS כדי למדוד מהירות. אנא אשרו הרשאת מיקום.';

  @override
  String get permission_grant_button => 'אשר הרשאה';

  @override
  String get home_title => 'מדידת תאוצת\nרכב';

  @override
  String get home_subtitle =>
      'הניחו את הטלפון בכל מקום ברכב.\nהאפליקציה מבצעת כיול אוטומטי לכל כיוון.';

  @override
  String get home_startButton => 'התחל הקלטה';

  @override
  String get home_viewRecordingsButton => 'הצג הקלטות';

  @override
  String get home_default_recording_name_prefix => 'נסיעה';

  @override
  String get home_name_dialog_title => 'תנו שם להקלטה';

  @override
  String get home_name_dialog_confirm => 'התחל';

  @override
  String get recording_appbar_calibrating => 'מתכייל...';

  @override
  String get recording_appbar_recording => 'מקליט';

  @override
  String get recording_appbar_saved => 'ההקלטה נשמרה';

  @override
  String get recording_appbar_ready => 'מוכן';

  @override
  String get recording_not_found => 'ההקלטה לא נמצאה';

  @override
  String get recording_calibrating_title => 'החזיקו את הטלפון יציב...';

  @override
  String get recording_calibrating_hint => 'מכייל אוריינטציה';

  @override
  String get recording_speed_label => 'מהירות';

  @override
  String get recording_accel_label => 'תאוצה';

  @override
  String get recording_pitch_label => 'Pitch';

  @override
  String get recording_roll_label => 'Roll';

  @override
  String get recording_peak_accel_label => 'תאוצת שיא';

  @override
  String get recording_peak_brake_label => 'בלימת שיא';

  @override
  String get recording_peak_lateral_label => 'צד שיא';

  @override
  String get recording_heading_locked => 'כיוון ננעל';

  @override
  String get recording_heading_calibrating => 'מכייל כיוון...';

  @override
  String get recording_chart_speed_vs_accel => 'מהירות מול תאוצה';

  @override
  String get recording_stop_button => 'עצור הקלטה';

  @override
  String get recording_chart_waiting_gps => 'ממתין לנתוני GPS...';

  @override
  String get recording_saved_title => 'ההקלטה נשמרה!';

  @override
  String get recording_view_button => 'צפה בהקלטה';

  @override
  String get recording_back_home_button => 'חזרה לעמוד הבית';

  @override
  String get recording_warning_gps_lost =>
      'הרשאת GPS אבדה — ההקלטה נשמרה מוקדם.';

  @override
  String get recordings_title => 'הקלטות';

  @override
  String get recordings_import_tooltip => 'ייבוא';

  @override
  String get recordings_filter_all => 'הכל';

  @override
  String get recordings_filter_user => 'משתמש';

  @override
  String get recordings_filter_dev => 'פיתוח';

  @override
  String get recordings_rename_dialog_title => 'שינוי שם להקלטה';

  @override
  String get recordings_rename_dialog_confirm => 'שנה שם';

  @override
  String get recordings_delete_title => 'מחיקת הקלטה';

  @override
  String recordings_delete_message(String name) {
    return 'למחוק את \"$name\"? לא ניתן לבטל פעולה זו.';
  }

  @override
  String get recordings_delete_cancel => 'ביטול';

  @override
  String get recordings_delete_confirm => 'מחק';

  @override
  String get recordings_import_success => 'ההקלטה יובאה';

  @override
  String recordings_import_failed(String error) {
    return 'ייבוא נכשל: $error';
  }

  @override
  String get recordings_empty_title => 'אין הקלטות עדיין';

  @override
  String get recordings_empty_filtered => 'אין הקלטות התואמות לסינון זה.';

  @override
  String get recordings_empty_hint =>
      'הקישו על הכפתור למטה כדי להקליט נסיעה ראשונה.';

  @override
  String get recordings_empty_cta => 'התחל הקלטה';

  @override
  String get detail_default_title => 'הקלטה';

  @override
  String get detail_export_tooltip => 'ייצוא';

  @override
  String get detail_export_save_csv => 'שמור כ-CSV';

  @override
  String get detail_export_save_json => 'שמור כ-JSON';

  @override
  String get detail_export_share_csv => 'שתף כ-CSV';

  @override
  String get detail_export_share_json => 'שתף כ-JSON';

  @override
  String detail_export_saved_to(String path) {
    return 'נשמר אל $path';
  }

  @override
  String detail_export_failed(String error) {
    return 'ייצוא נכשל: $error';
  }

  @override
  String detail_share_failed(String error) {
    return 'שיתוף נכשל: $error';
  }

  @override
  String get detail_empty => 'אין נתונים מוקלטים';

  @override
  String get detail_chart_speed_vs_accel => 'מהירות מול תאוצה';

  @override
  String get detail_chart_accel_time => 'תאוצה לאורך זמן';

  @override
  String get detail_chart_speed_time => 'מהירות לאורך זמן';

  @override
  String get detail_summary_duration => 'משך';

  @override
  String get detail_summary_max_speed => 'מהירות מרבית';

  @override
  String get detail_summary_max_accel => 'תאוצה מרבית';

  @override
  String get detail_summary_max_brake => 'בלימה מרבית';

  @override
  String get detail_chart_no_gps_accel => 'אין נתוני GPS+תאוצה';

  @override
  String get detail_chart_no_accel => 'אין נתוני תאוצה';

  @override
  String get detail_chart_no_speed => 'אין נתוני מהירות GPS';

  @override
  String get chart_axis_speed_kmh => 'מהירות (km/h)';

  @override
  String get chart_axis_accel_g => 'תאוצה (g)';

  @override
  String get chart_axis_time_s => 'זמן (s)';

  @override
  String get chart_axis_kmh => 'km/h';

  @override
  String get settings_title => 'הגדרות';

  @override
  String get settings_appearance_section => 'מראה';

  @override
  String get settings_developer_section => 'מפתח';

  @override
  String get settings_theme_label => 'ערכת נושא';

  @override
  String get settings_theme_picker_title => 'בחר ערכת נושא';

  @override
  String get settings_theme_system => 'ברירת מחדל של המערכת';

  @override
  String get settings_theme_light => 'בהיר';

  @override
  String get settings_theme_dark => 'כהה';

  @override
  String get settings_devmode_label => 'מצב מפתח';

  @override
  String get settings_devmode_hint => 'הצג נתוני חיישנים גולמיים בזמן הקלטה';

  @override
  String get settings_language_section => 'שפה';

  @override
  String get settings_language_label => 'שפה';

  @override
  String get settings_language_picker_title => 'בחר שפה';

  @override
  String get settings_language_system => 'שפת המכשיר';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_language_hebrew => 'עברית';

  @override
  String get settings_vehicles_section => 'רכבים';

  @override
  String get settings_my_cars_label => 'הרכבים שלי';

  @override
  String get settings_my_cars_hint => 'ניהול פרופילי רכב לשימוש חוזר';

  @override
  String get manage_cars_title => 'הרכבים שלי';

  @override
  String get manage_cars_empty_title => 'אין רכבים עדיין';

  @override
  String get manage_cars_empty_hint => 'הוסיפו רכב כדי לשייך אותו להקלטות.';

  @override
  String get manage_cars_add_button => 'הוסף רכב';

  @override
  String get manage_cars_edit_title => 'עריכת רכב';

  @override
  String get manage_cars_new_title => 'רכב חדש';

  @override
  String get manage_cars_field_name => 'שם';

  @override
  String get manage_cars_field_make => 'יצרן';

  @override
  String get manage_cars_field_model => 'דגם';

  @override
  String get manage_cars_field_year => 'שנה';

  @override
  String get manage_cars_field_fuel_type => 'סוג דלק';

  @override
  String get manage_cars_field_transmission => 'תיבת הילוכים';

  @override
  String get manage_cars_save => 'שמור';

  @override
  String get manage_cars_delete_title => 'מחיקת רכב';

  @override
  String manage_cars_delete_message(String name) {
    return 'למחוק את \"$name\"? הקלטות קיימות ישמרו את הערכים אך יאבדו את הקישור.';
  }

  @override
  String get manage_cars_delete_confirm => 'מחק';

  @override
  String get manage_cars_delete_cancel => 'ביטול';

  @override
  String get manage_cars_fuel_petrol => 'בנזין';

  @override
  String get manage_cars_fuel_diesel => 'דיזל';

  @override
  String get manage_cars_fuel_electric => 'חשמלי';

  @override
  String get manage_cars_fuel_hybrid => 'היברידי';

  @override
  String get manage_cars_fuel_other => 'אחר';

  @override
  String get manage_cars_transmission_auto => 'אוטומטית';

  @override
  String get manage_cars_transmission_manual => 'ידנית';

  @override
  String get manage_cars_transmission_dct => 'DCT';

  @override
  String get manage_cars_transmission_other => 'אחר';

  @override
  String get detail_metadata_add_button => 'הוסף פרטים';

  @override
  String get detail_metadata_edit_button => 'ערוך פרטים';

  @override
  String get detail_metadata_summary_car => 'רכב';

  @override
  String get detail_metadata_summary_no_car => 'לא נבחר רכב';

  @override
  String get detail_metadata_summary_drive_mode => 'מצב נהיגה';

  @override
  String get detail_metadata_summary_passengers => 'נוסעים';

  @override
  String get detail_metadata_summary_fuel_level => 'רמת דלק';

  @override
  String get detail_metadata_summary_tyres => 'צמיגים';

  @override
  String get detail_metadata_summary_weather => 'מזג אוויר';

  @override
  String get detail_metadata_sheet_title => 'פרטי הקלטה';

  @override
  String get detail_metadata_field_car => 'רכב';

  @override
  String get detail_metadata_field_drive_mode => 'מצב נהיגה';

  @override
  String get detail_metadata_field_passenger_count => 'מספר נוסעים';

  @override
  String get detail_metadata_field_fuel_level => 'רמת דלק (%)';

  @override
  String get detail_metadata_field_tyre_type => 'סוג צמיגים';

  @override
  String get detail_metadata_field_weather => 'מזג אוויר';

  @override
  String get detail_metadata_field_free_text => 'הערות';

  @override
  String get detail_metadata_car_none => 'ללא';

  @override
  String get detail_metadata_car_add_new => '+ הוסף רכב חדש…';

  @override
  String get detail_metadata_save => 'שמור';

  @override
  String get detail_metadata_cancel => 'ביטול';

  @override
  String get dialog_name_field_label => 'שם';

  @override
  String get dialog_cancel => 'ביטול';
}
