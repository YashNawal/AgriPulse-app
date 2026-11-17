import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/agri_provider.dart';
import 'providers/language_provider.dart';
import 'ui/screens/main_navigation.dart';
import 'ui/screens/onboarding/select_language_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://dpkjhgnhagjzuloxjlqo.supabase.co',
      // ignore: deprecated_member_use
      anonKey: 'sb_publishable_dqTh_YtBYhdYyQmDF3gilQ_can4Buw-',
      // ignore: deprecated_member_use
      publishableKey: 'sb_publishable_dqTh_YtBYhdYyQmDF3gilQ_can4Buw-',
    );
  } catch (e) {
    debugPrint('Supabase init warning: $e');
  }

  runApp(const KisanMitraApp());
}

class KisanMitraApp extends StatelessWidget {
  const KisanMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AgriProvider()),
      ],
      child: MaterialApp(
        title: 'KisanMitra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppEntryRouter(),
      ),
    );
  }
}

class AppEntryRouter extends StatefulWidget {
  const AppEntryRouter({super.key});

  @override
  State<AppEntryRouter> createState() => _AppEntryRouterState();
}

class _AppEntryRouterState extends State<AppEntryRouter> {
  bool _isChecking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLocalProfile = prefs.getString('kisanmitra_farmer_profile');
      final isGuest = prefs.getBool('kisanmitra_is_guest') ?? false;
      final session = Supabase.instance.client.auth.currentSession;

      if ((hasLocalProfile != null && hasLocalProfile.isNotEmpty) || isGuest || session != null) {
        _isLoggedIn = true;
        if (mounted) {
          final agri = context.read<AgriProvider>();
          await agri.loadProfileFromPrefs();
          if (session != null) {
            await agri.fetchFarmerProfileFromSupabase();
          }
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 18),
              const Text(
                'KisanMitra',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'AI-Powered Agri Intelligence',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(color: AppTheme.accentEmerald, strokeWidth: 2),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoggedIn) {
      return const MainNavigation();
    }

    return const SelectLanguageScreen();
  }
}
