import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../services/session_manager.dart';
import '../../services/permission_manager.dart';
import '../../services/expo_service.dart';
import '../../services/secure_storage_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../kiosk/expo_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _secureStorage = SecureStorageService();

  bool rememberMe = true;
  bool obscurePassword = true;
  bool isLoading = false;
  bool expoLoading = false;
  bool loadingSavedLogin = true;

  @override
  void initState() {
    super.initState();
    _restoreRememberedLogin();
  }

  Future<void> _restoreRememberedLogin() async {
    try {
      final saved = await _secureStorage.readNormalLogin();
      if (!mounted) return;

      if (saved != null) {
        usernameController.text = saved['username']!;
        passwordController.text = saved['password']!;
        rememberMe = true;
      }
    } catch (_) {
      // Secure storage may be unavailable on an unusual platform.
    } finally {
      if (mounted) setState(() => loadingSavedLogin = false);
    }
  }

  Future<void> login() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your username and password."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final username = usernameController.text.trim();
      final password = passwordController.text;

      final result = await AuthService().login(username, password);

      if (!mounted) return;

      if (result.success) {
        SessionManager.sessionId = result.sessionId;
        SessionManager.userId = result.userId;
        SessionManager.username = result.username;
        SessionManager.fullName = result.fullName;
        SessionManager.isAdmin = result.isAdmin;

        if (rememberMe) {
          await _secureStorage.saveNormalLogin(
            username: username,
            password: password,
          );
        } else {
          await _secureStorage.clearNormalLogin();
        }

        await PermissionManager.load();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? "Login failed.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  Future<void> _enterExpo() async {
    setState(() => expoLoading = true);

    try {
      final loggedInWithSavedPassword =
          await ExpoService().trySavedExpoLogin();

      if (!mounted) return;

      if (loggedInWithSavedPassword) {
        await _openExpoSetup();
        return;
      }

      final controller = TextEditingController();

      final password = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          bool obscure = true;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.event_available),
                    SizedBox(width: 10),
                    Text('Expo Lead Capture'),
                  ],
                ),
                content: SizedBox(
                  width: 380,
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Expo password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() => obscure = !obscure);
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) Navigator.pop(context, value);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Navigator.pop(context, controller.text);
                      }
                    },
                    child: const Text('START EXPO'),
                  ),
                ],
              );
            },
          );
        },
      );

      controller.dispose();

      if (password == null || password.isEmpty || !mounted) return;

      await ExpoService().enterExpoMode(password);

      if (!mounted) return;
      await _openExpoSetup();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not enter Expo Mode: $e')),
      );
    } finally {
      if (mounted) setState(() => expoLoading = false);
    }
  }

  Future<void> _openExpoSetup() async {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExpoSetupScreen(),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 140,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        AppConfig.appName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 35),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: rememberMe,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text("Remember Me"),
                        onChanged: loadingSavedLogin
                            ? null
                            : (value) {
                                setState(() => rememberMe = value ?? true);
                              },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(
                            isLoading ? "Signing In..." : "LOGIN",
                            style: const TextStyle(fontSize: 18),
                          ),
                          onPressed: isLoading || expoLoading ? null : login,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          icon: expoLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.event_available),
                          label: const Text(
                            'EXPO LEAD CAPTURE',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: isLoading || expoLoading
                              ? null
                              : _enterExpo,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Version ${AppConfig.version}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
