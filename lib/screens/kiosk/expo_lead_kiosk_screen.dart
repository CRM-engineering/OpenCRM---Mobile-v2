import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../services/expo_service.dart';
import '../../services/session_manager.dart';

class ExpoLeadKioskScreen extends StatefulWidget {
  final String event;
  final String leadSource;

  const ExpoLeadKioskScreen({
    super.key,
    required this.event,
    required this.leadSource,
  });

  @override
  State<ExpoLeadKioskScreen> createState() => _ExpoLeadKioskScreenState();
}

class _ExpoLeadKioskScreenState extends State<ExpoLeadKioskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _company = TextEditingController();
  final _title = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _phone = TextEditingController();
  final _interest = TextEditingController();
  final _notes = TextEditingController();

  static const _interests = <String>[
    'Product Information',
    'Sales Enquiry',
    'Service Request',
    'Technical Support',
    'Partnership',
    'Event Follow-up',
    'Other',
    'Other',
  ];

  String _selectedInterest = _interests.first;
  bool _submitting = false;
  bool _success = false;
  Timer? _resetTimer;

  ExpoService get _service => ExpoService();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    WakelockPlus.disable();
    _firstName.dispose();
    _lastName.dispose();
    _company.dispose();
    _title.dispose();
    _email.dispose();
    _mobile.dispose();
    _phone.dispose();
    _interest.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate() || _submitting) return;

    setState(() => _submitting = true);

    try {
      final created = await _service.submitLead(
        firstName: _firstName.text,
        lastName: _lastName.text,
        company: _company.text,
        title: _title.text,
        email: _email.text,
        mobile: _mobile.text,
        phone: _phone.text,
        interest: _selectedInterest,
        otherInterest: _interest.text,
        event: widget.event,
        leadSource: widget.leadSource,
        otherLeadSource: '',
        notes: _notes.text,
      );

      if (!mounted) return;

      if (!created) {
        throw Exception('SuiteCRM did not confirm the Lead was created.');
      }

      setState(() {
        _submitting = false;
        _success = true;
      });

      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 8), _resetForm);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit lead: $e')),
      );
    }
  }

  void _resetForm() {
    if (!mounted) return;

    _formKey.currentState?.reset();
    _firstName.clear();
    _lastName.clear();
    _company.clear();
    _title.clear();
    _email.clear();
    _mobile.clear();
    _phone.clear();
    _interest.clear();
    _notes.clear();

    setState(() {
      _selectedInterest = _interests.first;
      _success = false;
      _submitting = false;
    });
  }

  Future<void> _exitExpo() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Expo Mode?'),
        content: const Text(
          'This will end the Expo session and return to the normal login screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
        SessionManager.clear();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final required = _required(value, 'Email');
    if (required != null) return required;
    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Expo Lead Capture'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Exit Expo Mode',
              icon: const Icon(Icons.lock_outline),
              onPressed: _exitExpo,
            ),
          ],
        ),
        body: SafeArea(
          child: _success ? _successView() : _formView(),
        ),
      ),
    );
  }

  Widget _successView() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 90,
                    color: Color(0xFFF7941D),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Thank you!',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We have received your information. '
                    'A team representative will be in touch.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  FilledButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('START NEW REGISTRATION'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The form will reset automatically.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formView() {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(20, 20, 20, keyboardBottom + 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Let's Connect!",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.event} • ${widget.leadSource}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final twoColumns = constraints.maxWidth >= 560;
                            final first = TextFormField(
                              controller: _firstName,
                              scrollPadding: const EdgeInsets.only(bottom: 360),
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                'First Name *',
                                Icons.person_outline,
                              ),
                              validator: (v) => _required(v, 'First Name'),
                            );
                            final last = TextFormField(
                              controller: _lastName,
                              scrollPadding: const EdgeInsets.only(bottom: 360),
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                'Last Name *',
                                Icons.person_outline,
                              ),
                              validator: (v) => _required(v, 'Last Name'),
                            );

                            if (!twoColumns) {
                              return Column(
                                children: [
                                  first,
                                  const SizedBox(height: 16),
                                  last,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: first),
                                const SizedBox(width: 16),
                                Expanded(child: last),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _company,
                          scrollPadding: const EdgeInsets.only(bottom: 360),
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            'Company *',
                            Icons.business_outlined,
                          ),
                          validator: (v) => _required(v, 'Company'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _title,
                          scrollPadding: const EdgeInsets.only(bottom: 360),
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            'Job Title',
                            Icons.badge_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final twoColumns = constraints.maxWidth >= 560;
                            final email = TextFormField(
                              controller: _email,
                              scrollPadding: const EdgeInsets.only(bottom: 360),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                'Email *',
                                Icons.email_outlined,
                              ),
                              validator: _emailValidator,
                            );
                            final mobile = TextFormField(
                              controller: _mobile,
                              scrollPadding: const EdgeInsets.only(bottom: 360),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                'Mobile',
                                Icons.phone_android_outlined,
                              ),
                            );

                            if (!twoColumns) {
                              return Column(
                                children: [
                                  email,
                                  const SizedBox(height: 16),
                                  mobile,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: email),
                                const SizedBox(width: 16),
                                Expanded(child: mobile),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phone,
                          scrollPadding: const EdgeInsets.only(bottom: 360),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            'Business Phone',
                            Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedInterest,
                          decoration: _decoration(
                            'What are you interested in? *',
                            Icons.interests_outlined,
                          ),
                          items: _interests
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value, overflow: TextOverflow.ellipsis),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedInterest = value;
                                if (value != 'Other') _interest.clear();
                              });
                            }
                          },
                        ),

                        if (_selectedInterest == 'Other') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _interest,
                            scrollPadding: const EdgeInsets.only(bottom: 360),
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              'Other — please specify *',
                              Icons.edit_note,
                            ),
                            validator: (value) {
                              if (_selectedInterest == 'Other') {
                                return _required(value, 'Other interest');
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notes,
                          scrollPadding: const EdgeInsets.only(bottom: 360),
                          minLines: 3,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          decoration: _decoration(
                            'Anything else you would like us to know?',
                            Icons.notes_outlined,
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          height: 56,
                          child: FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              _submitting
                                  ? 'SUBMITTING...'
                                  : 'SUBMIT MY INFORMATION',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lead Source: ${widget.leadSource}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
