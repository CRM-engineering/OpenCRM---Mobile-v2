import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/login_result.dart';
import 'suitecrm_client.dart';

class AuthService {
  Future<LoginResult> login(
    String username,
    String password,
  ) async {
    final md5Password =
        md5.convert(utf8.encode(password)).toString();

    final response = await SuiteCRMClient().login(
      username,
      md5Password,
    );

    if (response.containsKey('id')) {
      final nameValueList = response['name_value_list'];

      return LoginResult(
        success: true,
        sessionId: response['id'],
        userId: nameValueList['user_id']['value'],
        username: nameValueList['user_name']['value'],
        fullName: nameValueList['user_name']['value'],
        isAdmin: _asBool(
          nameValueList['user_is_admin']?['value'] ??
              response['user_is_admin'] ??
              false,
        ),
      );
    }

    return LoginResult(
      success: false,
      error: response['description'] ?? 'Login failed.',
    );
  }


  bool _asBool(dynamic value) {
    return value == true ||
        value.toString().toLowerCase() == 'true' ||
        value.toString() == '1';
  }
}
