import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/app_state.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';
import '../core/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback done;
  const WelcomeScreen({super.key, required this.state, required this.done});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int step = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: PageBody(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Brand(),
              if (step > 0)
                TextButton(
                  onPressed: widget.done,
                  child: Text(context.tr('skip')),
                ),
            ],
          ),
          const SizedBox(height: 28),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(80),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(80),
            ),
            child: Image.asset(
              'assets/images/tomato.jpg',
              height: MediaQuery.sizeOf(context).height * .31,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Heading(
              context.tr(step == 0 ? 'welcome' : 'onboard$step'),
              key: ValueKey(step),
              subtitle: context.tr(
                step == 0 ? 'chooseLanguage' : 'onboard${step}Body',
              ),
            ),
          ),
          if (step == 0) ...[
            for (final lang in ['te', 'en'])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: widget.state.language == lang
                        ? sage
                        : null,
                    padding: const EdgeInsets.all(20),
                  ),
                  onPressed: () => widget.state.setLanguage(lang),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lang == 'te' ? 'తెలుగు — Telugu' : 'English',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      if (widget.state.language == lang)
                        const Icon(Icons.check_circle),
                    ],
                  ),
                ),
              ),
          ] else
            Row(
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8, bottom: 24),
                  width: step == i + 1 ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: step == i + 1 ? forest : sage,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          FilledButton(
            onPressed: () {
              if (step == 3) {
                widget.done();
              } else {
                setState(() => step++);
              }
            },
            child: Text(context.tr(step == 3 ? 'start' : 'continue')),
          ),
        ],
      ),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback done;
  const AuthScreen({super.key, required this.state, required this.done});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final name = TextEditingController(),
      mobile = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      identifier = TextEditingController();
  bool register = false, visible = false, busy = false;
  @override
  void dispose() {
    for (final c in [name, mobile, email, password, identifier]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (password.text.length < (register ? 10 : 1) ||
        (register
            ? name.text.trim().isEmpty ||
                  !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(mobile.text.trim())
            : identifier.text.trim().isEmpty)) {
      toast(context, 'required');
      return;
    }
    setState(() => busy = true);
    try {
      await widget.state.authenticate(
        register,
        register
            ? {
                'name': name.text.trim(),
                'mobile': mobile.text.trim(),
                'email': email.text.trim().isEmpty ? null : email.text.trim(),
                'password': password.text,
              }
            : {'identifier': identifier.text.trim(), 'password': password.text},
      );
      if (mounted) {
        widget.done();
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'error');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Brand()),
    body: PageBody(
      children: [
        Heading(
          context.tr(register ? 'register' : 'welcome'),
          subtitle: context.tr('authNote'),
        ),
        if (const bool.fromEnvironment('TEMPORARY_SERVER'))
          Notice(context.tr('temporaryServer'), warning: true),
        if (register) ...[
          field(name, 'name'),
          field(mobile, 'mobile', type: TextInputType.phone),
          field(email, 'email', type: TextInputType.emailAddress),
        ] else
          field(identifier, 'identifier'),
        TextField(
          controller: password,
          obscureText: !visible,
          decoration: InputDecoration(
            labelText: context.tr('password'),
            helperText: register ? context.tr('passwordHint') : null,
            suffixIcon: IconButton(
              tooltip: context.tr('password'),
              onPressed: () => setState(() => visible = !visible),
              icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: busy ? null : submit,
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.tr(register ? 'register' : 'login')),
        ),
        TextButton(
          onPressed: busy ? null : () => setState(() => register = !register),
          child: Text(context.tr(register ? 'login' : 'register')),
        ),
        OutlinedButton(
          onPressed: busy ? null : widget.done,
          child: Text(context.tr('guest')),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: busy ? null : () => editServer(context, widget.state),
          icon: const Icon(Icons.dns_outlined),
          label: Text(context.tr('server')),
        ),
      ],
    ),
  );
  Widget field(TextEditingController c, String key, {TextInputType? type}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: c,
          keyboardType: type,
          decoration: InputDecoration(labelText: context.tr(key)),
        ),
      );
}

Future<void> editServer(BuildContext context, AppState state) async {
  final controller = TextEditingController(text: state.api.base);
  final value = await showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(c.tr('server')),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: c.tr('serverHint')),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: Text(c.tr('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            c,
            controller.text.trim().replaceAll(RegExp(r'/$'), ''),
          ),
          child: Text(c.tr('save')),
        ),
      ],
    ),
  );
  // Dialog exit animation still owns the controller; dispose after it completes.
  await Future<void>.delayed(const Duration(milliseconds: 250));
  controller.dispose();
  if (value == null || !context.mounted) {
    return;
  }
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      !(uri.scheme == 'https' ||
          (uri.scheme == 'http' &&
              ['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host)))) {
    toast(context, 'serverInvalid');
    return;
  }
  if (state.api.base != value) {
    try {
      await state.logout();
    } catch (_) {
      /* Local session is always cleared. */
    }
    state.api.base = value;
    await state.prefs.setString('server', value);
  }
  if (context.mounted) {
    toast(context, 'serverSaved');
  }
}

class LocationScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback? done;
  const LocationScreen({super.key, required this.state, this.done});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final fields = List.generate(4, (_) => TextEditingController());
  bool busy = false;
  @override
  void dispose() {
    for (final c in fields) {
      c.dispose();
    }
    super.dispose();
  }

  void finish() {
    if (widget.done != null) {
      widget.done!();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> gps() async {
    setState(() => busy = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
      await widget.state.setLocation(
        '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
      );
      if (mounted) {
        finish();
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'gpsError');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr('location'))),
    body: PageBody(
      children: [
        const Icon(Icons.landscape_outlined, size: 84, color: forest),
        const SizedBox(height: 24),
        Heading(context.tr('location'), subtitle: context.tr('locationBody')),
        OutlinedButton.icon(
          onPressed: busy ? null : gps,
          icon: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(context.tr('currentLocation')),
        ),
        section(context, 'manual'),
        Wrap(
          spacing: 8,
          children: ['Andhra Pradesh', 'Telangana']
              .map(
                (s) => ActionChip(
                  label: Text(s),
                  onPressed: () => fields[0].text = s,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: fields[i],
              decoration: InputDecoration(
                labelText: context.tr(
                  ['state', 'district', 'mandal', 'village'][i],
                ),
              ),
            ),
          ),
        FilledButton(
          onPressed: busy
              ? null
              : () async {
                  final value = fields
                      .map((c) => c.text.trim())
                      .where((s) => s.isNotEmpty)
                      .toList()
                      .reversed
                      .join(', ');
                  if (value.isEmpty) {
                    toast(context, 'required');
                    return;
                  }
                  await widget.state.setLocation(value);
                  if (mounted) {
                    finish();
                  }
                },
          child: Text(context.tr('save')),
        ),
        TextButton(
          onPressed: busy ? null : finish,
          child: Text(context.tr('skip')),
        ),
      ],
    ),
  );
}
