import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'l10n/strings.dart';
import 'services/app_state.dart';
import 'screens/setup.dart';
import 'screens/home.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(await SharedPreferences.getInstance());
  await state.init();
  runApp(CropCareApp(state: state));
}

class CropCareApp extends StatelessWidget {
  final AppState state;
  const CropCareApp({super.key, required this.state});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => MaterialApp(
      title: 'CropCare',
      debugShowCheckedModeBanner: false,
      theme: cropTheme(state.language),
      locale: Locale(state.language),
      supportedLocales: const [Locale('en'), Locale('te')],
      localizationsDelegates: const [
        Strings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Entry(state: state),
    ),
  );
}

class Entry extends StatefulWidget {
  final AppState state;
  const Entry({super.key, required this.state});
  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  int step = -1;
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(
          () => step = widget.state.prefs.getBool('onboarded') == true ? 3 : 0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (step == -1) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/tomato.jpg', fit: BoxFit.cover),
            Container(color: forest.withValues(alpha: .78)),
            SafeArea(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: .85, end: 1),
                  duration: const Duration(milliseconds: 900),
                  builder: (c, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Brand(light: true),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr('tagline'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: ivory, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (step == 0) {
      return WelcomeScreen(
        state: widget.state,
        done: () => setState(() => step = 1),
      );
    }
    if (step == 1) {
      return AuthScreen(
        state: widget.state,
        done: () => setState(() => step = 2),
      );
    }
    if (step == 2) {
      return LocationScreen(
        state: widget.state,
        done: () async {
          await widget.state.prefs.setBool('onboarded', true);
          if (mounted) {
            setState(() => step = 3);
          }
        },
      );
    }
    return HomeShell(
      state: widget.state,
      onLogout: () => setState(() => step = 1),
    );
  }
}
