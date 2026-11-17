import 'suitecrm_client.dart';
import 'session_manager.dart';

class PermissionManager {
  static Map<String, Map<String, bool>> _permissions = {};
  static bool _initialized = false;

  static bool get initialized => _initialized;

  static Future<void> load() async {
    _permissions = {};
    _initialized = false;
    try {
      _permissions = await SuiteCRMClient().getAvailableModulePermissions();
      _initialized = true;
    } catch (_) {
      _permissions = {};
      _initialized = false;
    }
  }

  static void clear() {
    _permissions = {};
    _initialized = false;
  }

  static bool _can(String module, String action) {
    // SuiteCRM's system administrators have unrestricted module ACLs.
    // Keep the UI usable even if get_available_modules does not return
    // every ACL entry for an administrator. The server remains the
    // ultimate authority for every API request.
    if (SessionManager.isAdmin) return true;
    return _permissions[module]?[action.toLowerCase()] == true;
  }

  static bool canList(String module) => _can(module, 'list');
  static bool canView(String module) => _can(module, 'view');
  // SuiteCRM ACLs do not expose a separate "create" action through
  // get_available_modules. Record creation is governed by edit access.
  static bool canCreate(String module) => _can(module, 'edit');
  static bool canEdit(String module) => _can(module, 'edit');
  static bool canDelete(String module) => _can(module, 'delete');
  static bool can(String module, String action) => _can(module, action);
}
