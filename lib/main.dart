import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/country_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/club_provider.dart';

// Services
import 'services/attendance_service.dart';

// Repositories
import 'repositories/attendance_repository.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(const VClubApp());
}

class VClubApp extends StatelessWidget {
  const VClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              AttendanceProvider(AttendanceRepository(AttendanceService())),
        ),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ClubProvider()),
      ],
      child: MaterialApp(
        title: 'VCLUB',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Splash Screen menjadi halaman pertama.
        home: const SplashScreen(nextScreen: AuthGate()),
      ),
    );
  }
}

// Menentukan halaman berdasarkan status login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isAuthenticated) {
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
