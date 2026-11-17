class AppConfig {
  static const String appName = "CRM Mobile";
  static const String version = "1.0";

  static const String crmUrl = String.fromEnvironment(
      'CRM_URL', defaultValue: 'https://crm.example.com');

  static const String restEndpoint =
      "/custom/QuickCRM/rest4_1.php";

  static const Duration networkTimeout =
      Duration(seconds: 30);

  static const bool enableLogging = false;
  static const bool debugMode = false;
}