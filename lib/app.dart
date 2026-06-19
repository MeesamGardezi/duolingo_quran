import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'services/progress_service.dart';
import 'screens/main_nav.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'theme/app_theme.dart';

class DuolingoQuranApp extends StatelessWidget {
  const DuolingoQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'Quran Journey',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final done = await ProgressService.instance.isOnboardingComplete();
    if (mounted) setState(() => _onboardingComplete = done);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (_onboardingComplete == null || !provider.initialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F7F7),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🕌', style: TextStyle(fontSize: 60)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Color(0xFF58CC02)),
            ],
          ),
        ),
      );
    }

    if (!_onboardingComplete!) {
      return const OnboardingScreen();
    }

    return const MainNav();
  }
}
