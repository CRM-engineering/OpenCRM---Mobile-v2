import 'package:flutter/material.dart';

import '../../services/expo_service.dart';
import '../../services/session_manager.dart';
import 'expo_lead_kiosk_screen.dart';

class ExpoSetupScreen extends StatefulWidget {
  const ExpoSetupScreen({super.key});

  @override
  State<ExpoSetupScreen> createState() => _ExpoSetupScreenState();
}

class _ExpoSetupScreenState extends State<ExpoSetupScreen> {
  final _otherEvent = TextEditingController();
  final _otherSource = TextEditingController();

  ExpoSetupOptions? _options;
  String? _event;
  String? _leadSource;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final options = await ExpoService().loadSetupOptions();
      if (!mounted) return;

      setState(() {
        _options = options;
        _event = options.events.first;
        _leadSource = options.leadSources.first;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _options = const ExpoSetupOptions(
          events: ExpoService.fallbackEvents,
          leadSources: ExpoService.fallbackLeadSources,
        );
        _event = ExpoService.fallbackEvents.first;
        _leadSource = ExpoService.fallbackLeadSources.first;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _otherEvent.dispose();
    _otherSource.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_event == null || _leadSource == null) return;

    if (_event == 'Other' && _otherEvent.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the event name.')),
      );
      return;
    }

    if (_leadSource == 'Other' && _otherSource.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the lead source.')),
      );
      return;
    }

    final event = _event == 'Other'
        ? _otherEvent.text.trim()
        : _event!;

    final source = _leadSource == 'Other'
        ? _otherSource.text.trim()
        : _leadSource!;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExpoLeadKioskScreen(
          event: event,
          leadSource: source,
        ),
      ),
    );
  }

  Future<void> _exit() async {
    SessionManager.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expo Setup'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: _loading
                        ? const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading Expo options from SuiteCRM...'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(
                                Icons.event_available,
                                size: 64,
                                color: Color(0xFFF7941D),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Expo Setup',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Choose the event and lead source for this kiosk session.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 28),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _event,
                                decoration: const InputDecoration(
                                  labelText: 'Event',
                                  prefixIcon: Icon(Icons.event),
                                  border: OutlineInputBorder(),
                                ),
                                items: _options!.events
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _event = value);
                                  }
                                },
                              ),
                              if (_event == 'Other') ...[
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _otherEvent,
                                  decoration: const InputDecoration(
                                    labelText: 'Other event name',
                                    prefixIcon: Icon(Icons.edit_note),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _leadSource,
                                decoration: const InputDecoration(
                                  labelText: 'Lead Source',
                                  prefixIcon: Icon(Icons.source),
                                  border: OutlineInputBorder(),
                                ),
                                items: _options!.leadSources
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _leadSource = value);
                                  }
                                },
                              ),
                              if (_leadSource == 'Other') ...[
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _otherSource,
                                  decoration: const InputDecoration(
                                    labelText: 'Other lead source',
                                    prefixIcon: Icon(Icons.edit_note),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 54,
                                child: FilledButton.icon(
                                  onPressed: _start,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text(
                                    'START LEAD CAPTURE',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _exit,
                                icon: const Icon(Icons.logout),
                                label: const Text('EXIT EXPO MODE'),
                              ),
                            ],
                          ),
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
