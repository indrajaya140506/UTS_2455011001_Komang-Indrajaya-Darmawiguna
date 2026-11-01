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
import 'providers/match_provider.dart';
import 'providers/club_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('SUPABASE URL: ${SupabaseConfig.url}');
  print('SUPABASE KEY TERISI: ${SupabaseConfig.publishableKey.isNotEmpty}');

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
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ClubProvider()),
      ],
      child: MaterialApp(
        title: 'VCLUB',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
