import '../models/lead.dart';
import 'auth_service.dart';
import 'lead_service.dart';
import 'session_manager.dart';
import 'secure_storage_service.dart';
import 'suitecrm_client.dart';

class ExpoSetupOptions {
  final List<String> events;
  final List<String> leadSources;

  const ExpoSetupOptions({
    required this.events,
    required this.leadSources,
  });
}

class ExpoService {
  static const String username = String.fromEnvironment(
    'EXPO_USERNAME', defaultValue: 'expo');

  static const List<String> fallbackEvents = [
    'Example Trade Show',
    'Other',
  ];

  static const List<String> fallbackLeadSources = [
    'Trade Show',
    'Conference',
    'Exhibition',
    'Referral',
    'Other',
  ];

  final AuthService _authService = AuthService();
  final LeadService _leadService = LeadService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final SuiteCRMClient _client = SuiteCRMClient();

  Future<bool> enterExpoMode(String password) async {
    final result = await _authService.login(username, password);

    if (!result.success) {
      throw Exception(result.error ?? 'Expo login failed.');
    }

    SessionManager.sessionId = result.sessionId;
    SessionManager.userId = result.userId;
    SessionManager.username = result.username;
    SessionManager.fullName = result.fullName;
    SessionManager.isAdmin = result.isAdmin;

    await _secureStorage.saveExpoPassword(password);
    return true;
  }

  Future<bool> trySavedExpoLogin() async {
    final password = await _secureStorage.readExpoPassword();
    if (password == null || password.isEmpty) return false;

    try {
      final ok = await enterExpoMode(password);
      if (ok) return true;
    } catch (_) {
      // Fall through to clear the stale credential below.
    }

    await _secureStorage.clearExpoPassword();
    SessionManager.clear();
    return false;
  }

  Future<void> forgetExpoPassword() async {
    await _secureStorage.clearExpoPassword();
  }

  Future<ExpoSetupOptions> loadSetupOptions() async {
    List<String> leadSources = fallbackLeadSources;
    List<String> events = fallbackEvents;

    try {
      final crmSources = await _client.getModuleFieldOptions(
        'Leads',
        'lead_source',
      );
      if (crmSources.isNotEmpty) {
        leadSources = _ensureOther(crmSources);
      }
    } catch (_) {
      // Keep safe local defaults if metadata is unavailable.
    }

    try {
      final modules = await _client.getAvailableModulePermissions();
      final hasEventsModule = modules.keys.any(
        (key) => key.toLowerCase() == 'events',
      );

      if (hasEventsModule) {
        final crmEvents = await _client.getSimpleEntryNames('Events');
        if (crmEvents.isNotEmpty) {
          events = _ensureOther(crmEvents);
        }
      }
    } catch (_) {
      // Events is not a standard module on every SuiteCRM installation.
    }

    return ExpoSetupOptions(
      events: events,
      leadSources: leadSources,
    );
  }

  List<String> _ensureOther(List<String> values) {
    final cleaned = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    if (!cleaned.any((value) => value.toLowerCase() == 'other')) {
      cleaned.add('Other');
    }
    return cleaned;
  }

  Future<bool> submitLead({
    required String firstName,
    required String lastName,
    required String company,
    required String title,
    required String email,
    required String mobile,
    required String phone,
    required String interest,
    required String otherInterest,
    required String event,
    required String leadSource,
    required String otherLeadSource,
    required String notes,
  }) {
    final effectiveInterest =
        interest == 'Other' && otherInterest.trim().isNotEmpty
            ? otherInterest.trim()
            : interest;

    final effectiveLeadSource =
        leadSource == 'Other' && otherLeadSource.trim().isNotEmpty
            ? otherLeadSource.trim()
            : leadSource;

    final extra = <String>[
      'Expo Event: $event',
      'Interested Product/Service: $effectiveInterest',
      if (leadSource == 'Other' && otherLeadSource.trim().isNotEmpty)
        'Other Lead Source: ${otherLeadSource.trim()}',
      if (notes.trim().isNotEmpty) 'Expo Notes: ${notes.trim()}',
    ].join('\n');

    final lead = Lead(
      id: '',
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      accountName: company.trim(),
      title: title.trim(),
      phoneWork: phone.trim(),
      phoneMobile: mobile.trim(),
      email: email.trim(),
      website: '',
      street: '',
      suburb: '',
      city: '',
      province: '',
      postalCode: '',
      country: '',
      description: extra,
      status: 'New',
      leadSource: effectiveLeadSource,
      assignedTo: '',
      dateCreated: '',
    );

    return _leadService.createLead(lead);
  }
}
